# Project Status

Updated: 2026-09-02

## Repository reset

`main`의 기존 파일 트리는 2026-09-02에 MoP 전용 기준으로 전면 재정의했습니다.

리셋 직전 상태는 `archive/pre-reset-20260902` 브랜치에 보존되어 있습니다.

## Baselines

### WotLK reference

- Repository: `hilch1981-prog/azerothcore-gm-addon`
- Latest verified release: `v3.5.0-335a`
- Client: WotLK 3.3.5a Build 12340
- Interface: 30300

### MoP target

- Repository: `hilch1981-prog/MOP_V2_Repack`
- Branch: `repack-main`
- Baseline: `0739d072f8f1f42523f04cca4b2607d88a01def4`
- Client: MoP 5.4.8 Build 18414
- Interface: 50400

## P0 bootstrap

- [x] clean repository definition
- [x] MoP TOC / Interface 50400
- [x] isolated SavedVariables
- [x] localization foundation (enUS / koKR)
- [x] basic shell and `/aamop`
- [x] verified `.gm` controls
- [x] `.tele` input
- [x] `.lookup item/creature/quest` input
- [x] PlayerBot status panel (disabled)
- [x] static validation script
- [x] GitHub Actions static workflow
- [ ] actual MoP client load test
- [ ] actual in-game command smoke test

## PlayerBot V2

Target server Draft PR #1: `[PB-V2][POC-G1] Bootstrap generic module loader and source baseline`

Current verified state:

- Source integration: PORTED
- Architecture/static inspection: STATIC_PASS
- G1-B1 MODULES=0 clean build: PASS
- G1-B2 MODULES=1 clean build: PASS
- G1-B3 worldserver boot: PENDING
- Human smoke regression: PENDING
- PR state: Draft / merge prohibited

Therefore addon PlayerBot actions remain disabled.
