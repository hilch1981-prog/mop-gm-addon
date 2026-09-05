# PlayerBot Command Audit

기준일: 2026-09-05

## 1. 적용 대상

이 문서는 `AzerothAdmin` MoP 5.4.8 포트에서 PlayerBot 버튼/명령을 추가하기 전에 확인해야 할 command compatibility 기록이다. 런타임 namespace는 `AzerothAdminMoP548`을 기준으로 한다.

정본 우선순위:

1. `hilch1981-prog/MOP_V2_Repack` 실제 runtime 구현
2. `MOP_V2_Repack/playerbot-v2-poc` 실제 POC 구현
3. `hilch1981-prog/mod-playerbots` MoP V2 module
4. DigiD702 MoP donor/reference
5. Legends of Azeroth PR #389 historical reference
6. AzerothCore mod-playerbots generic reference

## 2. 감사 기준과 확인된 치파팩 상태

감사한 고정 소스:

- Runtime branch: `hilch1981-prog/MOP_V2_Repack/playerbot-v2-poc`
- Runtime HEAD: `ee21f0cd9cf8cd8da41784a02295f4dc2edc0342`
- Runtime base: `repack-main@0739d072f8f1f42523f04cca4b2607d88a01def4`
- Pinned module: `hilch1981-prog/mod-playerbots@78bc93512f8c3b26175321e98eb0bede42917ce6`

현재 브랜치는 POC-G1 Generic Module Infrastructure 단계다. `chipa_module.cmake`의 `CHIPA_MODULE_SOURCES`에는 `src/chipa/ModuleBootstrap.cpp` 한 파일만 들어 있다. 그 파일의 `Addmod_playerbotsScripts()`는 의도적으로 비어 있으며 command script를 등록하지 않는다.

고정된 submodule 안에는 기존 AzerothCore PlayerBots 소스가 존재하지만, 그 소스는 현재 Chipa manifest의 컴파일 대상이 아니다. 따라서 파일이 저장소에 존재한다는 사실을 runtime command 등록 증거로 사용할 수 없다.

현재 소스에서 확인된 결론:

| 확인 항목 | 치파팩 runtime 결과 | 판정 |
|---|---|---|
| PlayerBot command handler | 컴파일/등록되지 않음 | NOT PRESENT |
| 실제 최상위 명령 | 없음 | 미확정 |
| SelfBot attach | handler 없음 | NOT PRESENT |
| SelfBot detach | handler 없음 | NOT PRESENT |
| add/remove/list | handler 없음 | NOT PRESENT |
| 권한 레벨 | 등록 명령이 없어 적용할 권한 없음 | N/A |
| 필수/선택 인수 | 등록 명령이 없어 runtime 계약 없음 | N/A |
| 잘못된 인수 처리 | 실행 경로가 없어 검증 불가 | BLOCKED |
| G3 SelfBot | POC 문서의 목표만 존재; 구현은 시작되지 않음 | NOT STARTED |

결론: 현재 치파팩에서 실제 확인된 PlayerBot 명령은 **0개**다. `.playerbot`, `.playerbots`, `.npcbot`, `.pmon`을 AzerothAdmin command catalog나 UI 버튼에 넣으면 안 된다.

## 3. 컴파일에서 제외된 pinned module source

`hilch1981-prog/mod-playerbots@78bc935...`의 기존 upstream 파일 `src/Script/PlayerbotCommandScript.cpp`에는 다음 command table이 들어 있다.

- 최상위: `.playerbots`
- 하위: `bot`, `gtask`, `pmon`, `rndbot`, `debug bg`
- 계정: `account setKey`, `account link`, `account linkedAccounts`, `account unlink`
- 권한 표기: `bot`과 `account`은 `SEC_PLAYER`; `gtask`, `pmon`, `rndbot`, `debug bg`는 `SEC_GAMEMASTER`
- 콘솔: `bot`과 `account`은 불가; GM 계열 일부는 허용

그러나 이 파일은 현재 `CHIPA_MODULE_SOURCES`에 없으며 `Addmod_playerbotsScripts()`도 `AddPlayerbotsCommandscripts()`를 호출하지 않는다. 또한 이 코드는 AzerothCore API를 사용하는 미포팅 source다. 위 목록은 **치파팩 runtime에서 실제 확인된 명령이 아니라, submodule에 보관됐지만 컴파일에서 제외된 참고 소스**다.

특히 이 제외 소스의 `.playerbots bot`을 치파팩의 SelfBot attach/detach, add/remove/list 계약으로 간주하지 않는다.

## 4. Legends PR #389 donor command surface

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

이 목록은 donor 분석 기록이며 치파팩 runtime 등록표가 아니다. 현재 치파팩 실제 명령 0개와 섞어 쓰지 않는다.

## 5. donor 구현에서 확인된 오류

### 5.1 `addspec` 조건 반전

