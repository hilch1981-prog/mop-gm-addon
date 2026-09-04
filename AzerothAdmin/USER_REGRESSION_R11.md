# R11 hidden BattlePet death picker regression

Date: 2026-09-04
Build: `3.5.0-548-r11-battlepet-rc11`

## User request

- Embed the supplied `BattlePetDeathPicker.7z` into AzerothAdmin.
- No visible UI, button, settings panel, SavedVariables, or slash command.
- Keep exactly one functional purpose: when the active allied battle pet dies, make the built-in pet selection window appear reliably.

## Source inspection

The supplied standalone addon contains two unrelated behaviors:

1. `PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE` / `PET_BATTLE_HEALTH_CHANGED` death watcher that calls the built-in `PetBattlePetSelectionFrame_Show`.
2. A separate quest-frame auto-close hook on `QuestFrameAcceptButton` and `QuestFrameCompleteQuestButton`.

Only behavior (1) is embedded. Behavior (2) is deliberately excluded.

## Regression gates

- `Modules/Integrations/BattlePetDeathPicker.lua` is loaded by the main TOC.
- It registers only the two pet-battle death/round events.
- It contains no quest-frame hooks and no visible AzerothAdmin UI registration.
- It creates no SavedVariables and no slash command.
- Mock runtime: dead active ally pet + two living pets -> built-in selection frame is shown.
