#!/usr/bin/env python3
"""Generate MoP quest-navigation data from the pinned SQLyog world dump.

This version understands Pandaria's separate quest_objective table and emits
only verified world spawn coordinates (plus safe entry/GUID fallbacks).
"""
from __future__ import annotations

import argparse
import collections
import importlib.util
import json
import re
import zipfile
from pathlib import Path

BASE_PATH = Path(__file__).with_name("extract_r5_mop_data.py")
SPEC = importlib.util.spec_from_file_location("r5base", BASE_PATH)
BASE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(BASE)

BASE.TARGET_TABLES.update(
    {
        "quest_objective",
        "quest_objective_locale",
        "creature_template_locale",
        "gameobject_template_locale",
    }
)

START = re.compile(
    r"(?:CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?|"
    r"INSERT(?:\s+IGNORE)?\s+INTO|REPLACE\s+INTO|UPDATE)"
    r"\s+`?([A-Za-z0-9_]+)`?",
    re.I,
)


def iter_statements(path: Path):
    with path.open("r", encoding="utf-8-sig", errors="replace") as handle:
        active = False
        buffer: list[str] = []
        quoted = False
        escaped = False
        for line in handle:
            if not active:
                match = START.match(line.lstrip())
                if not match or match.group(1).lower() not in BASE.TARGET_TABLES:
                    continue
                active = True
                buffer = []
                quoted = False
                escaped = False
            buffer.append(line)
            index = 0
            while index < len(line):
                char = line[index]
                if quoted:
                    if escaped:
                        escaped = False
                    elif char == "\\":
                        escaped = True
                    elif char == "'":
                        if index + 1 < len(line) and line[index + 1] == "'":
                            index += 1
                        else:
                            quoted = False
                else:
                    if char == "'":
                        quoted = True
                    elif char == ";":
                        yield "".join(buffer)
                        active = False
                        buffer = []
                        quoted = False
                        escaped = False
                        break
                index += 1
        if active and buffer:
            yield "".join(buffer)


def parse_sources(paths: list[Path]):
    schemas: dict[str, list[str]] = {}
    rows = collections.defaultdict(list)
    updates = []
    stats = collections.Counter()
    for path in paths:
        for statement in iter_statements(path):
            source = statement.lstrip()
            create = re.match(
                r"CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?\s+`?([A-Za-z0-9_]+)`?"
                r"\s*\((.*)\)\s*(?:ENGINE|TYPE|COMMENT|;)",
                source,
                re.I | re.S,
            )
            if create:
                schemas[create.group(1).lower()] = re.findall(
                    r"^\s*`([^`]+)`\s+", create.group(2), re.M
                )
                continue
            insert = re.match(
                r"(?:INSERT(?:\s+IGNORE)?\s+INTO|REPLACE\s+INTO)"
                r"\s+`?([A-Za-z0-9_]+)`?\s*(?:\((.*?)\))?\s+VALUES\s*(.*);\s*$",
                source,
                re.I | re.S,
            )
            if insert:
                table = insert.group(1).lower()
                explicit = insert.group(2)
                columns = (
                    [value.strip().strip("`") for value in explicit.split(",")]
                    if explicit
                    else schemas.get(table, [])
                )
                values = BASE.split_values(insert.group(3))
                stats[table] += len(values)
                if not columns:
                    rows[table].extend(values)
                else:
                    width = len(columns)
                    for value_row in values:
                        if len(value_row) < width:
                            value_row = value_row + [None] * (width - len(value_row))
                        rows[table].append(
                            {
                                str(columns[index]).lower(): value_row[index]
                                for index in range(min(width, len(value_row)))
                            }
                        )
                continue
            update = re.match(
                r"UPDATE\s+`?([A-Za-z0-9_]+)`?\s+SET\s+(.*?)\s+WHERE\s+(.*);\s*$",
                source,
                re.I | re.S,
            )
            if update:
                updates.append((update.group(1).lower(), update.group(2), update.group(3)))
    return schemas, rows, updates, stats


def is_korean_locale(value) -> bool:
    text = str(value or "").strip().lower()
    return text in {"1", "kokr", "ko_kr", "ko-kr"}


