# AzerothAdminMoP 개발 규칙

## 1. 호환성 우선순위

1. WoW MoP 5.4.8 Build 18414 / Interface 50400
2. `hilch1981-prog/MOP_V2_Repack` 실제 소스와 DB
3. 기존 `AzerothAdminMoP` SavedVariables/UI 호환
4. 외부 donor/reference 구현

외부 구현이 치파팩과 다르면 치파팩을 우선한다.

## 2. 서버 명령

- 새 버튼/명령 추가 전 실제 C++ `CommandScript`/`ChatCommand` 등록을 확인한다.
- 명령 이름뿐 아니라 subcommand, 인수, 선택 인수, 권한도 확인한다.
- 문서에만 있고 코드에 없는 명령은 추가하지 않는다.
- `Commands.lua`에 존재하는 명령은 지원되는 명령이어야 한다. 런타임에서 몰래 제거하는 방식보다 원본 카탈로그 수정이 우선이다.
- `tools/validate_mop_addon.py`에 제거된/금지된 명령의 회귀 검사를 추가한다.

## 3. PlayerBot

- PlayerBot runtime 정본은 `MOP_V2_Repack/playerbot-v2-poc`의 실제 구현이다.
- POC Gate 문서는 목표와 검증 수준을 정의하며 명령 이름을 자동 보장하지 않는다.
- historical Legends PR #389, AzerothCore, DigiD702는 donor/reference다.
- SelfBot 버튼은 최소 G3 구현과 실제 command handler가 확인되기 전에는 노출하지 않는다.
- donor bug를 그대로 복제하지 않는다.

## 4. Lua/UI

- Lua 5.1만 사용한다.
- MoP 5.4.8에서 존재하지 않는 Retail API 사용 금지.
- TOC 로드 순서를 깨뜨리지 않는다.
- 공통 명령 전송은 기존 `Core.lua` 경로를 사용한다.
- 새 기능은 기존 패널을 불필요하게 재작성하지 않고 작은 패치로 추가한다.
- 사용자 표시 문자열은 가능하면 locale 체계에 넣는다.

## 5. 데이터

- Item/Quest/Creature/Teleport는 치파팩 MoP DB에서 생성한다.
- WotLK ID/좌표를 fallback 데이터로 넣지 않는다.
- 생성 데이터는 source revision을 보존한다.

## 6. Git/협업

- `main` 직접 수정 금지.
- Codex: `codex/*`, Claude: `claude/*`.
- 기능별 PR.
- 사용자 승인 전 PR merge, release, tag, Issue close 금지.
- 외부 코드/데이터를 포함하면 출처와 라이선스를 기록한다.

## 7. 검증 단계

- STATIC_PASS: Lua 5.1/TOC/validator/tests 통과
- COMMAND_AUDIT_PASS: 실제 치파팩 command handler 대조 완료
- GAME_PASS: 실제 MoP 5.4.8 클라이언트에서 기능 검증

STATIC_PASS를 GAME_PASS로 표현하지 않는다.
