# MOP_V2_Repack Compatibility Report

Target: WoW Mists of Pandaria 5.4.8, Build 18414, Interface 50400.
Primary server: `hilch1981-prog/MOP_V2_Repack` branch `repack-main`.

## Source audit

The addon command surface was rebuilt from the target repack command scripts rather than copied from the WotLK AzerothCore addon.

Verified command families:

- `cs_gm.cpp`: `.gm`, `.gm chat`, `.gm fly`, `.gm ingame`, `.gm list`, `.gm visible`
- `cs_cheat.cpp`: `.cheat god`, `casttime`, `cooldown`, `power`, `waterwalk`, `status`, `taxi`, `explore`
- `cs_misc.cpp`: `.additem`, `.bank`, `.combatstop`, `.cooldown`, `.die`, `.gps`, `.maxskill`, `.recall`, `.repairitems`, `.respawn`, `.revive`, `.save`, `.saveall`, `.setskill`, `.summon`, `.unaura`, and related commands
- `cs_lookup.cpp`: area, creature, event, faction, item, itemset, object, quest, player, skill, spell, taxinode, tele, title, map lookups
- `cs_tele.cpp`: `.tele`, `.tele add/del/name/group`
- `cs_go.cpp`: `.go creature/graveyard/grid/object/taxinode/trigger/zonexy/xyz/ticket`
- `cs_modify.cpp`: money/resources/phase/reputation/scale/speed/currency/morph/demorph
- `cs_learn.cpp`: `.learn`, `.unlearn`, class spells/talents/recipes/crafts/default/lang
- `cs_quest.cpp`: `.quest add/complete/remove/reward`
- `cs_npc.cpp`: NPC info/near/move/add/delete/set/follow and other administration commands
- `cs_server.cpp`: `.server info`, `.server motd` and administrator server controls
- `cs_reload.cpp`: `.reload all` and scoped reload groups

## Deliberate changes from AzerothAdmin 3.3.5a

- WotLK `Interface: 30300` is not reused; MoP uses `50400`.
- WotLK-only item/search/quest datasets are not copied into the MoP runtime.
- Server actions are generated from the MoP repack command namespace.
- Search uses the repack's runtime `.lookup` commands, so IDs/names are resolved from the actual MoP server data rather than a stale 3.3.5a embedded dataset.
- Teleport uses `.lookup tele`, `.tele`, and `.go` instead of importing WotLK teleport coordinates.
- Profession operations use the MoP core's learn/skill commands instead of the WotLK embedded profession database.

## PlayerBot

PlayerBot controls are intentionally not enabled in the stable command catalog until the target `MOP_V2_Repack` branch contains a confirmed PlayerBot command implementation. Sending guessed PlayerBot commands would make the addon appear functional while silently failing on the target server. When PlayerBot is merged into the repack, it should be added as a separate verified command group.

## Validation boundary

GitHub CI checks Lua 5.1 syntax, TOC/runtime integrity, Interface/build metadata, localization packs, and required command coverage. A real 5.4.8 client session is still required to certify rendering and every server action end-to-end; static CI cannot emulate the WoW client or a running worldserver.