def verified_targets(pairs, creature_spawns, object_spawns, creature_names, object_names, maximum=6):
    output = []
    seen = set()
    for kind, entry in pairs:
        key = (kind, entry)
        if key in seen:
            continue
        seen.add(key)
        source = creature_spawns.get(entry, []) if kind == "c" else object_spawns.get(entry, [])
        output.extend(BASE.representative(source, 2))
        if not source:
            output.append(
                {
                    "k": kind,
                    "e": entry,
                    "g": 0,
                    "m": 0,
                    "x": 0,
                    "y": 0,
                    "z": 0,
                    "n": creature_names.get(entry, "") if kind == "c" else object_names.get(entry, ""),
                }
            )
        if len(output) >= maximum:
            break
    return output[:maximum]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--server", required=True)
    parser.add_argument("--out", required=True)
    options = parser.parse_args()

    server = Path(options.server)
    output_dir = Path(options.out)
    output_dir.mkdir(parents=True, exist_ok=True)
    world_zip = server / "sql/base/world_04_03_2023.zip"
    extract_dir = output_dir / "world_extract"
    extract_dir.mkdir(exist_ok=True)

    with zipfile.ZipFile(world_zip) as archive:
        sql_members = [name for name in archive.namelist() if name.lower().endswith(".sql")]
        if not sql_members:
            raise SystemExit("world archive has no SQL member")
        for member in sql_members:
            archive.extract(member, extract_dir)

    source_paths = [extract_dir / member for member in sql_members]
    korean_dir = server / "repack/database/korean"
    if korean_dir.exists():
        source_paths.extend(sorted(korean_dir.glob("*.sql")))

    schemas, rows, updates, stats = parse_sources(source_paths)

    creature_names: dict[int, str] = {}
    creature_loot: dict[int, int] = {}
    for row in rows.get("creature_template", []):
        entry = BASE.to_int(BASE.get(row, "entry", "id"))
        if entry:
            creature_names[entry] = str(BASE.get(row, "name", default="") or "")
            creature_loot[entry] = BASE.to_int(BASE.get(row, "lootid", "loot_id"))

    object_names: dict[int, str] = {}
    object_loot: dict[int, int] = {}
    for row in rows.get("gameobject_template", []):
        entry = BASE.to_int(BASE.get(row, "entry", "id"))
        if entry:
            object_names[entry] = str(BASE.get(row, "name", default="") or "")
            object_loot[entry] = BASE.to_int(BASE.get(row, "data1", "lootid", "loot_id"))

    for row in rows.get("locales_creature", []):
        if not is_korean_locale(BASE.get(row, "locale")):
            continue
        entry = BASE.to_int(BASE.get(row, "entry", "id"))
        name = BASE.get(row, "name", "name_loc1")
        if entry and name:
            creature_names[entry] = str(name)

    for row in rows.get("locales_gameobject", []):
        entry = BASE.to_int(BASE.get(row, "entry", "id"))
        name = BASE.get(row, "name_loc1", "name")
        if entry and name:
            object_names[entry] = str(name)

    for table, destination in (
        ("creature_template_locale", creature_names),
        ("gameobject_template_locale", object_names),
    ):
        for row in rows.get(table, []):
            if not is_korean_locale(BASE.get(row, "locale")):
                continue
            entry = BASE.to_int(BASE.get(row, "entry", "id"))
            name = BASE.get(row, "name")
            if entry and name:
                destination[entry] = str(name)

    teleport_names: dict[int, str] = {}
    for row in rows.get("game_tele", []):
        entry = BASE.to_int(BASE.get(row, "id", "entry"))
        name = BASE.get(row, "name")
        if entry and name:
            teleport_names[entry] = str(name)
    BASE.apply_updates(updates, creature_names, object_names, teleport_names)

    creature_spawns = collections.defaultdict(list)
    for row in rows.get("creature", []):
        entry = BASE.to_int(BASE.get(row, "id", "entry"))
        if entry:
            creature_spawns[entry].append(
                BASE.compact_spawn(row, "c", entry, creature_names.get(entry, ""))
            )

    object_spawns = collections.defaultdict(list)
    for row in rows.get("gameobject", []):
        entry = BASE.to_int(BASE.get(row, "id", "entry"))
        if entry:
            object_spawns[entry].append(
                BASE.compact_spawn(row, "o", entry, object_names.get(entry, ""))
            )

    starters = collections.defaultdict(list)
    enders = collections.defaultdict(list)
    for table, kind, destination in (
        ("creature_queststarter", "c", starters),
        ("gameobject_queststarter", "o", starters),
        ("creature_questender", "c", enders),
        ("gameobject_questender", "o", enders),
    ):
        for row in rows.get(table, []):
            entry = BASE.to_int(BASE.get(row, "id", "entry"))
            quest = BASE.to_int(BASE.get(row, "quest", "questid"))
            if entry and quest:
                destination[quest].append((kind, entry))

    creature_loot_to_entries = collections.defaultdict(list)
    for entry, loot_id in creature_loot.items():
        creature_loot_to_entries[loot_id or entry].append(entry)
        if loot_id and loot_id != entry:
            creature_loot_to_entries[entry].append(entry)

    object_loot_to_entries = collections.defaultdict(list)
    for entry, loot_id in object_loot.items():
        object_loot_to_entries[loot_id or entry].append(entry)
        if loot_id and loot_id != entry:
            object_loot_to_entries[entry].append(entry)

    item_sources = collections.defaultdict(list)
    for table, kind, inverse in (
        ("creature_loot_template", "c", creature_loot_to_entries),
        ("gameobject_loot_template", "o", object_loot_to_entries),
    ):
        for row in rows.get(table, []):
            loot_entry = BASE.to_int(BASE.get(row, "entry"))
            item_id = BASE.to_int(BASE.get(row, "item"))
            if not item_id:
                continue
            for source_entry in inverse.get(loot_entry, []):
                item_sources[item_id].append((kind, source_entry))

    objective_rows = collections.defaultdict(list)
    for row in rows.get("quest_objective", []):
        quest_id = BASE.to_int(BASE.get(row, "questid", "quest"))
        if quest_id:
            objective_rows[quest_id].append(row)

    quest_ids = set(starters) | set(enders) | set(objective_rows)
    quest_data = {}
    objective_count = 0
    coordinate_objectives = 0

    for quest_id in sorted(quest_ids):
        record = {}
        start_targets = verified_targets(
            starters.get(quest_id, []),
            creature_spawns,
            object_spawns,
            creature_names,
            object_names,
        )
        end_targets = verified_targets(
            enders.get(quest_id, []),
            creature_spawns,
            object_spawns,
            creature_names,
            object_names,
        )
        if start_targets:
            record["s"] = start_targets
        if end_targets:
            record["e"] = end_targets

        objectives = []
        for row in sorted(
            objective_rows.get(quest_id, []),
            key=lambda item: BASE.to_int(BASE.get(item, "index")),
        ):
            objective_type = BASE.to_int(BASE.get(row, "type"), -1)
            object_id = BASE.to_int(BASE.get(row, "objectid", "object"))
            amount = max(1, abs(BASE.to_int(BASE.get(row, "amount"), 1)))
            slot = BASE.to_int(BASE.get(row, "index"), 0) + 1
            objective_id = BASE.to_int(BASE.get(row, "id"))
            description = str(BASE.get(row, "description", default="") or "")
            objective = {
                "s": slot,
                "c": amount,
                "id": objective_id,
                "d": description,
            }

            if objective_type in {0, 3, 11} and object_id:
                objective["k"] = "c"
                objective["e"] = object_id
                candidates = verified_targets(
                    [("c", object_id)],
                    creature_spawns,
                    object_spawns,
                    creature_names,
                    object_names,
                    maximum=3,
                )
                if candidates:
                    objective["r"] = candidates
                    if any(candidate.get("m", 0) for candidate in candidates):
                        coordinate_objectives += 1
            elif objective_type == 2 and object_id:
                objective["k"] = "o"
                objective["e"] = object_id
                candidates = verified_targets(
                    [("o", object_id)],
                    creature_spawns,
                    object_spawns,
                    creature_names,
                    object_names,
                    maximum=3,
                )
                if candidates:
                    objective["r"] = candidates
                    if any(candidate.get("m", 0) for candidate in candidates):
                        coordinate_objectives += 1
            elif objective_type == 1 and object_id:
                objective["k"] = "i"
                objective["i"] = object_id
                pairs = item_sources.get(object_id, [])
                candidates = verified_targets(
                    pairs,
                    creature_spawns,
                    object_spawns,
                    creature_names,
                    object_names,
                    maximum=3,
                ) if pairs else []
                if candidates:
                    objective["r"] = candidates
                    if any(candidate.get("m", 0) for candidate in candidates):
                        coordinate_objectives += 1
            else:
                objective["k"] = "x"
                objective["e"] = object_id
                objective["t"] = objective_type

            objectives.append(objective)
            objective_count += 1

        if objectives:
            record["o"] = objectives
        if record:
            quest_data[quest_id] = record

    def lua_objective(value):
        parts = [
            f's={value["s"]}',
            f'k={BASE.esc_lua(value["k"])}',
            f'c={value["c"]}',
            f'id={value["id"]}',
        ]
        if value.get("e"):
            parts.append(f'e={value["e"]}')
        if value.get("i"):
            parts.append(f'i={value["i"]}')
        if value.get("t") is not None:
            parts.append(f't={value["t"]}')
        if value.get("d"):
            parts.append("d=" + BASE.esc_lua(value["d"]))
        if value.get("r"):
            parts.append("r={" + ",".join(BASE.lua_target(target) for target in value["r"]) + "}")
        return "{" + ",".join(parts) + "}"

    quest_file = output_dir / "QuestLocations.lua"
    with quest_file.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write(
            "-- Generated from pinned MOP_V2_Repack world DB; do not edit by hand.\n"
            "AzerothAdminMoP548 = AzerothAdminMoP548 or {}\n"
            "AzerothAdminMoP548.MoPQuestLocations = {\n"
        )
        for quest_id in sorted(quest_data):
            record = quest_data[quest_id]
            fields = []
            if record.get("s"):
                fields.append("s={" + ",".join(BASE.lua_target(target) for target in record["s"]) + "}")
            if record.get("e"):
                fields.append("e={" + ",".join(BASE.lua_target(target) for target in record["e"]) + "}")
            if record.get("o"):
                fields.append("o={" + ",".join(lua_objective(item) for item in record["o"]) + "}")
            handle.write(f"  [{quest_id}]={{" + ",".join(fields) + "},\n")
        handle.write("}\n")

    teleport_file = output_dir / "TeleportDbNames.lua"
    with teleport_file.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write(
            "-- Generated game_tele command names from pinned MOP_V2_Repack.\n"
            "AzerothAdminMoP548 = AzerothAdminMoP548 or {}\n"
            "AzerothAdminMoP548.MoPTeleportDbNames = {\n"
        )
        for entry in sorted(teleport_names):
            handle.write(f"  [{entry}]={BASE.esc_lua(teleport_names[entry])},\n")
        handle.write("}\n")

    audit = {
        "source_revision": "0739d072f8f1f42523f04cca4b2607d88a01def4",
        "table_rows": dict(stats),
        "quest_records": len(quest_data),
        "objective_slots": objective_count,
        "coordinate_objectives": coordinate_objectives,
        "quest_starters": sum(len(value) for value in starters.values()),
        "quest_enders": sum(len(value) for value in enders.values()),
        "creature_spawn_entries": len(creature_spawns),
        "gameobject_spawn_entries": len(object_spawns),
        "teleport_names": len(teleport_names),
        "korean_creature_names": sum(1 for value in creature_names.values() if re.search("[가-힣]", value)),
        "korean_gameobject_names": sum(1 for value in object_names.values() if re.search("[가-힣]", value)),
    }
    (output_dir / "audit.json").write_text(
        json.dumps(audit, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(json.dumps(audit, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
