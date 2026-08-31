#!/usr/bin/env python3
"""Generate compact Lua indexes directly from Chipa MySQL dumps.

The extractor deliberately does not start MySQL/MariaDB. It streams the SQL
inside the world ZIP, keeps only the four addon datasets, then applies koKR
locale INSERT/REPLACE/UPDATE statements from the integrated Korean patch.
"""

from __future__ import annotations

import argparse
import io
import re
import sys
import zipfile
from pathlib import Path
from typing import Callable, Iterable, TextIO


BASE_TABLES = {"item_template", "quest_template", "creature_template", "game_tele"}
LOCALE_TABLES = {
    "item_template_locale", "quest_template_locale", "creature_template_locale",
    "locales_item", "locales_quest", "locales_creature",
}
TARGET_TABLES = BASE_TABLES | LOCALE_TABLES

# The Korean patch uses an implicit-column REPLACE for this compatibility table.
FALLBACK_COLUMNS = {
    "item_template_locale": ["ID", "locale", "Name", "Description", "VerifiedBuild"],
    "quest_template_locale": ["ID", "locale", "Title"],
    "creature_template_locale": ["entry", "locale", "Name", "Title"],
}

INSERT_START = re.compile(
    r"^\s*(?:insert|replace)\s+(?:ignore\s+)?into\s+`?([A-Za-z0-9_]+)`?",
    re.IGNORECASE,
)
UPDATE_START = re.compile(r"^\s*update\s+`?([A-Za-z0-9_]+)`?\s+set\s+", re.IGNORECASE)
VALUES_WORD = re.compile(r"\bvalues\b", re.IGNORECASE)


def normalize_column(name: str) -> str:
    return name.strip().strip("`").lower()


def clean_text(value: object) -> str:
    text = "" if value is None else str(value)
    return " ".join(text.replace("\x00", " ").replace("\t", " ").splitlines()).strip()


def integer(value: object) -> int:
    try:
        return int(float(str(value or 0)))
    except (TypeError, ValueError):
        return 0


def number_text(value: object) -> str:
    value = str(value or "0").strip()
    try:
        float(value)
    except ValueError:
        return "0"
    return value


def lua_quote(value: object) -> str:
    text = clean_text(value).replace("\\", "\\\\").replace('"', '\\"')
    return '"' + text + '"'


class ValuesParser:
    """Incrementally parse literal tuples following a MySQL VALUES keyword."""

    ESCAPES = {
        "0": "\x00", "b": "\b", "n": "\n", "r": "\r", "t": "\t",
        "Z": "\x1a", "\\": "\\", "'": "'", '"': '"',
    }

    def __init__(self, on_row: Callable[[list[object]], None]):
        self.on_row = on_row
        self.in_tuple = False
        self.in_string = False
        self.escaped = False
        self.token_was_string = False
        self.token: list[str] = []
        self.row: list[object] = []

    def _finish_token(self) -> object:
        raw = "".join(self.token)
        self.token.clear()
        was_string = self.token_was_string
        self.token_was_string = False
        if was_string:
            return raw
        raw = raw.strip()
        return None if raw.upper() == "NULL" else raw

    def feed(self, text: str) -> bool:
        """Consume a chunk. Return True when the SQL statement terminates."""
        i = 0
        while i < len(text):
            char = text[i]
            if self.in_string:
                if self.escaped:
                    self.token.append(self.ESCAPES.get(char, char))
                    self.escaped = False
                elif char == "\\":
                    self.escaped = True
                elif char == "'":
                    if i + 1 < len(text) and text[i + 1] == "'":
                        self.token.append("'")
                        i += 1
                    else:
                        self.in_string = False
                else:
                    self.token.append(char)
                i += 1
                continue

            if not self.in_tuple:
                if char == "(":
                    self.in_tuple = True
                    self.row = []
                    self.token = []
                    self.token_was_string = False
                elif char == ";":
                    return True
                i += 1
                continue

            if char == "'":
                self.in_string = True
                self.token_was_string = True
            elif char == ",":
                self.row.append(self._finish_token())
            elif char == ")":
                self.row.append(self._finish_token())
                self.on_row(self.row)
                self.row = []
                self.in_tuple = False
            else:
                self.token.append(char)
            i += 1
        return False


