from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
addon = root / "AzerothAdmin"
toc = addon / "AzerothAdmin.toc"
errors = []

if not toc.exists():
    errors.append("Missing AzerothAdmin/AzerothAdmin.toc")
else:
    text = toc.read_text(encoding="utf-8")
    if "## Interface: 50400" not in text:
        errors.append("TOC is not Interface 50400")
    if "30300" in text:
        errors.append("WotLK Interface 30300 leaked into TOC")
    if "QuestRewards335" in text:
        errors.append("WotLK QuestRewards335 is loaded by TOC")

    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("##"):
            continue
        path = addon / line.replace("\\", "/")
        if not path.exists():
            errors.append(f"Missing TOC path: {line}")

runtime = ""
for path in addon.rglob("*"):
    if path.is_file() and path.suffix.lower() in {".lua", ".toc", ".xml"}:
        runtime += path.read_text(encoding="utf-8") + "\n"

if "Interface: 30300" in runtime:
    errors.append("Found WotLK Interface 30300 in runtime files")
if "QuestRewards335" in runtime:
    errors.append("Found QuestRewards335 runtime dependency")
if "C_Container" in runtime or "ScrollBox" in runtime or "C_Map" in runtime:
    errors.append("Found obvious Retail-era API in bootstrap runtime")

if errors:
    print("FAIL")
    for error in errors:
        print("-", error)
    sys.exit(1)

print("PASS")
