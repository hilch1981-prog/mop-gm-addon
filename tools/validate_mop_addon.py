from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "AzerothAdminMoP"
TOC = ADDON / "AzerothAdminMoP.toc"

errors = []
text = TOC.read_text(encoding="utf-8")

if "## Interface: 50400" not in text:
    errors.append("TOC Interface must be 50400")
if "## X-Client: WoW 5.4.8 (18414)" not in text:
    errors.append("TOC client/build metadata missing")
if "30300" in text or "3.3.5a" in text:
    errors.append("WotLK metadata leaked into MoP TOC")

runtime = []
for line in text.splitlines():
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    if line.lower().endswith(".lua"):
        runtime.append(line.replace("\\", "/"))

for rel in runtime:
    if not (ADDON / rel).is_file():
        errors.append(f"TOC runtime file missing: {rel}")

commands = (ADDON / "Commands.lua").read_text(encoding="utf-8")
required = [
    ".gm on", ".gm fly on", ".cheat god on", ".bank", ".revive", ".gps",
    ".lookup item %s", ".lookup creature %s", ".lookup quest %s", ".lookup tele %s",
    ".tele %s", ".go creature %s", ".additem %s", ".quest complete %s",
    ".learn all my class", ".npc info", ".modify speed fly %s",
]
for command in required:
    if command not in commands:
        errors.append(f"required command missing: {command}")

core = (ADDON / "Core.lua").read_text(encoding="utf-8")
if 'SendChatMessage(command, "SAY")' not in core:
    errors.append("GM command sender is missing")
if "SLASH_AZEROTHADMINMOP1" not in core:
    errors.append("slash command is missing")

ui = (ADDON / "UI.lua").read_text(encoding="utf-8")
if "AzerothAdminMoPFrame" not in ui or "UIPanelButtonTemplate" not in ui:
    errors.append("main UI frame/buttons missing")

locales = (ADDON / "Locales.lua").read_text(encoding="utf-8")
for loc in ("enUS", "koKR", "zhCN", "zhTW", "ruRU"):
    if not re.search(rf"\b{loc}\s*=", locales):
        errors.append(f"locale missing: {loc}")

if errors:
    print("FAILED")
    for error in errors:
        print(" -", error)
    raise SystemExit(1)

print(f"PASS: {len(runtime)} runtime Lua files, Interface 50400, required MoP command surface present")