def split_assignments(text: str) -> list[str]:
    parts: list[str] = []
    start = 0
    quoted = False
    escaped = False
    for index, char in enumerate(text):
        if quoted:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == "'":
                quoted = False
        elif char == "'":
            quoted = True
        elif char == ",":
            parts.append(text[start:index])
            start = index + 1
    parts.append(text[start:])
    return parts


def parse_sql_literal(text: str) -> object:
    text = text.strip()
    if text.upper() == "NULL":
        return None
    if len(text) >= 2 and text[0] == "'" and text[-1] == "'":
        result: list[object] = []
        parser = ValuesParser(lambda row: result.extend(row))
        parser.feed("(" + text + ");")
        return result[0] if result else ""
    return text


class ChipaExtractor:
    def __init__(self) -> None:
        self.items: dict[int, list[object]] = {}
        self.quests: dict[int, list[object]] = {}
        self.creatures: dict[int, list[object]] = {}
        self.teleports: dict[int, list[object]] = {}
        self.locale_updates = {"items": set(), "quests": set(), "creatures": set()}

    @staticmethod
    def _mapped(columns: list[str], row: list[object]) -> dict[str, object]:
        return {normalize_column(name): row[index] for index, name in enumerate(columns) if index < len(row)}

    @staticmethod
    def _value(data: dict[str, object], *names: str) -> object:
        for name in names:
            key = normalize_column(name)
            if key in data:
                return data[key]
        return None

    def consume_row(self, table: str, columns: list[str], row: list[object]) -> None:
        data = self._mapped(columns, row)
        table = table.lower()
        if table == "item_template":
            key = integer(self._value(data, "entry", "id"))
            if key:
                self.items[key] = [key, clean_text(self._value(data, "name")),
                    integer(self._value(data, "Quality")), integer(self._value(data, "ItemLevel")),
                    integer(self._value(data, "RequiredLevel")), integer(self._value(data, "class"))]
        elif table == "quest_template":
            key = integer(self._value(data, "Id", "entry"))
            if key:
                self.quests[key] = [key, clean_text(self._value(data, "Title")),
                    integer(self._value(data, "Level")), integer(self._value(data, "MinLevel")),
                    integer(self._value(data, "ZoneOrSort"))]
        elif table == "creature_template":
            key = integer(self._value(data, "entry", "id"))
            if key:
                self.creatures[key] = [key, clean_text(self._value(data, "name")),
                    integer(self._value(data, "minlevel")), integer(self._value(data, "maxlevel")),
                    integer(self._value(data, "rank"))]
        elif table == "game_tele":
            key = integer(self._value(data, "id"))
            if key:
                self.teleports[key] = [key, clean_text(self._value(data, "name")),
                    integer(self._value(data, "map")), number_text(self._value(data, "position_x")),
                    number_text(self._value(data, "position_y")), number_text(self._value(data, "position_z"))]
        else:
            self._consume_locale_row(table, data)

    def _consume_locale_row(self, table: str, data: dict[str, object]) -> None:
        locale = clean_text(self._value(data, "locale"))
        if locale and locale.lower() not in {"kokr", "1"}:
            return
        if table in {"item_template_locale", "locales_item"}:
            key = integer(self._value(data, "ID", "entry"))
            name = clean_text(self._value(data, "Name", "name_loc1"))
            if key in self.items and name:
                self.items[key][1] = name
                self.locale_updates["items"].add(key)
        elif table in {"quest_template_locale", "locales_quest"}:
            key = integer(self._value(data, "ID", "Id", "entry"))
            name = clean_text(self._value(data, "Title", "Title_loc1"))
            if key in self.quests and name:
                self.quests[key][1] = name
                self.locale_updates["quests"].add(key)
        elif table in {"creature_template_locale", "locales_creature"}:
            key = integer(self._value(data, "entry", "ID"))
            name = clean_text(self._value(data, "Name", "name_loc1"))
            if key in self.creatures and name:
                self.creatures[key][1] = name
                self.locale_updates["creatures"].add(key)

    def consume_update(self, table: str, statement: str) -> None:
        match = re.search(
            r"\bset\b(.*?)\bwhere\b\s*`?(entry|id)`?\s*=\s*'?([0-9]+)'?",
            statement, re.IGNORECASE | re.DOTALL,
        )
        if not match:
            return
        data: dict[str, object] = {normalize_column(match.group(2)): match.group(3)}
        for assignment in split_assignments(match.group(1)):
            part = re.match(r"\s*`?([A-Za-z0-9_]+)`?\s*=\s*(.*?)\s*$", assignment, re.DOTALL)
            if part:
                data[normalize_column(part.group(1))] = parse_sql_literal(part.group(2))
        self._consume_locale_row(table.lower(), data)


