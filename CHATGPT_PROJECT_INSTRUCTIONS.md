# ChatGPT 프로젝트 지시서

이 문서는 ChatGPT 프로젝트 지시사항으로 복사해 사용할 수 있는 MoP 전용 기준이다.

---

이 프로젝트는 **World of Warcraft Mists of Pandaria 5.4.8 Build 18414 / Interface 50400**용 `AzerothAdminMoP` GM 애드온을 개발하고 검증한다.

공용 원본 저장소:

`https://github.com/hilch1981-prog/mop-gm-addon`

서버/리팩 정본:

`https://github.com/hilch1981-prog/MOP_V2_Repack`

WotLK 참고 프로젝트:

`https://github.com/hilch1981-prog/azerothcore-gm-addon`

작업을 시작하기 전에 다음을 순서대로 읽는다.

1. `AGENTS.md`
2. `PROJECT_STATUS.md`
3. `TASKS.md`
4. `DEVELOPMENT_RULES.md`
5. `PLAYERBOT_COMMAND_AUDIT.md` (관련 작업 시)
6. `README.md`

## 절대 조건

- MoP 5.4.8 Build 18414 / Interface 50400 기준만 사용한다.
- Lua 5.1 문법만 사용한다.
- `MOP_V2_Repack`의 실제 command handler와 DB를 서버 동작 정본으로 사용한다.
- `azerothcore-gm-addon`은 UI/UX, 협업 방식, 프로젝트 운영 구조 참고용으로만 사용한다.
- WotLK 3.3.5a 명령, ID, 좌표, 데이터셋을 직접 이식하지 않는다.
- 실제 코드를 확인하지 않고 명령 이름, 인수, 권한을 추측하지 않는다.
- 게임 내 테스트를 하지 않았다면 정적 검증과 게임 검증을 구분한다.
- 기존 파일, SavedVariables, UI 동작을 가능한 한 보존한다.
- API 키, 토큰, 계정/DB 접속 정보, 개인 로컬 경로를 저장소에 기록하지 않는다.

## PlayerBot 특별 규칙

- `MOP_V2_Repack/repack-main`과 `playerbot-v2-poc` 상태를 모두 확인한다.
- PlayerBot POC 문서의 기능 목표와 실제 등록된 채팅/GM 명령은 별개로 검증한다.
- Legends PR #389의 `.npcbot`은 역사적 donor 구현이며 치파팩 명령으로 자동 채택하지 않는다.
- `.playerbot`, `.npcbot`, `self`, `addspec`, `setspec` 등은 치파팩의 실제 handler가 확인되기 전에는 UI 버튼으로 노출하지 않는다.
- donor 코드의 알려진 오류는 `PLAYERBOT_COMMAND_AUDIT.md`를 따른다.

## 작업 절차

1. 현재 `main`과 열린 PR을 확인한다.
2. 대상 Lua/TOC/테스트와 서버 command handler를 확인한다.
3. 원인, 수정 파일, 영향 범위, 검증 계획을 정리한다.
4. Codex는 `codex/<기능명>`, Claude는 `claude/<기능명>` 브랜치를 사용한다.
5. 한 PR은 한 기능 또는 한 공통 기반으로 제한한다.
6. Lua 5.1, TOC, MoP API, 명령 문자열, 데이터 출처를 정적 검증한다.
7. 가능하면 다른 AI가 PR을 교차 검토한다.
8. 사용자가 실제 5.4.8 게임에서 검증한 뒤에만 stable/완료로 승격한다.

두 AI가 같은 브랜치나 같은 파일을 동시에 수정하지 않는다. 충돌이 있으면 한쪽을 자동 선택하지 말고 양쪽 의도를 비교한다.

답변과 문서는 기본적으로 한국어로 작성한다.
