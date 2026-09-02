# ARCHITECTURE_CONTRACT.md

## One product, multiple client adapters

AzerothAdmin is one product architecture. Client versions are ports of that product, not independent redesigns.

### Canonical UI/product layer

Source: `hilch1981-prog/azerothcore-gm-addon` verified release.

Owns:

- UI composition
- navigation
- table schemas
- module names/responsibilities
- user workflows
- localization keys/concepts
- command/search/teleport/item/profession screen behavior

### Client adapter layer

Owns only version-specific APIs:

- WotLK 3.3.5a adapter
- MoP 5.4.8 adapter
- future client-version adapters

### Server adapter/data layer

For MoP, authority is `MOP_V2_Repack`:

- CommandScript implementation
- command/security metadata
- DB command table
- teleport DB (`game_tele`)
- item/quest/creature/gameobject/spell/profession IDs/data

## Porting rule

For each module:

1. Start from the verified AzerothCore module.
2. Freeze its UI/table contract.
3. Identify only client/server/data differences.
4. Place those differences in adapter/data files.
5. Add regression tests for every known defect.
6. Do not replace unaffected modules.

## Forbidden patterns

- separate temporary MoP UI
- wholesale UI rewrite
- changing table columns/layout just because data changed
- copying unverified WotLK IDs into MoP
- copying BlueItemInfo/Inven UI instead of data
- regenerating a small skeleton and calling it a recovery build
- deleting working modules during compatibility fixes

## Required comparison gates

Before a MoP release candidate:

- compare module inventory against the verified AzerothCore release
- compare screen/tab inventory
- compare UI/table contracts
- verify all MoP commands against core/DB evidence
- verify all teleport data against target DB
- verify item/profession data source provenance
- rerun the user-feedback regression ledger
