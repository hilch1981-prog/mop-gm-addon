# Codex 작업 지침

이 저장소는 **World of Warcraft Mists of Pandaria 5.4.8 Build 18414 / Interface 50400**용 `AzerothAdminMoP` GM 애드온이다.

## Source of truth

- 애드온 저장소: `hilch1981-prog/mop-gm-addon`
- 서버/리팩 정본: `hilch1981-prog/MOP_V2_Repack`
- 서버 기준 브랜치: `repack-main`
- PlayerBot 개발 브랜치: `MOP_V2_Repack/playerbot-v2-poc`
- WotLK UI/운영 참고: `hilch1981-prog/azerothcore-gm-addon`

WotLK 저장소는 **UI/UX, 협업 규칙, 모듈화 방식 참고용**이다. WotLK 명령, ID, 좌표, API를 MoP에 직접 복사하지 않는다.

## 작업 전 확인 순서

1. `PROJECT_STATUS.md`
2. `TASKS.md`
3. `DEVELOPMENT_RULES.md`
4. `PLAYERBOT_COMMAND_AUDIT.md` (PlayerBot/명령 작업 시)
5. `README.md`
6. 실제 변경 대상 Lua/TOC/테스트
7. 서버 명령 변경이면 `MOP_V2_Repack`의 실제 C++ command handler

## 절대 조건

- WoW MoP 5.4.8 Build 18414 / Interface 50400 기준만 사용한다.
- Lua 5.1 문법만 사용한다.
- 서버 명령은 `MOP_V2_Repack`의 실제 구현을 확인한 뒤 등록한다.
- Legends/AzerothCore/DigiD702 등 외부 구현은 donor/reference일 뿐 치파팩의 명령 정본이 아니다.
- WotLK 전용 ID, 좌표, 데이터셋, API를 가져오지 않는다.
- 기존 SavedVariables와 UI/UX를 가능한 한 보존한다.
- 실제 게임 테스트를 수행하지 않았다면 `GAME_PASS`, stable, 완료라고 표현하지 않는다.
- API 키, 토큰, 계정 정보, DB 비밀번호, 개인 로컬 경로를 커밋하지 않는다.

## PlayerBot 규칙

- `MOP_V2_Repack/playerbot-v2-poc`의 현재 Gate와 실제 command handler를 먼저 확인한다.
- POC 문서에 `SelfBot`이 적혀 있다는 이유만으로 `.playerbot self`, `.npcbot self` 등을 추측해 UI에 넣지 않는다.
- historical Legends PR #389의 `.npcbot` 명령은 참고 자료일 뿐 치파팩 정본이 아니다.
- PlayerBot 버튼은 치파팩 runtime에 명령 handler가 존재하고 최소 G3(SelfBot Attach/Detach) 검증 범위가 확정된 뒤 별도 PR에서 추가한다.
- donor 코드의 알려진 `addspec` 조건 오류와 `setspec` 무인자 방어 누락은 `PLAYERBOT_COMMAND_AUDIT.md`를 확인한다.

## Git 작업 규칙

- Codex 브랜치: `codex/<기능명>`
- Claude 브랜치: `claude/<기능명>`
- `main` 직접 푸시 금지. 기능별 PR 사용.
- 한 PR에는 한 기능 또는 한 공통 기반만 넣는다.
- 서로 다른 AI가 같은 브랜치/파일을 동시에 수정하지 않는다.
- 사용자의 명시적 승인 전에는 merge/release/tag/Issue 종료를 하지 않는다.

## 검증

- `python tools/validate_mop_addon.py`
- `python -m unittest discover -s tests -p "test_*.py"`
- Lua 5.1 syntax 검사
- TOC 경로/로드 순서 검사
- 명령 문자열을 `MOP_V2_Repack` 구현과 대조
- 게임 테스트가 없으면 정적 검증과 게임 검증을 명확히 구분

답변과 프로젝트 문서는 기본적으로 한국어로 작성한다.
