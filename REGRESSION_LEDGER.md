# REGRESSION_LEDGER.md

This file records defects that must never reappear.

| ID | Source | Symptom | Module | Status | Required regression |
|---|---|---|---|---|---|
| MOP-R001 | user feedback after 1.3.3-test2 | UI did not match canonical AzerothCore presentation | UI/layout | OPEN - re-audit required | compare MoP screens/tabs/layout against verified AzerothCore release |
| MOP-R002 | user feedback after 1.3.3-test2 | one or more GM commands did not execute correctly | command adapter | OPEN - re-audit required | verify every exposed command against `MOP_V2_Repack` C++ + DB command evidence |
| MOP-R003 | prior rc2 feedback | ESC/main-window close behavior incorrect | shell/UI | FIX KNOWN, must preserve | main window closes correctly with ESC without breaking child UI |
| MOP-R004 | prior rc2 feedback | `/mopgm` raw GM command collided with addon control commands | command dispatch | FIX KNOWN, must preserve | `/mopgm <cmd>` sends raw GM command; addon control commands remain separate |
| MOP-R005 | prior rc2 feedback | SQL DataBrowser contained hard-coded locale behavior | DataBrowser/localization | FIX KNOWN, must preserve | browser strings follow locale/fallback contract |
| MOP-R006 | project recovery incident | reduced/skeleton package lost working modules/data | packaging/module inventory | OPEN guardrail | compare file/module inventory and data sizes against selected full baseline before release |

Add exact screenshot/file references and root causes as recovered from prior project material.
