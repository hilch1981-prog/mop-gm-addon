# PlayerBot Command Audit

기준일: 2026-09-06

## 1. 적용 대상

이 문서는 `AzerothAdmin` MoP 5.4.8 포트에서 PlayerBot 버튼/명령을 추가하기 전에 확인해야 할 command compatibility 기록이다. 런타임 namespace는 `AzerothAdminMoP548`을 기준으로 한다.

정본 우선순위:

1. `hilch1981-prog/MOP_V2_Repack` 실제 runtime 구현
2. `MOP_V2_Repack/playerbot-v2-poc` 실제 POC 구현
3. `hilch1981-prog/mod-playerbots`의 Chipa manifest에 실제 포함된 source
4. DigiD702 MoP donor/reference
5. Legends of Azeroth PR #389 historical reference
6. AzerothCore mod-playerbots generic reference

핵심 원칙: 저장소 또는 submodule에 파일이 존재하는 것과 Chipa runtime에 그 파일이 컴파일/등록되는 것은 다르다. `chipa_module.cmake`의 실제 source closure와 loader 호출이 우선이다.

## 2. 2026-09-06 현재 감사 고정점

감사한 소스:

- Runtime branch: `hilch1981-prog/MOP_V2_Repack/playerbot-v2-poc`
- Runtime HEAD: `0086d0a9352022c41e348158573c918c77e05e42`
- Runtime base: `repack-main@0739d072f8f1f42523f04cca4b2607d88a01def4`
- Submodule repository: `hilch1981-prog/mod-playerbots`
- Submodule configured branch: `mop-5.4.8-v2`
- Runtime-pinned module commit: `8d5eceebe94e6514a959115063943896424a8281`

현재 `chipa_module.cmake`가 Chipa runtime에 포함하는 파일은 다음 5개뿐이다.

- `src/chipa/ModuleBootstrap.cpp`
- `src/chipa/PlayerLifecycleBridge.cpp`
- `src/chipa/PlayerUpdateBridge.cpp`
- `src/chipa/PlayerUpdateAdapter.cpp`
- `src/chipa/PlayerUpdateScript.cpp`

반대로 아래 기존 upstream 명령 구현은 **현재 Chipa runtime source closure에 포함되지 않는다.**

- `src/Script/PlayerbotCommandScript.cpp`
- `src/Bot/PlayerbotMgr.cpp`
- `src/Bot/RandomPlayerbotMgr.cpp`

`Addmod_playerbotsScripts()`는 현재 Chipa update adapter와 `PlayerScript` bridge를 등록하지만 `AddPlayerbotsCommandscripts()`를 호출하지 않는다. 따라서 upstream command table이 submodule에 남아 있어도 Chipa runtime command 등록 증거가 아니다.

## 3. 현재 치파팩 runtime command 감사 결과

| 확인 항목 | 현재 Chipa runtime 결과 | 판정 |
|---|---|---|
| PlayerBot command handler | manifest에 command script 미포함 | NOT PRESENT |
| 실제 최상위 PlayerBot 명령 | 등록 source 없음 | NONE / 미확정 |
| SelfBot attach 명령 | 등록 source 없음 | NOT PRESENT |
| SelfBot detach 명령 | 등록 source 없음 | NOT PRESENT |
| add/remove/list 명령 | 등록 source 없음 | NOT PRESENT |
| runtime command 권한 | 등록 명령 없음 | N/A |
| runtime 필수/선택 인수 | 등록 명령 없음 | N/A |
| runtime 잘못된 인수 처리 | 실행 경로 없음 | BLOCKED |
| PlayerScript login/logout/update bridge | source closure에 포함 | SOURCE PRESENT |
| PlayerBot backend 연결 | donor backend가 manifest에 미포함 | NOT PRESENT |
| G3 SelfBot command surface | 확인된 등록 경로 없음 | NOT PRESENT |

결론: **현재 치파팩 runtime에서 실제로 확인된 PlayerBot 채팅 명령은 0개다.**

`.playerbot`, `.playerbots`, `.npcbot`, `.pmon`을 AzerothAdmin command catalog 또는 실행 버튼에 넣으면 안 된다.

## 4. 현재 Chipa bridge에서 실제로 확인된 범위

현재 bootstrap은 다음 경로를 등록한다.

