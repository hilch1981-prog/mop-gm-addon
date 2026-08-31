# AzerothAdmin 3.3.5a -> MoP 5.4.8 Migration Plan

## Source baseline

WotLK reference repository: `hilch1981-prog/azerothcore-gm-addon`

Target repository: `hilch1981-prog/mop-gm-addon`

Target server/repack: `hilch1981-prog/MOP_V2_Repack` (`repack-main`)

## What can be reused conceptually

- Modular architecture
- Localization strategy
- Command metadata model
- GM panel workflow
- Search/browser UX patterns
- Teleport browser UX
- Item/NPC/quest helper concepts
- Testing discipline and release gating

## What must be revalidated or replaced

- `## Interface: 30300` -> `50400`
- WoW 3.3.5a client API calls
- Frame templates and UI behavior changed in MoP
- AzerothCore-specific commands
- WotLK item/NPC/quest/spell IDs
- WotLK zones, maps, raids and teleport coordinates
- Profession data and recipe IDs
- Embedded 3.3.5-era libraries
- PlayerBot command behavior
- Saved-variable assumptions tied to old modules

## Phases

### Phase 0 - Repository bootstrap

Status: DONE

- Dedicated public repository
- README
- MoP TOC
- Minimal Core/UI
- Slash command entry point

### Phase 1 - Compatibility inventory

Status: NEXT

For every WotLK module, classify:

1. direct-port candidate
2. API adaptation required
3. data replacement required
4. server-command replacement required
5. drop/rewrite

### Phase 2 - Core UI port

- Window shell
- module registry
- localization
- font handling
- popup/localization isolation
- command dispatch
- error handling

### Phase 3 - Server command validation

Validate commands directly against `MOP_V2_Repack` source and then in game.

Priority:

1. GM mode
2. teleport
3. revive
4. bank
5. character operations
6. NPC/creature operations
7. item operations
8. quest operations
9. account/server operations
10. PlayerBot integration

### Phase 4 - MoP data migration

- Pandaria maps and zones
- raids/dungeons/scenarios
- creatures
- items
- quests
- professions
- spells
- teleport data

### Phase 5 - Localization

Target parity:

- enUS
- koKR
- zhCN
- zhTW
- ruRU

### Phase 6 - Test and release

- Static checks
- Client load test
- UI regression
- command-by-command game test
- locale regression
- packaged ZIP verification
- first stable MoP release

## Release rule

No feature is marked compatible solely because its Lua code parses. It must be validated against both the 5.4.8 client and the target repack behavior.
