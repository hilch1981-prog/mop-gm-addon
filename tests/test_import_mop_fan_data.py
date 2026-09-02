import tempfile
import unittest
import zipfile
from pathlib import Path

from tools.import_mop_fan_data import parse_blue, parse_craft


class FanDataImporterTests(unittest.TestCase):
    def test_blue_aliases_are_resolved(self):
        with tempfile.TemporaryDirectory() as tmp:
            archive = Path(tmp) / "blue.zip"
            with zipfile.ZipFile(archive, "w") as zf:
                zf.writestr("BlueItemInfo3/db/quest.lua", 'item[100] = "Quest_A"\nitem[101] = item[100]\n')
            data = parse_blue(archive)
            self.assertEqual("Quest_A", data[100])
            self.assertEqual("Quest_A", data[101])

    def test_craft_profession_ids_are_detected(self):
        with tempfile.TemporaryDirectory() as tmp:
            archive = Path(tmp) / "craft.zip"
            with zipfile.ZipFile(archive, "w") as zf:
                zf.writestr(
                    "InvenCraftInfo2_UI/db/alchemy.lua",
                    'InvenCraftInfo2.tradeSkillData[171] = { { list = { 114780, 114781 }, name = "x" } }',
                )
            data = parse_craft(archive)
            self.assertIn(171, data)
            self.assertGreaterEqual(data[171]["numeric_tokens"], 3)


if __name__ == "__main__":
    unittest.main()
