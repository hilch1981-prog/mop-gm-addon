import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "AzerothAdmin"
TOC = ADDON / "AzerothAdmin.toc"


class MoPFullPortTests(unittest.TestCase):
    def test_toc_is_mop_and_every_runtime_path_exists(self):
        text = TOC.read_text(encoding="utf-8")
        self.assertIn("## Interface: 50400", text)
        self.assertNotIn("30300", text)
        self.assertNotIn("QuestRewards335", text)
        for raw in text.splitlines():
            line = raw.strip()
            if not line or line.startswith("##"):
                continue
            self.assertTrue((ADDON / line.replace("\\", "/")).exists(), line)

    def test_full_module_surface_is_loaded(self):
        text = TOC.read_text(encoding="utf-8")
        required = [
            "Modules\\Language\\Module.lua", "Modules\\Commands\\Module.lua",
            "Modules\\Teleports\\Module.lua", "Modules\\Search\\Module.lua",
            "Modules\\Creatures\\Module.lua", "Modules\\ItemBrowser\\Module.lua",
            "Modules\\QuestHelper\\Module.lua", "Modules\\ProfessionInfo\\Module.lua",
            "Modules\\Bank\\Module.lua", "Modules\\Revive\\Module.lua",
            "Modules\\PlayerBot\\Module.lua", "Modules\\Integrations\\Module.lua",
        ]
        for path in required:
            self.assertIn(path, text)

    def test_chipa_sql_generated_counts_are_pinned(self):
        source = (ADDON / "Data/Generated/SourceInfo.lua").read_text(encoding="utf-8")
        self.assertIn('revision="0739d072f8f1f42523f04cca4b2607d88a01def4"', source)
        for expected in ("Items=80072", "Quests=18144", "Creatures=57526", "Teleports=1602"):
            self.assertIn(expected, source)

    def test_all_11_mop_professions_are_loaded(self):
        text = TOC.read_text(encoding="utf-8")
        ids = {129, 164, 165, 171, 185, 186, 197, 202, 333, 755, 773}
        loaded = set()
        for path in (ADDON / "Data/Professions").glob("*.lua"):
            match = re.search(r"MoPProfessionIndex\[(\d+)\]", path.read_text(encoding="utf-8"))
            if match:
                loaded.add(int(match.group(1)))
            self.assertIn("Data\\Professions\\" + path.name, text)
        self.assertEqual(ids, loaded)

    def test_gm_level_6_and_quest_admin_boundary(self):
        registry = (ADDON / "Framework/CommandRegistry.lua").read_text(encoding="utf-8")
        meta = (ADDON / "Modules/Commands/CommandMeta.lua").read_text(encoding="utf-8")
        self.assertRegex(registry, r"GAMEMASTER\s*=\s*6")
        self.assertRegex(registry, r"ADMINISTRATOR\s*=\s*8")
        self.assertIn('C("gm_on", ".gm on", S.GAMEMASTER', meta)
        self.assertIn('C("quest_add", ".quest add", S.ADMINISTRATOR', meta)
        self.assertIn('C("bank", ".bank", S.MODERATOR', meta)
        self.assertNotIn(".character check bank", meta)

    def test_verified_gm6_misc_commands_are_registered(self):
        meta = (ADDON / "Modules/Commands/CommandMeta.lua").read_text(encoding="utf-8")
        for command in (".additem", ".revive", ".respawn", ".repairitems", ".gps", ".recall", ".appear", ".summon"):
            self.assertIn(command, meta)

    def test_no_obvious_retail_or_wotlk_runtime_leaks(self):
        runtime = "\n".join(
            p.read_text(encoding="utf-8")
            for p in ADDON.rglob("*")
            if p.is_file() and p.suffix.lower() in {".lua", ".toc", ".xml"}
        )
        self.assertNotIn("Interface: 30300", runtime)
        self.assertNotIn("QuestRewards335", runtime)
        for symbol in ("C_Container", "ScrollBox", "C_Map"):
            self.assertNotIn(symbol, runtime)

    def test_playerbot_remains_blocked(self):
        text = (ADDON / "Modules/PlayerBot/Module.lua").read_text(encoding="utf-8")
        meta = (ADDON / "Modules/Commands/CommandMeta.lua").read_text(encoding="utf-8")
        self.assertIn("blocked = true", meta)
        self.assertNotRegex(text, r"SendCommand\([^\n]*playerbot")


if __name__ == "__main__":
    unittest.main()
