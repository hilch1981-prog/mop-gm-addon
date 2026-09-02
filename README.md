# AzerothAdmin for MoP 5.4.8

치파 MoP V2 Repack 전용을 우선 목표로 하는 GM 관리 애드온 저장소입니다.

## 기준 환경

- Client: World of Warcraft Mists of Pandaria 5.4.8
- Build: 18414
- Interface: 50400
- Server Source of Truth: `hilch1981-prog/MOP_V2_Repack`
- Server branch: `repack-main`
- Server baseline: `0739d072f8f1f42523f04cca4b2607d88a01def4`
- Porting reference only: `hilch1981-prog/azerothcore-gm-addon`
- WotLK reference release: `v3.5.0-335a`

이 저장소는 WotLK 애드온과 MoP 서버 본체를 섞지 않습니다.

## 현재 단계

`0.1.0-mop-alpha / P0 Bootstrap`

현재 포함 범위:

- MoP 5.4.8용 TOC (`Interface 50400`)
- `/aamop` 기본 UI
- GM 모드 ON/OFF
- GM 비행 ON/OFF
- GM 표시/은신 ON/OFF
- 직접 GM 명령 입력
- `.tele <name>` 실행 UI
- `.lookup item|creature|quest <text>` 검색 UI
- PlayerBot V2 상태 표시(기능은 아직 비활성)
- 정적 검증 도구 및 GitHub Actions

## 설치

`AzerothAdmin/` 폴더를 클라이언트의 다음 경로에 복사합니다.

`World of Warcraft/Interface/AddOns/AzerothAdmin/`

게임에서 `/aamop` 명령으로 창을 엽니다.

## 중요 원칙

WotLK 3.3.5a의 데이터 파일을 MoP에 그대로 복사하지 않습니다. 아이템, 퀘스트, 전문기술, 크리처, 텔레포트 데이터는 MoP 5.4.8과 치파팩 DB/소스를 기준으로 재검증하거나 재생성합니다.

PlayerBot V2는 `MOP_V2_Repack` Draft PR #1에서 POC 진행 중입니다. G1의 MODULES=0/1 clean build는 PASS지만 worldserver boot와 human smoke가 아직 PENDING이므로 애드온의 실제 PlayerBot 제어는 비활성 상태로 유지합니다.

상세 진행 상황은 `PROJECT_STATUS.md`, `TASKS.md`, `docs/`를 참고하세요.
