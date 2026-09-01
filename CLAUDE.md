# Claude Code 작업 지침

이 저장소는 **World of Warcraft Mists of Pandaria 5.4.8 Build 18414 / Interface 50400**용 `AzerothAdminMoP` GM 애드온 프로젝트다.

작업 전 다음 문서를 순서대로 읽는다.

1. `CHATGPT_PROJECT_INSTRUCTIONS.md`
2. `AGENTS.md`
3. `PROJECT_STATUS.md`
4. `TASKS.md`
5. `DEVELOPMENT_RULES.md`
6. `PLAYERBOT_COMMAND_AUDIT.md` (관련 작업 시)
7. `README.md`

## Source of truth

- Addon: `hilch1981-prog/mop-gm-addon`
- Runtime/Core: `hilch1981-prog/MOP_V2_Repack`
- Runtime baseline: `repack-main`
- PlayerBot POC: `playerbot-v2-poc`
- WotLK reference: `hilch1981-prog/azerothcore-gm-addon`

WotLK 프로젝트는 UI/UX 및 협업 방식 참고용이며 WotLK 명령/ID/좌표/API를 MoP에 직접 복사하지 않는다.

## 절대 조건

- Lua 5.1만 사용한다.
- MoP 5.4.8 Build 18414 / Interface 50400 호환을 우선한다.
- 서버 명령은 `MOP_V2_Repack`의 실제 C++ handler를 확인한다.
- 외부 donor의 명령 이름과 인수를 치파팩 명령으로 추측하지 않는다.
- 게임 테스트가 없으면 완료/배포 가능/GAME_PASS라고 표현하지 않는다.
- 기존 SavedVariables와 사용자 UI 동작을 가능한 한 보존한다.
- 비공개 소스, 토큰, 계정/DB 비밀번호, 개인 경로를 커밋하지 않는다.

## PlayerBot

- `MOP_V2_Repack/playerbot-v2-poc`의 현재 Gate를 먼저 확인한다.
- Legends PR #389의 `.npcbot`은 historical donor 정보다.
- `.playerbot`/`.npcbot`/`self`/`addspec`/`setspec`을 실제 치파팩 handler 확인 없이 UI에 넣지 않는다.
- 알려진 donor 오류는 `PLAYERBOT_COMMAND_AUDIT.md`를 기준으로 검토한다.

## ChatGPT/Codex와 협업

- 자동 PR 리뷰에서는 읽기 전용 독립 리뷰어로 동작한다.
- Codex가 구현한 `codex/*` 브랜치를 자동 리뷰 중 직접 수정하지 않는다.
- Claude가 구현할 때만 `claude/*` 브랜치를 사용한다.
- 같은 기능/파일을 두 AI가 동시에 수정하지 않는다.

## 변경 후 검증

- Lua 5.1 syntax
- TOC 파일 존재/로드 순서
- MoP 5.4.8 API 호환
- 실제 치파팩 명령 이름/인수/권한
- `python tools/validate_mop_addon.py`
- `python -m unittest discover -s tests -p "test_*.py"`
- 게임 테스트 여부를 정적 검증과 분리해 기록
