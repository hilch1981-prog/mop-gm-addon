#!/usr/bin/env python3
"""Guard against accidental MoP product/UI/module shrinkage.

Usage:
  python tools/verify_baseline_contract.py <azerothadmin_dir> <mop_dir>

This is intentionally conservative. It checks that the MoP port retains the
canonical module/UI inventory by filename/stem patterns while allowing known
version-specific filenames. It is a guardrail, not an in-game test.
"""
from __future__ import annotations
import pathlib
import re
import sys

IGNORE_NAMES = {
    '.gitignore', 'README.md', 'CHANGELOG.md',
}
IGNORE_DIRS = {'.git', '.github', 'tests', 'tools', '__pycache__'}
DATAISH = re.compile(r'(data|generated|locale|locales|db|database)', re.I)
UIISH = re.compile(r'(ui|frame|window|panel|browser|shell|minimap|tab)', re.I)


def files(root: pathlib.Path):
    out = []
    for p in root.rglob('*'):
        if not p.is_file():
            continue
        rel = p.relative_to(root)
        if any(part in IGNORE_DIRS for part in rel.parts):
            continue
        if p.name in IGNORE_NAMES:
            continue
        out.append(rel)
    return out


def norm(rel: pathlib.Path) -> str:
    s = str(rel).replace('\\', '/').lower()
    s = s.replace('azerothadminmop', 'azerothadmin')
    s = re.sub(r'(?<!\d)50400(?!\d)|(?<!\d)30300(?!\d)', '<iface>', s)
    s = re.sub(r'(?<!\d)5\.4\.8(?!\d)|(?<!\d)3\.3\.5a?(?!\d)', '<client>', s)
    return s


def stem_tokens(rel: pathlib.Path):
    n = norm(rel)
    base = pathlib.PurePosixPath(n).stem
    toks = [t for t in re.split(r'[^a-z0-9]+', base) if t and t not in {'mop','wotlk','335a','548'}]
    return set(toks)


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__.strip())
        return 2
    base = pathlib.Path(sys.argv[1])
    mop = pathlib.Path(sys.argv[2])
    if not base.is_dir() or not mop.is_dir():
        print('ERROR: both arguments must be directories')
        return 2

    bfiles = files(base)
    mfiles = files(mop)
    mn = {norm(p): p for p in mfiles}

    missing_exact = []
    missing_ui = []
    for b in bfiles:
        nb = norm(b)
        if nb in mn:
            continue
        bt = stem_tokens(b)
        candidates = [m for m in mfiles if bt and len(bt & stem_tokens(m)) >= max(1, len(bt)//2)]
        if UIISH.search(str(b)) and not candidates:
            missing_ui.append(str(b))
        elif not DATAISH.search(str(b)) and not candidates:
            missing_exact.append(str(b))

    print(f'Canonical files: {len(bfiles)}')
    print(f'MoP files:       {len(mfiles)}')
    print(f'Potential missing UI/product modules: {len(missing_ui)}')
    for x in missing_ui:
        print('  UI-MISSING:', x)
    print(f'Potential missing non-data modules: {len(missing_exact)}')
    for x in missing_exact:
        print('  MOD-MISSING:', x)

    if missing_ui:
        print('FAIL: MoP port appears to have lost canonical UI/product modules.')
        return 1
    print('PASS: no obvious canonical UI/product module shrinkage detected.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
