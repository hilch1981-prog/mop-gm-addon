#!/usr/bin/env python3
"""Run the source-pinned MoP extractor while preserving objective types.

The R5 extractor is intentionally kept stable. R7 applies one narrow generator
patch: every quest_objective record retains its authoritative `type` value so
the addon can distinguish NPC kill, item, gameobject, NPC interaction/dialogue,
and other MoP objective families without changing the canonical quest UI.
"""
from __future__ import annotations

import collections
import json
import re
import runpy
from pathlib import Path


SOURCE = Path(__file__).with_name("extract_r5_mop_data_v3.py")
RUNTIME = Path(__file__).with_name("_extract_r7_runtime.py")

NEEDLE = '''            objective = {
                "s": slot,
                "c": amount,
                "id": objective_id,
                "d": description,
            }
'''
REPLACEMENT = '''            objective = {
                "s": slot,
                "c": amount,
                "id": objective_id,
                "t": objective_type,
                "d": description,
            }
'''


def main() -> int:
    source = SOURCE.read_text(encoding="utf-8")
    occurrences = source.count(NEEDLE)
    if occurrences != 1:
        raise SystemExit(f"R7 generator patch expected one objective block, found {occurrences}")

    RUNTIME.write_text(source.replace(NEEDLE, REPLACEMENT, 1), encoding="utf-8", newline="\n")
    try:
        runpy.run_path(str(RUNTIME), run_name="__main__")
    finally:
        RUNTIME.unlink(missing_ok=True)

    # The wrapped generator accepts --out. Read it from argv without taking over
    # argparse so all original options and error behavior remain unchanged.
    import sys

    try:
        output_dir = Path(sys.argv[sys.argv.index("--out") + 1])
    except (ValueError, IndexError):
        raise SystemExit("--out is required")

    quest_path = output_dir / "QuestLocations.lua"
    audit_path = output_dir / "audit.json"
    quest_source = quest_path.read_text(encoding="utf-8")
    type_values = [int(value) for value in re.findall(r"\bid=\d+,t=(\d+)", quest_source)]
    counts = collections.Counter(type_values)
    audit = json.loads(audit_path.read_text(encoding="utf-8"))
    audit["objective_types_preserved"] = len(type_values)
    audit["objective_type_counts"] = {str(key): counts[key] for key in sorted(counts)}
    audit_path.write_text(json.dumps(audit, ensure_ascii=False, indent=2), encoding="utf-8")

    expected = int(audit.get("objective_slots", 0))
    if expected <= 0 or len(type_values) != expected:
        raise SystemExit(
            f"objective type preservation mismatch: preserved={len(type_values)}, expected={expected}"
        )
    if counts[3] <= 0:
        raise SystemExit("no NPC_INTERACT objective rows were preserved")

    print(
        json.dumps(
            {
                "objective_types_preserved": len(type_values),
                "npc_interact": counts[3],
                "pet_battle_tamer": counts[11],
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
