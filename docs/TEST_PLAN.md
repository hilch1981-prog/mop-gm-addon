# Test Plan

## Static

```bash
python tools/static_check.py
```

Expected: `PASS`

## Client load

1. `AzerothAdmin`을 `Interface/AddOns/`에 복사
2. WoW 5.4.8 Build 18414 실행
3. AddOn 목록에서 활성화 확인
4. GM 계정 로그인
5. `/aamop`
6. Lua error 없이 창 열림 확인

## P0 command smoke

순서대로 단독 검증:

- GM ON
- GM OFF
- Fly ON
- Fly OFF
- Visible ON
- Visible OFF
- `.tele <known game_tele>`
- `.lookup item <text>`
- `.lookup creature <text>`
- `.lookup quest <text>`

## PlayerBot expected result

- 탭 표시
- POC 진행 중 문구 표시
- 실제 실행 버튼 disabled

## Bug evidence

- client locale
- exact Lua error
- exact command/button
- server response
- selected target state
- server commit / addon commit
