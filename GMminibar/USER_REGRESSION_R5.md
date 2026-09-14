# R5 user game-test regression

Version: `3.5.0-548-r5-quest-tele-perf-rc5`

Based on the user's R4 MoP 5.4.8 in-game report.

- Quest start/end navigation now uses pinned server relation and spawn tables.
- Quest objective navigation uses Pandaria `quest_objective`, creature/object spawns, and loot sources.
- Teleport display metadata covers all 1,602 `game_tele` rows with Korean labels, region grouping, and recommended level text.
- GM power wording is changed to `마나/기력 등 무제한`.
- Profession switching uses lazy spell resolution and per-profession caches.

Source authority: `hilch1981-prog/MOP_V2_Repack@0739d072f8f1f42523f04cca4b2607d88a01def4`.
Canonical UI authority: `AzerothAdmin_3.5.0-335a.zip`.
