# References

## Primary server target

- `hilch1981-prog/MOP_V2_Repack`
- branch: `repack-main`
- baseline: `0739d072f8f1f42523f04cca4b2607d88a01def4`
- command source: `src/server/scripts/Commands/`

## Porting reference

- `hilch1981-prog/azerothcore-gm-addon`
- release: `v3.5.0-335a`

WotLK 저장소는 기능/UX 계보 참고용입니다. MoP 명령/데이터의 정본이 아닙니다.

## Additional MoP 5.4 data inputs

The following user-supplied archives are accepted as MoP-era reference/input data after inspection of their TOC metadata and Lua payloads. They are not copied wholesale into runtime; each dataset is adapted into the AzerothAdmin module model and cross-checked against the server/database source of truth where applicable.

- `BlueItemInfo3_5.4_fanfix3.zip`
  - Addon: Blue Item Info 3
  - Interface: 50400
  - Version: 5.4 fanfix3
  - SHA-256: `212802614321d0d7d665b86a320e2ab2f2b1e0bb920ce953395a7fef64efd41b`
  - Relevant inputs: item acquisition categories, MoP quest reward mappings, PvE/PvP/scenario/world/faction/event item sources
  - Observed: 10 primary `db/*.lua` files and about 10,983 item assignment entries

- `InvenCraftInfo2_v4.0.zip`
  - Addon: Inven Craft Info 2
  - Interface: 50400
  - Version: 4.0
  - SHA-256: `551e6b6798f5b66403cb6580fbb4908337c972af53e56b6ba510b062b2cb824c`
  - Relevant inputs: profession category tables, recipe/spell IDs, crafting UI metadata
  - Observed: 11 profession database files and extensive 5.4-era recipe IDs

These are preferred over WotLK-only embedded datasets for MoP item/profession reconstruction. In particular, `QuestRewards335.lua` remains prohibited as a MoP runtime dependency.

## PlayerBot V2 POC

- core: `hilch1981-prog/MOP_V2_Repack`
- Draft PR: `#1`
- POC branch: `playerbot-v2-poc`
- module hub: `hilch1981-prog/mod-playerbots`
- module branch: `mop-5.4.8-v2`
- module POC pin documented in PR #1: `78bc93512f8c3b26175321e98eb0bede42917ce6`

현재 G1-B1/B2 build PASS, G1-B3 boot와 human smoke는 PENDING입니다.
