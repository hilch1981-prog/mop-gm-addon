#!/usr/bin/env python3
"""Compatibility wrapper for SQLyog dumps with variable whitespace."""
from __future__ import annotations
import collections
import importlib.util
import re
from pathlib import Path

BASE = Path(__file__).with_name("extract_r5_mop_data.py")
spec = importlib.util.spec_from_file_location("r5base", BASE)
mod = importlib.util.module_from_spec(spec)
assert spec and spec.loader
spec.loader.exec_module(mod)

START = re.compile(
    r"(?:CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?|"
    r"INSERT(?:\s+IGNORE)?\s+INTO|REPLACE\s+INTO|UPDATE)"
    r"\s+`?([A-Za-z0-9_]+)`?",
    re.I,
)


def iter_statements(path: Path):
    with path.open("r", encoding="utf-8-sig", errors="replace") as fh:
        buf = []
        active = False
        quote = False
        escaped = False
        for line in fh:
            if not active:
                match = START.match(line.lstrip())
                if not match or match.group(1).lower() not in mod.TARGET_TABLES:
                    continue
                active = True
                buf = []
                quote = False
                escaped = False
            buf.append(line)
            for index, char in enumerate(line):
                if quote:
                    if escaped:
                        escaped = False
                    elif char == "\\":
                        escaped = True
                    elif char == "'":
                        # SQL doubled apostrophe stays inside the quoted value.
                        if index + 1 < len(line) and line[index + 1] == "'":
                            continue
                        quote = False
                else:
                    if char == "'":
                        quote = True
                    elif char == ";":
                        yield "".join(buf)
                        active = False
                        buf = []
                        quote = False
                        escaped = False
                        break
        if active and buf:
            yield "".join(buf)


def parse_sources(paths):
    schemas = {}
    rows = collections.defaultdict(list)
    updates = []
    stats = collections.Counter()
    for path in paths:
        for stmt in iter_statements(path):
            source = stmt.lstrip()
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
                values = mod.split_values(insert.group(3))
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


mod.iter_statements = iter_statements
mod.parse_sources = parse_sources
mod.main()