def extract_columns(header: str, table: str) -> list[str]:
    table_match = INSERT_START.match(header)
    if table_match:
        rest = header[table_match.end():]
        open_at = rest.find("(")
        if open_at >= 0:
            close_at = rest.find(")", open_at + 1)
            if close_at >= 0:
                return [normalize_column(value) for value in rest[open_at + 1:close_at].split(",")]
    return FALLBACK_COLUMNS.get(table, [])


def scan_sql(stream: TextIO, extractor: ChipaExtractor, label: str) -> None:
    insert_table: str | None = None
    header = ""
    parser: ValuesParser | None = None
    update_table: str | None = None
    update_text = ""
    statements = rows = 0

    def start_values(table: str, text: str, values: re.Match[str]) -> tuple[ValuesParser, bool]:
        columns = extract_columns(text[:values.start()], table)
        if not columns:
            raise ValueError(f"{label}: columns unavailable for {table}")

        def on_row(row: list[object]) -> None:
            nonlocal rows
            extractor.consume_row(table, columns, row)
            rows += 1

        value_parser = ValuesParser(on_row)
        ended = value_parser.feed(text[values.end():])
        return value_parser, ended

    for line in stream:
        if parser is not None:
            if parser.feed(line):
                parser = None
                insert_table = None
                statements += 1
            continue

        if insert_table is not None:
            header += line
            values = VALUES_WORD.search(header)
            if values:
                select = re.search(r"\bselect\b", header[:values.start()], re.IGNORECASE)
                if select:
                    if ";" in line:
                        insert_table = None
                        header = ""
                    continue
                parser, ended = start_values(insert_table, header, values)
                header = ""
                if ended:
                    parser = None
                    insert_table = None
                    statements += 1
            elif ";" in line:
                insert_table = None
                header = ""
            continue

        if update_table is not None:
            update_text += line
            if ";" in line:
                extractor.consume_update(update_table, update_text)
                update_table = None
                update_text = ""
                statements += 1
            continue

        insert = INSERT_START.match(line)
        if insert and insert.group(1).lower() in TARGET_TABLES:
            insert_table = insert.group(1).lower()
            header = line
            values = VALUES_WORD.search(header)
            if values:
                parser, ended = start_values(insert_table, header, values)
                header = ""
                if ended:
                    parser = None
                    insert_table = None
                    statements += 1
            continue

        update = UPDATE_START.match(line)
        if update and update.group(1).lower() in LOCALE_TABLES:
            update_table = update.group(1).lower()
            update_text = line
            if ";" in line:
                extractor.consume_update(update_table, update_text)
                update_table = None
                update_text = ""
                statements += 1

    if parser is not None or insert_table is not None or update_table is not None:
        raise ValueError(f"{label}: unterminated target SQL statement")
    print(f"Scanned {label}: {statements} target statements, {rows} literal rows")


def open_world_sql(path: Path) -> tuple[zipfile.ZipFile, TextIO, str]:
    archive = zipfile.ZipFile(path)
    entries = [info for info in archive.infolist() if info.filename.lower().endswith(".sql")]
    if len(entries) != 1:
        archive.close()
        raise ValueError(f"Expected exactly one SQL entry in {path}, found {len(entries)}")
    raw = archive.open(entries[0])
    stream = io.TextIOWrapper(raw, encoding="utf-8-sig", errors="replace", newline=None)
    return archive, stream, entries[0].filename


