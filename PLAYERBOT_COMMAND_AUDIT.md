# PlayerBot Command Audit

기준일: 2026-09-04

## 1. 적용 대상

이 문서는 `AzerothAdmin` MoP 5.4.8 포트에서 PlayerBot 버튼/명령을 추가하기 전에 확인해야 할 command compatibility 기록이다. 런타임 namespace는 `AzerothAdminMoP548`을 기준으로 한다.

정본 우선순위:

1. `hilch1981-prog/MOP_V2_Repack` 실제 runtime 구현
2. `MOP_V2_Repack/playerbot-v2-poc` 실제 POC 구현
3. `hilch1981-prog/mod-playerbots` MoP V2 module
4. DigiD702 MoP donor/reference
5. Legends of Azeroth PR #389 historical reference
6. AzerothCore mod-playerbots generic reference

## 2. 현재 치파팩 상태

`playerbot-v2-poc`은 `repack-main` 기준 PlayerBot V2 POC 개발 브랜치다. 현재 정식 POC 흐름은 G1~G7을 정의하며 G3에서 SelfBot Attach/Detach를 검증하는 구조다.

중요: **POC 문서에 SelfBot 목표가 존재한다고 해서 `.playerbot self` 또는 `.npcbot self`라는 명령이 치파팩 runtime에 등록되어 있다는 뜻은 아니다.**

따라서 runtime command handler가 확인되기 전에는 `AzerothAdmin` UI에 PlayerBot 실행 버튼을 노출하지 않는다.

## 3. Legends PR #389 command surface

Historical PR #389에서 확인된 최상위 등록 명령:

- `.npcbot` - administrator
- `.pmon` - gamemaster

PlayerBot manager 도움말/구현에서 확인되는 subcommand:

- `list`
- `reload`
- `tweak`
- `self`
- `add <PLAYERNAME>`
- `init <PLAYERNAME>`
- `remove <PLAYERNAME>`
- `addclass <CLASSNAME>`
- `addspec <tank|heal|dps>`
- `setspec <spec>`

이 목록은 donor 분석 기록이지 치파팩 애드온에 넣을 확정 명령표가 아니다.

## 4. donor 구현에서 확인된 오류

### 4.1 `addspec` 조건 반전

PR #389 계열 구현은 `tank`, `dps`, `heal`이 들어왔을 때 invalid 처리로 들어갈 수 있는 조건식이 확인되었다. 유효 역할 검증 조건을 그대로 이식하면 안 된다.

치파팩 구현 시 요구사항:

- 인자가 nil/empty면 실패
- 허용값은 명시적으로 `tank`, `heal`, `dps`
- 허용값이면 정상 경로
- 그 외 값만 invalid 처리

### 4.2 `setspec` 무인자 방어

PR #389 계열 구현은 target이 존재할 때 `charname`을 충분히 검증하지 않고 숫자 변환 경로로 넘길 수 있다.

치파팩 구현 시 요구사항:

- 인자 존재 확인
- 숫자 변환 성공 확인
- MoP specialization 범위/의미 확인
- target/player ownership 확인
- 잘못된 인자는 사용법만 반환하고 crash/undefined behavior를 만들지 않음

### 4.3 `.npcbot` 명칭

PR #389는 PlayerBot command script임에도 최상위 명령을 `.npcbot`으로 등록한다. AzerothCore 문서/다른 구현과 명칭이 다를 수 있으므로 치파팩에서 자동으로 유지하거나 `.playerbot`으로 임의 변경하지 않는다.

치파팩에서 최종 command handler가 정해진 뒤 애드온이 그 이름을 따른다. 필요하다면 서버 쪽에서 alias를 제공하되 애드온이 존재하지 않는 alias를 가정하지 않는다.

## 5. AzerothAdmin 노출 Gate

PlayerBot UI를 추가하려면 모두 충족해야 한다.

- [ ] 치파팩 runtime에 PlayerBot command handler source 존재
- [ ] 최상위 명령 이름 확인
- [ ] `self` attach/detach 방식 확인
- [ ] add/remove/list 계열 존재 여부 확인
- [ ] 권한 레벨 확인
- [ ] 필수/선택 인수 확인
- [ ] 잘못된 인자 방어 확인
- [ ] G3 SelfBot Attach/Detach 최소 구현 상태 확인
- [ ] 정적/build/boot 상태 기록

게임 검증 전에는 UI에 `experimental` 상태를 명확히 표시한다.

## 6. 애드온 회귀 방지

검증 전 `.playerbot` 또는 `.npcbot` 명령을 런타임 command catalog에 임의로 추가하지 않는다. 서버 POC에서 실제 command surface가 확정되면 이 문서와 정적 검증 규칙을 먼저 갱신한 별도 PlayerBot UI PR을 만든다.

## 7. 현재 분리 원칙

- 이 문서는 command 감사/게이트만 정의한다.
- R11 애드온 소스 동기화와 섞지 않는다.
- Claude/release 자동화와 섞지 않는다.
- 실제 PlayerBot UI 구현은 서버측 G3 command surface가 확인된 뒤 별도 PR로 진행한다.
