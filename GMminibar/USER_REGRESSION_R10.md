# USER_REGRESSION_R10

R10 game-feedback fixes are release-blocking regressions.

1. Teleport progression checkbox is faction-only; player level must not filter destinations.
2. Teleport faction checkbox and label stay inside the 500px window.
3. Teleport table columns are fixed: area is widened, destination narrowed, and long UTF-8 labels use `...` without corrupting Korean text.
4. Clicking the area/destination/level/faction table headers sorts that column; repeated click reverses direction.
5. Search, continent/expansion, type and own-faction controls remain the table filters.
6. No `기타 지역 위치 NN` placeholder is allowed for known server destinations.
7. Known raw server destinations are localized: Darkmoon Faire, Dagger in the Dark, Secrets of Ragefire, Thunder King's Citadel, The Lost Isles, Secret Ingredient, Proving Grounds.
8. Profession detail must not display the `InvenCraftInfo2 v4.0` source-brand line; only useful tool/current-skill/learn-state text remains.
9. R4-R9 regression guards remain intact.
