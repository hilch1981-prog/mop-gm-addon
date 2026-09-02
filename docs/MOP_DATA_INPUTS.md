# MoP 5.4 Additional Data Inputs

## Purpose

This document records inspected MoP-era addon data that may be used to reconstruct AzerothAdmin modules without importing WotLK-only datasets as runtime truth.

## BlueItemInfo3 5.4 fanfix3

Source archive: `BlueItemInfo3_5.4_fanfix3.zip`

- Interface: 50400
- Version: 5.4 fanfix3
- SHA-256: `212802614321d0d7d665b86a320e2ab2f2b1e0bb920ce953395a7fef64efd41b`
- Primary database files: `pve.lua`, `pvp.lua`, `faction.lua`, `scenario.lua`, `event.lua`, `gem.lua`, `archaeology.lua`, `quest.lua`, `world.lua`, `other.lua`
- Approximate item assignment entries: 10,983
- Example MoP data observed: Pandaria quest reward mappings in `db/quest.lua`

### Intended use

- `ItemBrowser`: source/category metadata and item acquisition hints
- `QuestHelper`: MoP quest-reward cross-reference only
- Search/index enrichment where the same item IDs are confirmed against the MoP server/database baseline

### Restrictions

- Do not embed the whole addon as a second UI.
- Do not treat textual source labels as server-authoritative command data.
- Validate IDs against `MOP_V2_Repack`/Chipa SQL before marking data as authoritative.

## InvenCraftInfo2 v4.0

Source archive: `InvenCraftInfo2_v4.0.zip`

- Interface: 50400
- Version: 4.0
- SHA-256: `551e6b6798f5b66403cb6580fbb4908337c972af53e56b6ba510b062b2cb824c`
- Profession DB files: 11 (`alchemy`, `blacksmithing`, `cooking`, `enchanting`, `engineering`, `firstaid`, `inscription`, `jewelcrafting`, `leatherworking`, `mining`, `tailoring`)
- Legacy MoP TradeSkill API usage observed, including `GetTradeSkillInfo`, `GetTradeSkillRecipeID`, and `GetTradeSkillReagentInfo`

### Intended use

- `ProfessionInfo`: profession/category ordering and recipe/spell ID seed data
- Item/recipe relationship reconstruction
- MoP-compatible profession browsing without importing the old standalone UI

### Restrictions

- Preserve AzerothAdmin 3.5.0 module/UI architecture.
- Import data/metadata only; do not replace the AzerothAdmin shell with InvenCraftInfo UI.
- Validate recipe and item IDs before release.

## Runtime integration order

1. Reconstruct AzerothAdmin `ItemBrowser` module shell from the 3.5.0 reference.
2. Replace WotLK item datasets with normalized MoP indexes derived from BlueItemInfo3 plus Chipa SQL.
3. Reconstruct AzerothAdmin `ProfessionInfo` module shell.
4. Seed profession categories/recipe IDs from InvenCraftInfo2 and reconcile them with MoP server/database data.
5. Add static checks that reject `QuestRewards335` runtime dependencies.
6. Perform client load and in-game browsing smoke tests before marking either module complete.
