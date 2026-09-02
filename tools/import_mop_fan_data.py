import argparse
import json
import re
import zipfile
from pathlib import Path

BLUE_ASSIGN = re.compile(r'item\[(\d+)\]\s*=\s*"([^"]*)"')
BLUE_ALIAS = re.compile(r'item\[(\d+)\]\s*=\s*item\[(\d+)\]')
CRAFT_FILE = re.compile(r'InvenCraftInfo2_UI/db/([a-z]+)\.lua$', re.I)
CRAFT_ID = re.compile(r'InvenCraftInfo2\.tradeSkillData\[(\d+)\]')


def parse_blue(path: Path):
    values, aliases = {}, {}
    with zipfile.ZipFile(path) as zf:
        for name in zf.namelist():
            if '/db/' not in name.lower() or not name.lower().endswith('.lua'):
                continue
            text = zf.read(name).decode('utf-8-sig', errors='replace')
            for item_id, source in BLUE_ASSIGN.findall(text):
                values[int(item_id)] = source
            for item_id, target in BLUE_ALIAS.findall(text):
                aliases[int(item_id)] = int(target)
    for item_id, target in aliases.items():
        seen = set()
        while target in aliases and target not in seen:
            seen.add(target)
            target = aliases[target]
        if target in values:
            values[item_id] = values[target]
    return values


def parse_craft(path: Path):
    professions = {}
    with zipfile.ZipFile(path) as zf:
        for name in zf.namelist():
            if not CRAFT_FILE.search(name):
                continue
            text = zf.read(name).decode('utf-8-sig', errors='replace')
            match = CRAFT_ID.search(text)
            if not match:
                continue
            profession_id = int(match.group(1))
            categories = len(re.findall(r'\b(?:list|header)\s*=', text))
            spells = len(re.findall(r'(?<![\w.])\d{3,6}(?![\w.])', text))
            professions[profession_id] = {'file': name, 'categories_or_headers': categories, 'numeric_tokens': spells}
    return professions


def main():
    parser = argparse.ArgumentParser(description='Validate user-supplied MoP fan data archives.')
    parser.add_argument('--blue', type=Path, required=True)
    parser.add_argument('--craft', type=Path, required=True)
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    items = parse_blue(args.blue)
    professions = parse_craft(args.craft)
    report = {
        'blue_item_sources': len(items),
        'profession_count': len(professions),
        'profession_ids': sorted(professions),
        'professions': professions,
    }
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(report, ensure_ascii=False, sort_keys=True))


if __name__ == '__main__':
    main()
