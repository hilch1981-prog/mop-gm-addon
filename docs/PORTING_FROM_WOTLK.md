# Porting from WotLK AzerothAdmin

Reference: `azerothcore-gm-addon v3.5.0-335a`

| WotLK module | MoP class | Decision |
|---|---|---|
| Framework / registry | PORTABLE | 구조 개념 이식 |
| Language | PORTABLE | enUS fallback 유지, koKR 우선 |
| Shell | MOP_ADAPT | UI 패턴 이식 후 5.4.8 테스트 |
| Commands | MOP_ADAPT | MoP command source에서 재생성 |
| Teleports | MOP_ADAPT | UI 이식, 데이터 재검증 |
| Search | MOP_ADAPT | UI 이식, lookup/data 재검증 |
| Creatures | REIMPLEMENT | Pandaria 데이터 재구축, 실패한 3D preview는 복원하지 않음 |
| QuestHelper | REIMPLEMENT | 3.3.5 quest/drop 데이터 사용 금지 |
| ItemBrowser | REIMPLEMENT | WotLK 분류/QuestRewards335 사용 금지 |
| ProfessionInfo | REIMPLEMENT | 5.4.8 tradeskill API와 데이터 재검증 |
| Bank | MOP_ADAPT | MoP bank/session 흐름 검증 |
| Revive | MOP_ADAPT | MoP 명령/타깃 처리 검증 |
| Integrations | REIMPLEMENT | embedded addon/library 별도 감사 |
| PlayerBot | BLOCKED | server POC runtime gate 완료 후 진행 |

## Explicitly unsafe to copy as MoP truth

- `QuestRewards335.lua`
- WotLK creature datasets
- WotLK teleport datasets
- WotLK profession recipe databases
- AzerothCore DB `command` dump 기반 metadata
