# R9 User Feedback Regression Ledger

Source: 2026-09-04 R8 in-game screenshots.

| ID | Regression | R9 contract |
|---|---|---|
| MOP-R021 | Profession recipe rows show a generic spell/profession icon instead of the crafted result icon | Recipe-row icon prefers `ProfessionDetails.createdItem` item icon; spell/profession icon is fallback only |
| MOP-R022 | `ScottTest` / 시험 지역 is visible and teleports to an invalid server target | Source row stays auditable but is disabled from search, full catalog and favorites |
| MOP-R023 | AreaTable overlay replaced prior Korean teleport labels and exposed raw English names | R7 localized names are the baseline; AreaTable upgrades only old numbered placeholders; unmatched rows retain R7 Korean fallback |
| MOP-R024 | Teleport row text is one variable-width string and columns do not line up | Main teleport catalog uses fixed `대륙/지역`, `목적지`, `레벨`, `진영` columns |
| MOP-R025 | Wide `UICheckButtonTemplate` stretches its checked texture into a diagonal slash | Check glyph is fixed at 20x20; only the hit rectangle extends across the label |

STATIC/MOCK pass does not imply GAME_PASS.
