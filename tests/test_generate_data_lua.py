import io
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from generate_data_lua import ChipaExtractor, ValuesParser, scan_sql  # noqa: E402


class ValuesParserTests(unittest.TestCase):
    def test_mysql_literals_across_chunks(self):
        rows = []
        parser = ValuesParser(rows.append)
        self.assertFalse(parser.feed("(1,'귀환"))
        self.assertFalse(parser.feed("석','it\\'s',NULL),"))
        self.assertTrue(parser.feed("(2,'line\\nnext','a,b',3);"))
        self.assertEqual(rows, [["1", "귀환석", "it's", None], ["2", "line\nnext", "a,b", "3"]])


class StreamExtractionTests(unittest.TestCase):
    def test_base_rows_and_korean_overrides(self):
        base = """
insert into `item_template`(`entry`,`class`,`name`,`Quality`,`ItemLevel`,`RequiredLevel`) values
(6948,15,'Hearthstone',1,1,0);
insert into `quest_template`(`Id`,`Level`,`MinLevel`,`ZoneOrSort`,`Title`) values
(7,2,1,9,'Kobold Camp Cleanup');
insert into `creature_template`(`entry`,`name`,`minlevel`,`maxlevel`,`rank`) values
(30,'Forest Spider',5,6,0);
insert into `game_tele`(`id`,`position_x`,`position_y`,`position_z`,`orientation`,`map`,`name`) values
(1,1.25,2.5,3.75,0,870,'Pandaria');
"""
        korean = """
REPLACE INTO `item_template_locale` VALUES (6948,'koKR','귀환석','',18414);
UPDATE `locales_quest` SET `Title_loc1` = '코볼트 소탕' WHERE `Id` = '7';
UPDATE `locales_creature` SET `name_loc1` = '숲거미' WHERE `entry` = '30';
"""
        extractor = ChipaExtractor()
        scan_sql(io.StringIO(base), extractor, "base")
        scan_sql(io.StringIO(korean), extractor, "korean")
        self.assertEqual(extractor.items[6948][1], "귀환석")
        self.assertEqual(extractor.quests[7][1], "코볼트 소탕")
        self.assertEqual(extractor.creatures[30][1], "숲거미")
        self.assertEqual(extractor.teleports[1], [1, "Pandaria", 870, "1.25", "2.5", "3.75"])


if __name__ == "__main__":
    unittest.main()
