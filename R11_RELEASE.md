# AzerothAdmin MoP 5.4.8 R11

Canonical game-test package for this branch:

- File: `AzerothAdmin_3.5.0-548-r11-GAME-TEST-FULL.zip`
- SHA-256: `8a452840a5fffbe57bd2664b067c448bd6efabfc3c1216c1d798515359fd1090`
- Uncompressed payload: `16,211,698` bytes
- Files: `86`
- ZIP integrity: verified with `unzip -t` (no errors)
- Client: WoW MoP 5.4.8 Build 18414 / Interface 50400
- Server source baseline: `hilch1981-prog/MOP_V2_Repack@0739d072f8f1f42523f04cca4b2607d88a01def4`

## R10 -> R11 delta verified from the packaged files

1. `AzerothAdmin/AzerothAdmin.toc`
2. `AzerothAdmin/Data/MoP/SourceInfo.lua`
3. `AzerothAdmin/FILE_MANIFEST.sha256`
4. `AzerothAdmin/Framework/Bootstrap.lua`
5. `AzerothAdmin/Modules/Integrations/BattlePetDeathPicker.lua` (new)
6. `AzerothAdmin/Modules/Verification/StaticChecks.lua`
7. `AzerothAdmin/README_KR.txt`
8. `AzerothAdmin/Tests/RuntimeSelfTest.lua`
9. `AzerothAdmin/USER_REGRESSION_R11.md` (new)

Do not substitute R10 or an earlier package when validating this branch. The SHA-256 above is the release identity for the user's requested R11 game-test build.
