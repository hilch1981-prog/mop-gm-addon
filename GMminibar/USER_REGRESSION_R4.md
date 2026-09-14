# AzerothAdmin MoP R4 bootstrap and user regression ledger

Version: `3.5.0-548-r4-bootstrap-rc4`

Canonical UI source: `AzerothAdmin_3.5.0-335a.zip`

## Direct startup regression

- MOP-R018: `Modules/Shell/UI.lua:145: attempt to index upvalue UI (a nil value)` must not recur.
- Bootstrap creates `AzerothAdminMoP548.UI` before every other runtime file.
- Shell/UI contains a complete canonical UI fallback and does not require a prior UIComponents side effect.
- Toolbar and minimap launchers are created independently from the main command window.
- `/aamop`, `/aamop test`, and `/aamop repair` initialize safely and never index a missing main frame.
- Schema 5 resets hidden/off-screen launcher state inherited from failed RC installs.
- Startup is exercised through the real `PLAYER_LOGIN` event route and a second idempotent retry.
- Generic legacy global replacement is fault-injected during the mock test; the stable namespace remains intact.

## Previous user regressions retained

- MOP-R007: Item toolbar/title icon uses the canonical BlueItemInfo3 icon.
- MOP-R008: Temporary/deprecated/unused placeholder rows are excluded.
- MOP-R009: User-supplied Hobbyist creator icon is used in the header and minimap.
- MOP-R010: Profession recipe icons, output items, tools, and offline reagents are displayed.
- MOP-R011: Known recipes use blue text without embedded color-code disappearance.
- MOP-R012: Collapsed quest headers are expanded and active quest-log events are synchronized.
- MOP-R013: Teleport title is generic and the full 1,602-entry game_tele catalog is the default.
- MOP-R014: Commands use self-whisper transport while dead; revive retries safely.
- MOP-R015: Toolbar language cycle is AUTO → koKR → enUS → zhCN → ruRU.
- MOP-R016: Minimap creator icon uses a ring and cache-busted texture paths.
- MOP-R017: Canonical AzerothAdmin item categories (252 entries / 16,166 verified IDs) are restored.

Static, Lua-parser, and WoW-API mock verification are not a substitute for the required MoP 5.4.8 in-game smoke test.