def write_table(path: Path, key: str, rows: Iterable[list[object]], field_types: list[str]) -> int:
    path.parent.mkdir(parents=True, exist_ok=True)
    count = 0
    with path.open("w", encoding="utf-8", newline="\n") as output:
        output.write("-- Generated by tools/generate_data_lua.py; do not edit by hand.\n")
        output.write("AzerothAdminMoP = AzerothAdminMoP or {}\n")
        output.write("AzerothAdminMoP.Data = AzerothAdminMoP.Data or {}\n")
        output.write(f"AzerothAdminMoP.Data.{key} = {{\n")
        for row in rows:
            values: list[str] = []
            for index, kind in enumerate(field_types):
                value = row[index] if index < len(row) else None
                if kind == "i":
                    values.append(str(integer(value)))
                elif kind == "n":
                    values.append(number_text(value))
                else:
                    values.append(lua_quote(value))
            output.write("  {" + ",".join(values) + "},\n")
            count += 1
        output.write("}\n")
    return count


def write_source_info(output_dir: Path, revision: str, counts: dict[str, int]) -> None:
    with (output_dir / "SourceInfo.lua").open("w", encoding="utf-8", newline="\n") as output:
        output.write("-- Generated by tools/generate_data_lua.py; do not edit by hand.\n")
        output.write("AzerothAdminMoP = AzerothAdminMoP or {}\n")
        output.write("AzerothAdminMoP.DataSource = {\n")
        output.write('  repository="hilch1981-prog/MOP_V2_Repack",\n')
        output.write(f"  revision={lua_quote(revision)},\n")
        output.write('  world="sql/base/world_04_03_2023.zip",\n')
        output.write('  korean="repack/database/korean/판다리아_5.4.8_한글_통합패치.sql",\n')
        output.write("  counts={")
        output.write(",".join(f"{key}={value}" for key, value in counts.items()))
        output.write("},\n}\n")


def generate(world_zip: Path, korean_sql: Path, output_dir: Path, source_revision: str = "unknown") -> dict[str, int]:
    extractor = ChipaExtractor()
    archive, world_stream, entry_name = open_world_sql(world_zip)
    try:
        with world_stream:
            scan_sql(world_stream, extractor, f"{world_zip.name}:{entry_name}")
    finally:
        archive.close()
    with korean_sql.open("r", encoding="utf-8-sig", errors="replace", newline=None) as stream:
        scan_sql(stream, extractor, korean_sql.name)

    ordered_teleports = sorted(extractor.teleports.values(), key=lambda row: (str(row[1]).casefold(), row[0]))
    counts = {
        "Items": write_table(output_dir / "Items.lua", "Items", (extractor.items[key] for key in sorted(extractor.items)), ["i", "s", "i", "i", "i", "i"]),
        "Quests": write_table(output_dir / "Quests.lua", "Quests", (extractor.quests[key] for key in sorted(extractor.quests)), ["i", "s", "i", "i", "i"]),
        "Creatures": write_table(output_dir / "Creatures.lua", "Creatures", (extractor.creatures[key] for key in sorted(extractor.creatures)), ["i", "s", "i", "i", "i"]),
        "Teleports": write_table(output_dir / "Teleports.lua", "Teleports", ordered_teleports, ["i", "s", "i", "n", "n", "n"]),
    }
    write_source_info(output_dir, source_revision, counts)
    print("Generated:", ", ".join(f"{key}={value}" for key, value in counts.items()))
    print("koKR overrides:", ", ".join(f"{key}={len(value)}" for key, value in extractor.locale_updates.items()))
    return counts


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--world-zip", type=Path, required=True)
    parser.add_argument("--korean-sql", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--source-revision", default="unknown")
    parser.add_argument("--minimum-items", type=int, default=50_000)
    parser.add_argument("--minimum-quests", type=int, default=10_000)
    parser.add_argument("--minimum-creatures", type=int, default=10_000)
    parser.add_argument("--minimum-teleports", type=int, default=500)
    args = parser.parse_args()

    counts = generate(args.world_zip, args.korean_sql, args.output_dir, args.source_revision)
    minimums = {"Items": args.minimum_items, "Quests": args.minimum_quests,
        "Creatures": args.minimum_creatures, "Teleports": args.minimum_teleports}
    failed = [f"{key}={counts[key]} < {minimum}" for key, minimum in minimums.items() if counts[key] < minimum]
    if failed:
        print("Dataset completeness check failed: " + "; ".join(failed), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
