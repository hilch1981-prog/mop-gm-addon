#!/usr/bin/env python3
"""Preserve the MoP quest_objective.type value in generated Lua records.

The R5 generator already extracts quest objectives and verified spawn targets.
This narrow R7 post-process keeps the canonical generated format but adds the
source `type` value to every objective so the client can distinguish normal NPC
kills from NPC interaction/dialogue, gameobjects, items, pet battles, and other
MoP objective families.
"""
from __future__ import annotations

import argparse
import collections
import importlib.util
import json
import re
from pathlib import Path


def load_generator(path: Path):
    spec = importlib.util.spec_from_file_location("r5generator", path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(module)
    return module


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--generator", required=True)
    parser.add_argument("--world-sql", required=True)
    parser.add_argument("--quest-lua", required=True)
    parser.add_argument("--audit", required=True)
    args = parser.parse_args()

    generator = load_generator(Path(args.generator))
    # Reuse the SQLyog-safe parser, but scan only the one table needed here.
    generator.BASE.TARGET_TABLES.clear()
    generator.BASE.TARGET_TABLES.add("quest_objective")
    _, rows, _, stats = generator.parse_sources([Path(args.world_sql)])

    objective_types: dict[int, int] = {}
    counts = collections.Counter()
    for row in rows.get("quest_objective", []):
        objective_id = generator.BASE.to_int(generator.BASE.get(row, "id"))
        objective_type = generator.BASE.to_int(generator.BASE.get(row, "type"), -1)
        if objective_id > 0 and objective_type >= 0:
            objective_types[objective_id] = objective_type
            counts[objective_type] += 1

    quest_path = Path(args.quest_lua)
    source = quest_path.read_text(encoding="utf-8")
    replaced = 0
    missing: set[int] = set()

    def add_type(match: re.Match[str]) -> str:
        nonlocal replaced
        objective_id = int(match.group(1))
        objective_type = objective_types.get(objective_id)
        if objective_type is None:
            missing.add(objective_id)
            return match.group(0)
        replaced += 1
        return f"id={objective_id},t={objective_type}"

    # `id` is unique to the objective record in this generated schema. Target
    # records use e/g/m/x/y/z keys, so this cannot alter spawn metadata.
    patched = re.sub(r"\bid=(\d+)(?!,t=)", add_type, source)
    quest_path.write_text(patched, encoding="utf-8", newline="\n")

    audit_path = Path(args.audit)
    audit = json.loads(audit_path.read_text(encoding="utf-8"))
    audit["objective_types_preserved"] = replaced
    audit["objective_type_counts"] = {str(key): counts[key] for key in sorted(counts)}
    audit["objective_type_missing_ids"] = sorted(missing)[:50]
    audit_path.write_text(json.dumps(audit, ensure_ascii=False, indent=2), encoding="utf-8")

    expected = int(audit.get("objective_slots", 0))
    if expected <= 0 or replaced != expected:
        raise SystemExit(
            f"objective type preservation mismatch: replaced={replaced}, expected={expected}, missing={len(missing)}"
        )
    if counts[3] <= 0:
        raise SystemExit("no NPC_INTERACT objective rows were found")

    print(
        json.dumps(
            {
                "quest_objective_rows": int(stats.get("quest_objective", 0)),
                "objective_types_preserved": replaced,
                "npc_interact": counts[3],
                "pet_battle_tamer": counts[11],
                "missing_ids": len(missing),
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
