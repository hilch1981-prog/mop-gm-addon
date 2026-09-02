# Tasks

## P0 - Bootstrap

- [x] clean repository reset
- [x] Interface 50400 TOC
- [x] base shell
- [x] enUS/koKR locale foundation
- [x] verified GM controls
- [x] teleport entry
- [x] item/creature/quest lookup entry
- [x] PlayerBot disabled status panel
- [x] static checks
- [ ] client load test
- [ ] in-game command smoke test

## P1 - Complete command layer

- [ ] enumerate all MoP command scripts
- [ ] generate command metadata and security levels
- [ ] compare every WotLK button with MoP syntax
- [ ] remove AzerothCore-only actions
- [ ] add useful MoP-only actions

## P2 - Teleports and search

- [ ] port full Teleports UI
- [ ] rebuild teleport dataset from MoP/Chipa data
- [ ] port Search UI
- [ ] rebuild Korean search aliases
- [ ] validate Pandaria map/area IDs

## P3 - Creatures and quests

- [ ] port creature browser without removed 3D preview
- [ ] rebuild Pandaria creature data
- [ ] verify npc/go/summon/delete commands
- [ ] port QuestHelper UI
- [ ] rebuild quest/drop-source data for MoP

## P4 - Items and professions

- [ ] replace WotLK item classification data
- [ ] ensure no `QuestRewards335` dependency
- [ ] audit MoP `GetItemInfo`/tooltip behavior
- [ ] audit MoP profession/tradeskill APIs
- [ ] rebuild profession datasets

## P5 - Bank / revive / integrations

- [ ] audit bank frame/session APIs
- [ ] verify remote bank server flow
- [ ] verify self revive flow
- [ ] audit embedded libraries one by one

## P6 - PlayerBot V2

- [ ] G1-B3 worldserver boot PASS
- [ ] human smoke regression PASS
- [ ] subsequent canonical POC gates complete
- [ ] freeze PlayerBot command contract
- [ ] implement addon PlayerBot controls
- [ ] game-test attach/detach/control

## Release gate

- [ ] koKR full game test
- [ ] enUS smoke test
- [ ] clean install test
- [ ] SavedVariables migration test
- [ ] release ZIP/checksum workflow
