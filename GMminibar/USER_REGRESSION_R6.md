# R6 user game-test regression

Version: `3.5.0-548-r6-feedback-rc6`

Source: user R5 in-game feedback supplied on 2026-09-03.

Confirmed working and preserved:

- Teleport Korean labels.
- Quest status/completion, objective/progress display, search, and quest add.
- Most quest start/end and NPC/gameobject navigation.
- Profession spell/result/reagent data.

R6 focused corrections:

1. A valid coordinate may contain zero on one axis; only the generated all-zero no-spawn marker is rejected.
2. Verified coordinates and GUIDs are sorted ahead of creature-entry fallbacks. If any strong target exists, spawnless entry-only targets are excluded from the click cycle.
3. Client quest objectives are matched to `quest_objective` by objective slot first, then type and normalized description/target-name score.
4. Objective lookup follows the matched DB objective kind instead of relying only on the client label.
5. Unavailable start/end/objective buttons explain whether a relation exists without an active spawn or the quest is item/script initiated.
6. MoP direct known-spell APIs no longer trigger a full spellbook scan after returning false.
7. First-page spell information for all 11 professions warms incrementally and is persisted per locale in SavedVariables.
8. Reagents visibly distinguish ready, partially held, and missing states, including shortage counts.

Validation level remains STATIC/MOCK PASS until this R6 package is tested in the real MoP 5.4.8 client.
