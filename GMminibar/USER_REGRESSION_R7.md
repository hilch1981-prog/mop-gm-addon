# R7 in-game feedback regression ledger

Source authorities:

- UI/layout: uploaded `AzerothAdmin_3.5.0-335a.zip`
- Server commands/data: `hilch1981-prog/MOP_V2_Repack@0739d072f8f1f42523f04cca4b2607d88a01def4`
- Client: WoW MoP 5.4.8 build 18414 / Interface 50400

## Fixed in R7

1. Quest objective `Find` uses localized names because this MoP core's `.lookup creature`, `.lookup object`, and `.lookup item` handlers search names rather than numeric template IDs. Names are sent as plain remaining command text, without quote characters, because the server lookup handler does not strip quotes.
2. Quest-log entries with zero leaderboard objectives now display a synthetic `Dialogue` row using the verified quest end NPC/object relation. Movement uses the existing coordinate/GUID navigation path.
3. Quest list and objective child widgets forward mouse-wheel paging so the lower pane no longer makes other quest pages appear inaccessible.
4. Teleports sort by continent, zone/city, faction, recommended level, destination, and ID. Rows explicitly show faction and right-click favorites.
5. `My faction/current level` filters opposite-faction destinations and entries outside the character's recommended level band.
6. Profession recipes decode InvenCraftInfo2 `requireCode`, display skill tier/required skill/spell ID, and disable Learn unless the profession is known and current skill satisfies the requirement.
7. Profession recipe tiers: Apprentice, Journeyman, Expert, Artisan, Master, Grand Master, Illustrious, Zen Master.
8. Item type, quality, and class controls rebuild the result list immediately; Artifact quality is included. Item, recipe-output, reagent, and creature right-click server lookups now send localized names rather than numeric IDs.

## Deliberately retained

- A small number of source `game_tele` rows may still have generic display labels when neither the pinned DB nor the canonical localization has a reliable Korean place name. The exact raw `.tele` command name remains preserved for dispatch.
- Script-spawned quest targets without an active world spawn are not assigned invented coordinates.

## Required real-client checks

- Quest 28168: lower pane shows a Dialogue row and its Move button reaches the end NPC.
- Quest 31870: Find searches `카산드라 카붐` by name, and Move uses the verified target route when a spawn exists.
- Horde character: `My faction/current level` hides Alliance-only capitals; Alliance character does the inverse.
- First Aid not learned: high-level bandage Learn button is disabled with a reason tooltip.
- Mining 115: Smelt Gold is enabled; lower skill remains disabled.
- Item type/quality checkbox changes update results without requiring a second Apply click.
