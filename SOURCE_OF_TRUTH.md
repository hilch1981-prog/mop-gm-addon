# SOURCE_OF_TRUTH.md

## Absolute project rule

This project is not a separate MoP UI rewrite.

The verified final AzerothCore GM addon is the canonical product baseline:

- Repository: `hilch1981-prog/azerothcore-gm-addon`
- Verified release line: `AzerothAdmin 3.5.0-335a`
- Client: WotLK 3.3.5a / Interface 30300

The MoP addon must preserve the AzerothCore addon's screen composition, module boundaries, tables, workflows, control placement, labels, navigation, and UX as closely as the MoP 5.4.8 client permits.

**Do not redesign the UI, do not replace tables, and do not invent a separate temporary MoP architecture.**

## MoP target

- Repository: `hilch1981-prog/mop-gm-addon`
- Client: WoW Mists of Pandaria 5.4.8 Build 18414
- Interface: 50400
- Server/core/database authority: `hilch1981-prog/MOP_V2_Repack`
- Stable server branch: `repack-main`

The MoP implementation is an adapter/data port of the verified AzerothCore addon, not a new addon design.

## Evidence priority

When facts disagree, use this order:

1. Verified AzerothCore GM addon release for UI/layout/module/table behavior.
2. Actual `MOP_V2_Repack` C++ command implementation and target DB tables for MoP server behavior.
3. Actual MoP 5.4.8 in-game test result.
4. User-provided SQL, screenshots, error reports, creator icon, and test feedback.
5. This file and repository status documents.
6. Historical MoP test builds such as `AzerothAdminMoP-1.3.3-test2` only as recovery material.
7. Chat history or AI memory.

## UI freeze contract

The following are frozen to the AzerothCore verified release unless a MoP client API makes the exact implementation impossible:

- main window layout and size concept
- tabs and navigation hierarchy
- button placement and workflow
- search/browse table structure
- item information screen structure
- profession information screen structure
- teleport/favorites workflow
- GM command workflow
- localization placement and UX
- minimap entry behavior
- visual grouping of modules

If MoP requires a compatibility fix, change the smallest internal adapter/module only. Do not redesign unrelated UI.

## Allowed MoP differences

MoP changes belong in replaceable modules/data layers:

- TOC Interface and MoP-compatible client APIs
- verified GM command strings and security behavior
- `world.command` / command-table-derived metadata
- `game_tele` names and coordinates
- MoP item data
- MoP quest/creature/gameobject data
- MoP profession data
- MoP spell/skill IDs
- MoP-specific lookup/search aliases
- MoP server/core adapters

## Item and profession data rule

The AzerothCore addon item/profession UI and table structures are frozen.

The original AzerothCore item/profession modules were developed using sources including WoW Inven and BlueItemInfo-derived data. For MoP, user-provided sources such as:

- `BlueItemInfo3_5.4_fanfix3`
- `InvenCraftInfo2_v4.0`

are **data/reference sources only**.

Use their MoP item/profession information to update data inside the existing AzerothAdmin item/profession structures. Do not import their UI wholesale and do not change AzerothAdmin table/UI contracts.

## Historical MoP build rule

`AzerothAdminMoP-1.3.3-test2` is the latest historical MoP test build supplied by the user, but it contains known defects. It is not the UI authority.

Use it only to recover MoP-specific work that is still valid, then compare every recovered feature back against the verified AzerothCore release.

Known later user feedback after 1.3.3-test2 includes UI defects and GM commands that did not work. Those defects must become regression tests and must not be reintroduced.

## Regression rule

Every confirmed user screenshot/error becomes a permanent regression case. Once fixed, the same failure must not reappear in a later build.

Maintain a defect ledger with:

- symptom
- affected module
- root cause
- fix
- regression test
- validation level

## Modularization/token rule

Keep modules small and replace only the affected compatibility/data layer. Avoid whole-file rewrites when a narrow adapter/data patch is sufficient. This is both an engineering rule and a token-efficiency rule for ChatGPT/Claude collaboration.

## Completion levels

- V0 IDEA
- V1 DESIGNED
- V2 PORTED
- V3 STATIC_PASS
- V4 SERVER_PASS
- V5 GAME_PASS
- V6 REGRESSION_PASS

Never call STATIC_PASS a GAME_PASS.
