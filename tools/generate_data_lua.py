#!/usr/bin/env python3
import argparse
from pathlib import Path


def lua_quote(value: str) -> str:
    value = value.replace('\\', '\\\\').replace('"', '\\"').replace('\r', ' ').replace('\n', ' ')
    return '"' + value + '"'


def read_tsv(path):
    rows = []
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            line = line.rstrip('\n\r')
            if not line:
                continue
            rows.append(line.split('\t'))
    return rows


def write_table(path, key, rows, fields):
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    with p.open('w', encoding='utf-8', newline='\n') as f:
        f.write('AzerothAdminMoP = AzerothAdminMoP or {}\n')
        f.write('AzerothAdminMoP.Data = AzerothAdminMoP.Data or {}\n')
        f.write(f'AzerothAdminMoP.Data.{key} = {{\n')
        for row in rows:
            vals = []
            for i, kind in enumerate(fields):
                v = row[i] if i < len(row) else ''
                if kind == 'n':
                    try:
                        vals.append(str(int(float(v or 0))))
                    except ValueError:
                        vals.append('0')
                else:
                    vals.append(lua_quote(v))
            f.write('  {' + ','.join(vals) + '},\n')
        f.write('}\n')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--input-dir', required=True)
    ap.add_argument('--output-dir', required=True)
    args = ap.parse_args()
    inp = Path(args.input_dir)
    out = Path(args.output_dir)
    specs = [
        ('items.tsv', 'Items', ['n','s','n','n','n','n']),
        ('quests.tsv', 'Quests', ['n','s','n','n','n']),
        ('creatures.tsv', 'Creatures', ['n','s','n','n','n']),
        ('teleports.tsv', 'Teleports', ['n','s','n','s','s','s']),
    ]
    for filename, key, fields in specs:
        rows = read_tsv(inp / filename)
        write_table(out / (key + '.lua'), key, rows, fields)
        print(f'{key}: {len(rows)} rows')


if __name__ == '__main__':
    main()
