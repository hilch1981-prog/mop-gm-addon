# R8 User Feedback Regression Ledger

Source: 2026-09-04 in-game screenshots + `AreaTable.csv` + canonical AzerothAdmin 3.5.0-335a minibar behavior.

| ID | Regression | R8 contract |
|---|---|---|
| MOP-R014 | Main subtitle/security strings overlap or truncate | One short line: client · core · security · deployment date |
| MOP-R015 | Child windows have no way back to previous addon screen | All managed child windows expose `← 뒤로` and share window history |
| MOP-R016 | Quest detail/objective can retain an older quest and navigate to stale target | Selection is Quest-ID based; objective action validates selected Quest ID before dispatch |
| MOP-R017 | Teleports display opaque `위치 01/02/03` placeholders | Match server raw names to `AreaTable.csv` internal names; unmatched rows use exact raw server name, never invented Korean |
| MOP-R018 | Item type/quality/class controls dominate UI and class filter is heuristic | Search + canonical categories are primary; optional collapsible type/quality advanced filter; class filter removed |
| MOP-R019 | Restart/shutdown lifecycle commands are too prominent for this repack | Definitions remain registered but hidden by default profile |
| MOP-R020 | Clicking the same minibar window icon twice does not close it | Canonical minibar uses `Toggle*` handlers for teleport/favorites/quest/profession/item windows |

These are permanent release regressions. STATIC/MOCK pass does not imply GAME_PASS.
