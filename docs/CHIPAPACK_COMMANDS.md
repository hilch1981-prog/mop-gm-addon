# Chipa MoP Command Audit

Target: `hilch1981-prog/MOP_V2_Repack@repack-main`

Baseline: `0739d072f8f1f42523f04cca4b2607d88a01def4`

## Verified P0 families

### `cs_gm.cpp`

- `.gm on`
- `.gm off`
- `.gm fly on`
- `.gm fly off`
- `.gm visible on`
- `.gm visible off`
- `.gm chat on|off`
- `.gm ingame`
- `.gm list`

### `cs_tele.cpp`

- `.tele <location>`
- `.tele add <location>`
- `.tele del <location>`
- `.tele name ...`
- `.tele group ...`

### `cs_lookup.cpp`

- `.lookup area`
- `.lookup creature`
- `.lookup event`
- `.lookup faction`
- `.lookup item`
- `.lookup itemset`
- `.lookup object`
- `.lookup quest`
- `.lookup player`
- `.lookup skill`
- `.lookup spell`
- `.lookup taxinode`
- `.lookup tele`
- `.lookup title`
- `.lookup map`

## Rule

AzerothCore에서 같은 이름의 명령이 있었다는 이유만으로 호환 처리하지 않습니다. MoP command matrix는 치파팩 소스에서 다시 작성합니다.
