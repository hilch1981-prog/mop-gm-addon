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

## Goal

Port the released AzerothAdmin 3.3.5a functionality to MoP while preserving the modular architecture and multilingual UI, but replacing client APIs, command metadata, search data and server-specific behavior that are not valid on MoP.

## Important compatibility rule

The 3.3.5a addon is a **feature/reference baseline only**. Files are not copied blindly. Every module must pass a MoP compatibility review before being enabled.

## Migration status

- [x] Dedicated MoP repository created
- [x] Target client/build/interface fixed to 5.4.8 / 18414 / 50400
- [x] Primary repack fixed to MOP_V2_Repack
- [x] Initial loadable addon skeleton
- [x] Base command sender and simple GM panel
- [ ] Command-by-command validation against MOP_V2_Repack
- [ ] Teleport data migration for MoP zones/raids
- [ ] Item/NPC/search data migration to MoP IDs
- [ ] Profession integration migration
- [ ] PlayerBot integration validation
- [ ] Full koKR/enUS/zhCN/zhTW/ruRU localization parity
- [ ] In-game regression test on Chipa MOP V2 repack
- [ ] First stable release

## Install

Copy `AzerothAdminMoP` into:

`World of Warcraft/Interface/AddOns/`

Then start the 5.4.8 client and enable **AzerothAdmin MoP** in the AddOns list.

Slash commands:

- `/aamop` - toggle the GM panel
- `/aamop show` - show the panel
- `/aamop hide` - hide the panel
- `/aamop reset` - reset panel position
- `/aamop help` - show help

## Development policy

1. MoP client/API compatibility first.
2. MOP_V2_Repack command behavior is authoritative for server actions.
3. WotLK-only data and APIs must not be treated as MoP-compatible without verification.
4. Static validation is not equivalent to in-game validation.
5. A stable release is created only after game testing on the target repack.

## Related repositories

- WotLK edition: `hilch1981-prog/azerothcore-gm-addon`
- Target repack: `hilch1981-prog/MOP_V2_Repack`

## License

GPL-3.0. See `LICENSE`.