PR #389 계열 구현은 `tank`, `dps`, `heal`이 들어왔을 때 invalid 처리로 들어갈 수 있는 조건식이 확인되었다. 유효 역할 검증 조건을 그대로 이식하면 안 된다.

치파팩 구현 시 요구사항:

- 인자가 nil/empty면 실패
- 허용값은 명시적으로 `tank`, `heal`, `dps`
- 허용값이면 정상 경로
- 그 외 값만 invalid 처리

### 5.2 `setspec` 무인자 방어

PR #389 계열 구현은 target이 존재할 때 `charname`을 충분히 검증하지 않고 숫자 변환 경로로 넘길 수 있다.

치파팩 구현 시 요구사항:

- 인자 존재 확인
- 숫자 변환 성공 확인
- MoP specialization 범위/의미 확인
- target/player ownership 확인
- 잘못된 인자는 사용법만 반환하고 crash/undefined behavior를 만들지 않음

### 5.3 `.npcbot` 명칭

PR #389는 PlayerBot command script임에도 최상위 명령을 `.npcbot`으로 등록한다. AzerothCore 문서/다른 구현과 명칭이 다를 수 있으므로 치파팩에서 자동으로 유지하거나 `.playerbot`으로 임의 변경하지 않는다.

치파팩에서 최종 command handler가 정해진 뒤 애드온이 그 이름을 따른다. 필요하다면 서버 쪽에서 alias를 제공하되 애드온이 존재하지 않는 alias를 가정하지 않는다.

## 6. AzerothAdmin 노출 Gate 감사 결과

감사 자체는 완료했지만 노출 전제는 충족되지 않았다.

- [x] 치파팩 runtime command handler source 감사 완료 — 결과: 컴파일/등록 source 없음
- [x] 최상위 명령 감사 완료 — 결과: 실제 명령 없음
- [x] `self` attach/detach 감사 완료 — 결과: 구현 없음
- [x] add/remove/list 감사 완료 — 결과: 구현 없음
- [x] 권한 레벨 감사 완료 — 결과: runtime 명령이 없어 N/A
- [x] 필수/선택 인수 감사 완료 — 결과: runtime 계약이 없어 N/A
- [x] 잘못된 인자 방어 감사 완료 — 결과: 실행 경로가 없어 BLOCKED
- [ ] G3 SelfBot Attach/Detach 최소 구현
- [x] 정적/build 상태 기록 — POC-G1 `MODULES=0/1` whole-server build와 worldserver 산출물 확인 PASS
- [ ] boot 상태 기록 — G1-B3 worldserver boot 미확인
- [ ] human smoke regression 기록

현재 UI Gate: **CLOSED**

G1 build 성공은 command runtime 또는 G3 성공 증거가 아니다. 최소한 G1-B3 boot와 human smoke를 끝내고, G2 bridge와 G3 command handler/attach/detach가 실제로 구현·등록·검증될 때까지 PlayerBot UI를 노출하지 않는다.

## 7. 다음 감사에서 반드시 기록할 command 계약

G3 구현 PR이 생기면 다음을 구현 코드와 게임 로그에서 다시 채운다.

| 항목 | 필수 기록 |
|---|---|
| 최상위 명령 | 정확한 token과 alias |
| attach/detach | 별도 subcommand인지 toggle인지 |
| 대상 | self 고정인지 player name/target 허용인지 |
| add/remove/list | 존재 여부와 정확한 의미 |
| 권한 | 각 명령별 security level과 console 허용 |
| 인수 | 필수/선택, 타입, 허용 범위, 공백/대소문자 처리 |
| 오류 처리 | nil/empty, 잘못된 이름/숫자/역할, 중복 attach, 미attach detach |
| 소유권 | 실제 client session 유지, GM이 타 사용자에 실행 가능한지 |
| lifecycle | relog/logout/death/map change 처리 |
| 증거 | commit SHA, build, boot, game command 입력/출력 로그 |

게임 검증 전에는 UI에 `experimental` 상태를 표시하는 것만으로 부족하다. **명령 실행 컨트롤 자체를 숨긴다.**

## 8. 애드온 회귀 방지

검증 전 `.playerbot`, `.playerbots`, `.npcbot` 명령을 runtime command catalog에 임의로 추가하지 않는다. donor 또는 컴파일 제외 파일의 문자열 탐지만으로 UI를 활성화하지 않는다.

서버 POC에서 실제 command surface가 확정되면 이 문서와 정적 검증 규칙을 먼저 갱신한 별도 PlayerBot UI PR을 만든다.

## 9. 현재 분리 원칙

- 이 문서는 command 감사/게이트만 정의한다.
- R11 애드온 소스 동기화와 섞지 않는다.
- Claude/release 자동화와 섞지 않는다.
- Legends PR #389는 historical donor로만 표시한다.
- submodule의 컴파일 제외 upstream 명령은 Chipa runtime 명령으로 표시하지 않는다.
- 실제 PlayerBot UI 구현은 서버측 G3 command surface가 확인된 뒤 별도 PR로 진행한다.
