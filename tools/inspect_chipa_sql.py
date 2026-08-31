#!/usr/bin/env python3
import re
import sys
from pathlib import Path

TARGETS = [
    "item_template",
    "item_template_locale",
    "locales_item",
    "quest_template",
    "quest_template_locale",
    "locales_quest",
    "creature_template",
    "creature_template_locale",
    "locales_creature",
    "game_tele",
]


def inspect(path):
    text = Path(path).read_text(encoding="utf-8", errors="ignore")
    print(f"== {path} ==")
    for table in TARGETS:
        m = re.search(r"CREATE TABLE\s+`?" + re.escape(table) + r"`?\s*\((.*?)\)\s*ENGINE=", text, re.S | re.I)
        if m:
            print(f"\n[{table}]\n{m.group(1)[:12000]}")
            continue
        ins = re.search(r"INSERT INTO\s+`?" + re.escape(table) + r"`?\s*(\([^;]+?\))?\s*VALUES", text, re.S | re.I)
        if ins:
            print(f"\n[{table}] INSERT columns: {ins.group(1) or '(implicit table order)'}")
        else:
            print(f"\n[{table}] NOT FOUND")


if __name__ == "__main__":
    for p in sys.argv[1:]:
        inspect(p)