```text
Addmod_playerbotsScripts()
  -> RegisterPlayerUpdateAdapter()
  -> AddChipaPlayerbotUpdateScript()
```

`ChipaPlayerbotUpdateScript`는 `OnLogin`, `OnLogout`, `OnUpdate`를 Chipa bridge로 전달한다. `PlayerUpdateAdapter`는 `isManagedPlayer` backend callback이 없거나 false면 즉시 return하도록 되어 있어 일반 human player가 AI 경로로 들어가지 않는 G2 형태의 방어 구조는 source에 존재한다.

하지만 현재 manifest에는 실제 donor `PlayerbotMgr` backend나 command registration source가 포함되지 않는다. 따라서 이 상태를 G3 SelfBot attach/detach 구현 완료 또는 command runtime PASS로 해석하지 않는다.

## 5. 컴파일에서 제외된 pinned upstream command source

`hilch1981-prog/mod-playerbots@8d5ecee...`의 제외 소스 `src/Script/PlayerbotCommandScript.cpp`에는 다음 command tree가 존재한다.

### 5.1 top-level tree - 참고 전용

- `.playerbots bot ...` — `SEC_PLAYER`, console 불가
- `.playerbots gtask ...` — `SEC_GAMEMASTER`, console 허용
- `.playerbots pmon ...` — `SEC_GAMEMASTER`, console 허용
- `.playerbots rndbot ...` — `SEC_GAMEMASTER`, console 허용
- `.playerbots debug bg ...` — `SEC_GAMEMASTER`, console 허용
- `.playerbots account setKey ...` — `SEC_PLAYER`, console 불가
- `.playerbots account link ...` — `SEC_PLAYER`, console 불가
- `.playerbots account linkedAccounts` — `SEC_PLAYER`, console 불가
- `.playerbots account unlink ...` — `SEC_PLAYER`, console 불가

위 목록은 **현재 Chipa runtime 명령이 아니다.** 현재 manifest가 해당 command script를 컴파일하지 않는다.

### 5.2 `.playerbots bot` manager subcommand - 참고 전용

제외된 `PlayerbotMgr.cpp`에서 확인되는 manager command:

- `list`
- `reload`
- `tweak`
- `self`
- `lookup`
- `add <PLAYERNAME>`
- `addaccount <ACCOUNT_OR_CHARACTER>`
- `remove <PLAYERNAME>` / `logout` / `rm`
- `addclass <CLASSNAME> [male|female|0|1]`
- `initself`
- `initself=<uncommon|rare|epic|legendary|GS>`
- bot init/refresh/random/quests 계열

### 5.3 `self` 동작 - 참고 전용

제외된 upstream manager에서 `self`는 별도의 attach/detach token 두 개가 아니라 **toggle**이다.

- 현재 player에 `PlayerbotAI`가 있으면 delete하여 비활성화
- 없으면 `selfBotLevel` 설정/GM 권한 조건을 확인한 뒤 Playerbot data/AI를 추가하고 master를 자기 자신으로 지정

이 동작은 Chipa G3 계약으로 확정된 것이 아니다. 현재 Chipa runtime에는 이 manager가 등록/컴파일되지 않는다.

### 5.4 add/remove/list 및 인수 처리 - 참고 전용

- `list`는 bot roster를 반환한다.
- `add`는 player name을 정규화/조회한 뒤 `AddPlayerBot` 경로를 사용한다.
- `addaccount`는 account 또는 character에서 account를 찾고 그 account의 characters를 대상으로 한다.
- `remove/logout/rm`은 대상이 online이고 자신의 bot인지 확인한 뒤 logout한다.
- character 인수가 없으면 현재 player target이 player일 때 target name을 사용하고, 그렇지 않으면 usage를 반환한다.
- comma-separated character names를 허용한다.
- `*`는 group member 집합을 대상으로 하는 경로가 있다.
- `addclass`는 class name과 optional gender를 파싱한다.

이 역시 **컴파일 제외 upstream reference**이며 현재 Chipa addon 버튼 계약으로 사용하지 않는다.

## 6. Legends PR #389 donor command surface

Historical PR #389 계열은 별도의 donor다. 여기서 확인된 최상위 명령은 `.npcbot`이며, manager help에는 `list/reload/tweak/self`, `add/init/remove`, `addclass` 등이 존재한다.

