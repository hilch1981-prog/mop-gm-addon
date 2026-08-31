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
- Current candidate: `1.0.0-rc1`

## What is implemented

The addon now uses a MoP-native command catalog validated against the target repack source. The panel provides categorized administration for GM state, cheats, players, character modification, spells/skills, items, lookups, teleports, quests, NPCs and server operations. It also supports direct raw GM commands and keeps a short local command history.

Search and teleport deliberately use the server's `.lookup`, `.tele` and `.go` facilities rather than importing stale WotLK 3.3.5a IDs and coordinates. This keeps results aligned with the actual MoP world database.

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
- [x] Lua 5.1 syntax + repository static CI
- [x] WotLK-only runtime datasets excluded
- [ ] Real-client 5.4.8 game regression test
- [ ] PlayerBot controls — waiting for a confirmed PlayerBot implementation in the target repack

The codebase is therefore a **release candidate** rather than a game-certified stable release. See `COMPATIBILITY_REPORT.md` for the exact validation boundary.

## Install

Copy `AzerothAdminMoP` into:

`World of Warcraft/Interface/AddOns/`

Start the 5.4.8 client and enable **AzerothAdmin MoP** in the AddOns list.

Slash commands:

- `/aamop` — toggle the panel
- `/aamop show` — show the panel
- `/aamop hide` — hide the panel
- `/aamop reset` — reset panel position
- `/aamop help` — help
- `/mopgm <command>` — send a raw GM command

For commands requiring a parameter, type the parameter in the **Argument** field and then press the corresponding button. The tooltip shows the exact server command and expected argument.

## Compatibility policy

1. MoP client/API compatibility comes first.
2. `MOP_V2_Repack` command behavior is authoritative for server actions.
3. WotLK-only IDs, coordinates and APIs are never assumed compatible.
4. Static validation is not equivalent to an in-game client/server test.
5. PlayerBot buttons are not exposed until the target repack actually provides verified PlayerBot commands.

## Related repositories

- WotLK edition: `hilch1981-prog/azerothcore-gm-addon`
- Target repack: `hilch1981-prog/MOP_V2_Repack`

## License

GPL-3.0. See `LICENSE`.
