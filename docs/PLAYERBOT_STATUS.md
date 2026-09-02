# PlayerBot V2 Status

Addon status: `BLOCKED_ON_POC`

## Current server POC

- Repository: `hilch1981-prog/MOP_V2_Repack`
- Draft PR: `#1`
- POC branch: `playerbot-v2-poc`
- PlayerBot hub: `hilch1981-prog/mod-playerbots`
- Module branch: `mop-5.4.8-v2`
- POC module pin documented in PR: `78bc93512f8c3b26175321e98eb0bede42917ce6`

## Verified gate state

- Source integration: PORTED
- Static architecture inspection: PASS
- G1-B1 `MODULES=0` clean build: PASS
- G1-B2 `MODULES=1` clean build: PASS
- G1-B3 worldserver boot: PENDING
- Human login/movement/basic combat smoke: PENDING
- PR: Draft / merge prohibited

## Addon consequence

PlayerBot 탭은 상태를 보여주기 위해 존재하지만 실제 동작 버튼은 비활성화합니다.

## Enable criteria

1. G1-B3 boot PASS
2. human smoke PASS
3. 필요한 후속 POC gate PASS
4. 최종 command/control contract 확정
5. security level 문서화
6. attach/detach/ownership 동작 검증
7. crash/memory regression 검증