이 donor surface와 pinned upstream `.playerbots` surface는 서로 다른 계열이다. 둘 중 어느 것도 현재 Chipa runtime command로 승격되지 않았다.

Donor 명령을 치파팩에 임의로 alias 처리하거나 AzerothAdmin 버튼에 하드코딩하지 않는다.

## 7. 문서 드리프트 주의

`MOP_V2_Repack/docs/playerbots/POC_SPEC.md`와 기존 `G1_BUILD_EVIDENCE.md` 일부는 이전 pinned module `78bc935...` 및 이전 source closure를 설명한다. 2026-09-06 현재 branch pin은 `8d5ecee...`이며 manifest도 5개 Chipa bridge source로 확장됐다.

따라서 POC 문서의 frozen G1 설명은 역사적 Gate 기준으로 보존하되, **현재 코드 감사에는 branch HEAD + gitlink + `chipa_module.cmake`를 우선한다.**

현재 HEAD `0086d0a...`에 대한 최신 Actions run은 감사 시점에 진행 중이었으므로, 이 문서에서는 현재 snapshot의 BUILD/BOOT/RUNTIME/GAME PASS를 새로 주장하지 않는다.

## 8. AzerothAdmin 노출 Gate 감사 결과

감사 자체는 최신 source 기준으로 완료했지만 UI 노출 전제는 충족되지 않았다.

- [x] 현재 runtime gitlink 확인 — `8d5ecee...`
- [x] 실제 Chipa manifest source closure 확인 — 5개 bridge source
- [x] command registration source 포함 여부 확인 — 미포함
- [x] 실제 최상위 명령 감사 — 없음
- [x] `self` attach/detach runtime 감사 — 없음
- [x] add/remove/list runtime 감사 — 없음
- [x] runtime 권한/인수 감사 — 등록 명령이 없어 N/A
- [x] donor/pinned upstream command와 Chipa runtime 분리
- [ ] G3 SelfBot attach/detach 구현 및 실제 등록
- [ ] 최종 command contract 확정
- [ ] current HEAD clean build PASS 기록
- [ ] worldserver boot PASS 기록
- [ ] 실제 command runtime/game 입력·출력 검증
- [ ] human smoke/regression 기록

현재 PlayerBot UI Gate: **CLOSED**

게임 검증 전에는 `experimental` 표시만 붙여 실행 버튼을 노출하는 것도 금지한다. 실제 command surface가 Chipa runtime에 등록되고 검증될 때까지 실행 컨트롤 자체를 숨긴다.

## 9. G3 이후 반드시 기록할 command 계약

G3 command handler가 실제 Chipa manifest와 loader에 들어오면 다음을 구현 코드와 게임 로그에서 다시 채운다.

| 항목 | 필수 기록 |
|---|---|
| 최상위 명령 | 정확한 token과 alias |
| attach/detach | 별도 subcommand인지 toggle인지 |
| 대상 | self 고정인지 player name/target 허용인지 |
| add/remove/list | 존재 여부와 정확한 의미 |
| 권한 | 각 명령별 security level과 console 허용 |
| 인수 | 필수/선택, 타입, 허용 범위, 공백/대소문자 처리 |
| 오류 처리 | empty, 잘못된 이름/숫자/역할, 중복 attach, 미attach detach |
| 소유권 | 실제 client session 유지, GM의 타 사용자 실행 허용 여부 |
| lifecycle | relog/logout/death/map change 처리 |
| 증거 | runtime SHA, module SHA, build, boot, 게임 command 입력/출력 로그 |

## 10. 회귀 방지 원칙

- `.playerbot`, `.playerbots`, `.npcbot`을 runtime command catalog에 추정으로 추가하지 않는다.
- donor 또는 컴파일 제외 파일의 문자열 탐지만으로 UI를 활성화하지 않는다.
- R11 애드온 소스 동기화와 command 감사 PR을 섞지 않는다.
- Legends PR #389는 historical donor로만 표시한다.
- submodule의 컴파일 제외 upstream 명령은 Chipa runtime 명령으로 표시하지 않는다.
- 실제 PlayerBot UI 구현은 서버측 G3 command surface가 manifest/loader에 들어오고 runtime 검증된 뒤 별도 PR로 진행한다.
