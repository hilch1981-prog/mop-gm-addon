# AzerothAdminMoP 작업 목록

## P0 - 프로젝트 운영 기준

- [x] MoP 전용 `AGENTS.md`
- [x] MoP 전용 `CHATGPT_PROJECT_INSTRUCTIONS.md`
- [x] `DEVELOPMENT_RULES.md`
- [x] `PROJECT_STATUS.md`
- [x] PlayerBot command audit 문서
- [ ] 필요 시 WotLK 프로젝트의 모듈 매니페스트 구조를 MoP 규모에 맞게 도입

## P0 - Command correctness

- [ ] `Commands.lua`에서 미지원 `.server uptime` 제거
- [ ] validator에서 `.server uptime` 재유입 차단
- [ ] validator에서 검증 전 `.playerbot` / `.npcbot` UI 노출 차단
- [ ] 새 명령 추가 시 `MOP_V2_Repack` 실제 handler 근거 기록

## P1 - PlayerBot integration

- [ ] `MOP_V2_Repack/playerbot-v2-poc` G1 결과 추적
- [ ] G2 PlayerScript Bridge 결과 확인
- [ ] G3 SelfBot Attach/Detach 구현 시 실제 command surface 확인
- [ ] command name/subcommand/권한/인수 정리
- [ ] donor PR #389와 차이표 작성
- [ ] 확정된 command surface만 `AzerothAdminMoP` PlayerBot 모듈로 추가
- [ ] 게임 테스트 전 experimental 상태 유지

## P1 - Game validation

- [ ] MoP 5.4.8 Build 18414 클라이언트 로드
- [ ] 패널 열기/닫기
- [ ] minimap left/right/middle click
- [ ] 대표 GM 명령 smoke test
- [ ] SQL browser item/quest/creature/teleport
- [ ] koKR 입력/표시
- [ ] SavedVariables 재접속 유지

## P2 - UI/UX parity

WotLK `azerothcore-gm-addon`의 최신 UI/UX를 참고하되 MoP 호환성을 우선한다.

- [ ] 모듈별 UI 비교
- [ ] 사용 빈도 기준 버튼 재배치
- [ ] 상태/위험 명령 시각 구분
- [ ] PlayerBot이 확정되면 별도 카테고리로 추가
