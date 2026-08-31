from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "AzerothAdminMoP"


class MinimapButtonTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.toc = (ADDON / "AzerothAdminMoP.toc").read_text(encoding="utf-8")
        cls.core = (ADDON / "Core.lua").read_text(encoding="utf-8")
        cls.minimap = (ADDON / "MinimapButton.lua").read_text(encoding="utf-8")
        cls.browser = (ADDON / "DataBrowser.lua").read_text(encoding="utf-8")
        cls.browser_ui = (ADDON / "DataBrowserUI.lua").read_text(encoding="utf-8")

    def test_minimap_button_is_loaded_after_ui(self):
        self.assertIn("MinimapButton.lua", self.toc)
        self.assertLess(self.toc.index("DataBrowserUI.lua"), self.toc.index("MinimapButton.lua"))

    def test_button_is_created_and_shown_automatically(self):
        self.assertIn('eventFrame:RegisterEvent("PLAYER_LOGIN")', self.minimap)
        self.assertIn("AAM:CreateMinimapButton()", self.minimap)
        self.assertIn("button:Show()", self.minimap)

    def test_original_click_rules_are_preserved(self):
        self.assertIn('RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")', self.minimap)
        self.assertIn("AAM:TogglePanel()", self.minimap)
        self.assertIn('AAM:ShowDataBrowser("Teleports", false)', self.minimap)
        self.assertIn('AAM:ShowDataBrowser("Teleports", true)', self.minimap)

    def test_drag_position_and_reset_are_persistent(self):
        self.assertIn("AzerothAdminMoPDB.minimapX = x", self.minimap)
        self.assertIn("AzerothAdminMoPDB.minimapY = y", self.minimap)
        self.assertIn("function AAM:ResetMinimapButton()", self.minimap)
        self.assertIn('lower == "reset" or lower == "resetui"', self.core)

    def test_icon_toggle_and_teleport_favorites_are_available(self):
        self.assertIn('lower == "icon"', self.core)
        self.assertIn("function AAM:ToggleDataFavorite", self.browser)
        self.assertIn("currentFavoritesOnly", self.browser_ui)


if __name__ == "__main__":
    unittest.main()
