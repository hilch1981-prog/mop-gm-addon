# AzerothAdmin MoP

GM administration addon for **World of Warcraft: Mists of Pandaria 5.4.8 (Build 18414 / Interface 50400)**.

This repository is the MoP-specific successor to `hilch1981-prog/azerothcore-gm-addon` and is intentionally maintained separately from the WotLK 3.3.5a edition.

## Target environment

- Client: WoW MoP 5.4.8
- Build: 18414
- Interface: 50400
- Primary repack: `hilch1981-prog/MOP_V2_Repack`
- Repack base: `alexkulya/pandaria_5.4.8`
- Addon author/maintainer: 취미연구가 (Hobbyist)
- Current candidate: `1.1.1-rc1`

## Project workflow

Before changing source or server commands, read:

1. `AGENTS.md`
2. `PROJECT_STATUS.md`
3. `TASKS.md`
4. `DEVELOPMENT_RULES.md`
5. `PLAYERBOT_COMMAND_AUDIT.md` for PlayerBot-related work
6. `CHATGPT_PROJECT_INSTRUCTIONS.md` when using this repository as a ChatGPT project

The WotLK `azerothcore-gm-addon` repository is a UI/UX and collaboration reference. MoP server commands, IDs, coordinates and runtime behavior must be verified against `MOP_V2_Repack` instead of copied from WotLK.

## What is implemented

The addon uses a MoP-native command catalog validated against the target repack source. The panel provides categorized administration for GM state, cheats, players, character modification, spells/skills, items, lookups, teleports, quests, NPCs and server operations. It also supports direct raw GM commands and keeps a short local command history.

The built-in **MoP SQL Data** browser is generated from the target repack's `world_04_03_2023.zip` and Korean integrated patch. It provides searchable item, quest, creature, and `game_tele` indexes with koKR names preferred when available. Selecting a result sends the matching `.additem`, `.quest add`, `.go creature`, or `.tele` command.

The ordinary Lookup panel remains server-driven through `.lookup`, `.tele`, and `.go`, while the generated browser offers fast offline discovery without importing any WotLK 3.3.5a IDs or coordinates.

The minimap button is created automatically at login, matching the established AzerothAdmin behavior. Left click toggles the GM panel, right click opens teleports, middle click opens favorite teleports, and dragging the button saves its position.

## Migration status

- [x] Dedicated MoP repository
- [x] 5.4.8 / Build 18414 / Interface 50400 metadata
- [x] Target `MOP_V2_Repack` source audit
- [x] MoP command runner
- [x] Categorized GM panel
- [x] GM / cheats / player / modify / spell / item / lookup / teleport / quest / NPC / server command groups
- [x] Server-driven MoP item/NPC/quest/spell/teleport search
- [x] MoP profession/skill command coverage through `.learn`, `.setskill`, `.maxskill`
- [x] enUS / koKR / zhCN / zhTW / ruRU UI foundation
- [x] Saved panel position and local command history
- [x] Automatic minimap button with saved position and teleport favorites
- [x] Lua 5.1 syntax + repository static CI
- [x] WotLK-only runtime datasets excluded
- [x] Complete Chipa SQL item/quest/creature/teleport browser
- [x] koKR locale overlay from the integrated Korean patch
- [x] MariaDB-free, reproducible SQL-to-Lua generation pipeline
- [x] MoP-specific AI/project instructions modeled after the WotLK project workflow
- [x] PlayerBot donor command audit and pre-G3 UI exposure guard
- [ ] Real-client 5.4.8 game regression test
- [ ] PlayerBot controls — blocked until the Chipa `playerbot-v2-poc` runtime reaches a verified SelfBot command surface

The codebase is therefore a **release candidate** rather than a game-certified stable release. See `COMPATIBILITY_REPORT.md` for the exact validation boundary.

## PlayerBot V2 status

PlayerBot development is now tracked in `hilch1981-prog/MOP_V2_Repack` on the `playerbot-v2-poc` branch. The POC is intentionally staged from generic module infrastructure toward SelfBot and MoP rotation gates.

The addon does **not** assume that the historical Legends PR #389 `.npcbot` command or the commonly documented `.playerbot` prefix is valid for Chipa. The actual Chipa command handler, permissions and arguments must be verified first. See `PLAYERBOT_COMMAND_AUDIT.md`.

Until that gate is reached, `.playerbot` and `.npcbot` entries are intentionally rejected by the static validator so donor/guessed commands cannot silently appear in the GM panel.

## Install

Copy `AzerothAdminMoP` into:

`World of Warcraft/Interface/AddOns/`

Start the 5.4.8 client and enable **AzerothAdmin MoP** in the AddOns list.

Slash commands:

- `/aamop` — toggle the panel
- `/aamop show` — show the panel
- `/aamop hide` — hide the panel
- `/aamop icon` — show or hide the minimap button for the current session
- `/aamop reset` — reset the panel and minimap button positions and show the button
- `/aamop help` — help
- `/mopgm <command>` — send a raw GM command
- `/aadb` — toggle the generated Chipa SQL data browser

For commands requiring a parameter, type the parameter in the **Argument** field and then press the corresponding button. The tooltip shows the exact server command and expected argument.

The main panel's **MoP SQL 데이터** button opens the generated data browser. Enter a Korean/English name or exact ID, press **검색**, move through results with **이전/다음**, and click a result to run its GM action.

## Rebuilding the SQL browser

`Build Chipa SQL Data` runs every Monday, can be started manually, and also runs when its extractor changes. It resolves the current `MOP_V2_Repack/repack-main` commit, downloads both SQL sources at that exact SHA, streams only the required tables without MariaDB or Docker, validates minimum row counts and Lua 5.1 syntax, and commits changed files under `AzerothAdminMoP/Generated`.

For a local rebuild:

```powershell
python tools/generate_data_lua.py `
  --world-zip world_04_03_2023.zip `
  --korean-sql 판다리아_5.4.8_한글_통합패치.sql `
  --output-dir AzerothAdminMoP/Generated `
  --source-revision <MOP_V2_Repack commit SHA>
```

## Compatibility policy

1. MoP client/API compatibility comes first.
2. `MOP_V2_Repack` command behavior is authoritative for server actions.
3. WotLK-only IDs, coordinates and APIs are never assumed compatible.
4. Static validation is not equivalent to an in-game client/server test.
5. PlayerBot buttons are not exposed until the target Chipa runtime provides a verified command handler and the SelfBot UI gate is reached.
6. External donor command names are never treated as Chipa commands without source verification.

## Related repositories

- WotLK edition/reference workflow: `hilch1981-prog/azerothcore-gm-addon`
- Target repack/runtime: `hilch1981-prog/MOP_V2_Repack`
- PlayerBot module development: `hilch1981-prog/mod-playerbots`

## License

GPL-3.0. See `LICENSE`.
