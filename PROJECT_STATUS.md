# AzerothAdminMoP 프로젝트 상태

최종 갱신 기준: 2026-09-02

## 대상

- Client: WoW MoP 5.4.8
- Build: 18414
- Interface: 50400
- Addon repo: `hilch1981-prog/mop-gm-addon`
- Runtime source of truth: `hilch1981-prog/MOP_V2_Repack`
- Runtime main: `repack-main`
- PlayerBot POC: `playerbot-v2-poc`
- WotLK reference project: `hilch1981-prog/azerothcore-gm-addon`

## 현재 애드온 상태

- GM command panel: 구현
- Raw command runner/history: 구현
- MoP SQL data browser: 구현
- koKR overlay: 구현
- Minimap button/favorites: 구현
- Lua 5.1 static validation: 구현
- Real-client 5.4.8 regression: 미완료

현재 버전은 정적 검증된 release candidate이며 GAME_PASS는 아니다.

## Command audit 상태

기존 명령 카탈로그는 `MOP_V2_Repack` 기준으로 작성되었으나 `.server uptime`이 `Commands.lua`에 남아 있고 런타임 `CommandSanity.lua`가 제거하는 우회 구조가 확인되었다. 원본 카탈로그에서 제거하는 것이 현재 수정 대상이다.

## PlayerBot 상태

`MOP_V2_Repack/playerbot-v2-poc`은 `repack-main`에서 분기된 실제 개발 브랜치이며 Generic Module Infrastructure부터 단계적으로 검증 중이다.

현재 정식 POC Gate 흐름:

- G1 Generic Module Infrastructure
- G2 PlayerScript Bridge
- G3 SelfBot Attach/Detach
- G4 SelfBot Control Ownership
- G5 Windwalker Minimal Rotation
- G6 Human Regression
- G7 Disable/Remove

현재 애드온에서는 PlayerBot 버튼을 노출하지 않는다. SelfBot 목표가 문서에 존재하는 것과 실제 GM/chat command handler가 존재하는 것은 별개다.

Historical Legends PR #389는 donor/reference로만 사용한다. 해당 구현에서 `.npcbot`, `addspec`, `setspec` 관련 주의점은 `PLAYERBOT_COMMAND_AUDIT.md`에 기록한다.

## 다음 승격 조건

1. 프로젝트 지시서/개발 규칙 정착
2. 명령 카탈로그 정본화 및 회귀 검사
3. PlayerBot POC가 G3 이상에서 실제 command surface 확정
4. 확정된 명령만 별도 PR로 애드온 UI에 추가
5. 실제 MoP 5.4.8 게임 테스트
