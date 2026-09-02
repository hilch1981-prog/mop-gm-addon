# AGENTS.md

## Scope

이 저장소는 **WoW MoP 5.4.8 Build 18414 GM 애드온 전용**입니다.

다음 항목을 섞지 마십시오.

- AzerothCore WotLK 3.3.5a 전용 코드/명령 가정
- MoP 서버 C++ 본체
- 전체 DB dump
- 게임 클라이언트 파일

## Authoritative targets

- Client: MoP 5.4.8 / Interface 50400
- Server: `hilch1981-prog/MOP_V2_Repack`
- Branch: `repack-main`
- Baseline: `0739d072f8f1f42523f04cca4b2607d88a01def4`
- WotLK reference: `hilch1981-prog/azerothcore-gm-addon@v3.5.0-335a`

WotLK 저장소는 UI/기능 계보 참고용이며 MoP 명령/데이터의 정본이 아닙니다.

## Classification

모든 포팅 작업은 아래 중 하나로 분류합니다.

- `PORTABLE`: 구조를 거의 그대로 이식 가능
- `MOP_ADAPT`: MoP API/서버 명령에 맞게 수정
- `REIMPLEMENT`: 데이터/API 차이 때문에 재구현
- `BLOCKED`: 서버 기능 또는 검증이 준비되지 않음

## Rules

1. 기능 하나 또는 호환성 이슈 하나당 PR 하나를 우선합니다.
2. 서버 명령 버튼은 `MOP_V2_Repack/src/server/scripts/Commands`에서 실제 구현을 확인한 뒤 추가합니다.
3. WotLK 데이터 파일을 MoP 정본처럼 복사하지 않습니다.
4. `QuestRewards335.lua` 같은 3.3.5a 전용 데이터는 로드 금지입니다.
5. PlayerBot은 서버 POC가 build/boot/game gate를 통과하기 전 활성화하지 않습니다.
6. 정적 테스트 PASS와 실제 게임 PASS를 구분합니다.
7. enUS를 런타임 fallback으로 유지하고 koKR를 우선 지원합니다.
8. Retail 전용 API를 도입하지 않습니다.
9. 기존 WotLK 저장소는 WotLK 수정이 아닌 한 건드리지 않습니다.
10. 문서의 완료 표시는 증거가 있을 때만 갱신합니다.

## Merge minimum

- TOC 경로 전부 존재
- Interface 50400
- 런타임 파일에 Interface 30300 없음
- `QuestRewards335` 런타임 의존성 없음
- `/aamop` 기본 shell 유지
- PlayerBot POC 미완료 시 실제 제어 버튼 비활성
