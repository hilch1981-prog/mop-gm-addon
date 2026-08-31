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
if "Generated\\SourceInfo.lua" not in text:
    errors.append("generated source provenance is not loaded by the TOC")
if "MinimapButton.lua" not in text:
    errors.append("automatic minimap button is not loaded by the TOC")
if "## Version: 1.1.1-rc1" not in text:
    errors.append("TOC release candidate version is not 1.1.1-rc1")

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
if "AAM:ShowDataBrowser" not in ui:
    errors.append("main UI does not open the SQL data browser")

browser = (ADDON / "DataBrowser.lua").read_text(encoding="utf-8")
browser_ui = (ADDON / "DataBrowserUI.lua").read_text(encoding="utf-8")
for marker in ("SearchData", ".additem ", ".quest add ", ".go creature ", ".tele "):
    if marker not in browser:
        errors.append(f"data browser behavior missing: {marker}")
for marker in ("pageOffset", "searchButton", "previous", "nextPage", "/aadb"):
    if marker not in browser_ui:
        errors.append(f"data browser UI control missing: {marker}")
for marker in ("ToggleDataFavorite", "currentFavoritesOnly", 'ShowDataBrowser(kind, favoritesOnly)'):
    if marker not in browser + browser_ui:
        errors.append(f"teleport favorite behavior missing: {marker}")

minimap = (ADDON / "MinimapButton.lua").read_text(encoding="utf-8")
for marker in (
    'CreateFrame("Button", "AzerothAdminMoPMinimapButton", UIParent)',
    'RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")',
    'eventFrame:RegisterEvent("PLAYER_LOGIN")',
    'AAM:ShowDataBrowser("Teleports", false)',
    'AAM:ShowDataBrowser("Teleports", true)',
    "AzerothAdminMoPDB.minimapX",
    "AzerothAdminMoPDB.minimapY",
    "button:Show()",
):
    if marker not in minimap:
        errors.append(f"minimap behavior missing: {marker}")
for marker in ('lower == "icon"', "ResetMinimapButton", "TogglePanel"):
    if marker not in core:
        errors.append(f"minimap slash/control behavior missing: {marker}")

minimum_rows = {"Items": 50000, "Quests": 10000, "Creatures": 10000, "Teleports": 500}
for name, minimum in minimum_rows.items():
    generated = ADDON / "Generated" / f"{name}.lua"
    if not generated.is_file():
        errors.append(f"generated dataset missing: {name}")
        continue
    with generated.open("r", encoding="utf-8") as source:
        count = sum(1 for line in source if line.startswith("  {"))
    if count < minimum:
        errors.append(f"generated dataset incomplete: {name} has {count}, expected at least {minimum}")

source_info = (ADDON / "Generated" / "SourceInfo.lua")
if not source_info.is_file():
    errors.append("generated source provenance file missing")
elif not re.search(r'revision="[0-9a-f]{40}"', source_info.read_text(encoding="utf-8")):
    errors.append("generated source revision is not a full Git commit SHA")

workflow = (ROOT / ".github" / "workflows" / "build-chipa-data.yml").read_text(encoding="utf-8")
if re.search(r"\bdocker\s+(?:run|exec)\b|mariadb:\\d", workflow, re.IGNORECASE):
    errors.append("Chipa generation workflow must not depend on MariaDB/Docker")
for marker in ("schedule:", "workflow_dispatch:", "--world-zip", "--korean-sql", "luac5.1 -p"):
    if marker not in workflow:
        errors.append(f"Chipa generation workflow marker missing: {marker}")

locales = (ADDON / "Locales.lua").read_text(encoding="utf-8")
for loc in ("enUS", "koKR", "zhCN", "zhTW", "ruRU"):
    if not re.search(rf"\b{loc}\s*=", locales):
        errors.append(f"locale missing: {loc}")

if errors:
    print("FAILED")
    for error in errors:
        print(" -", error)
    raise SystemExit(1)

print(f"PASS: {len(runtime)} runtime Lua files, complete Chipa indexes, Interface 50400, required MoP command surface present")
