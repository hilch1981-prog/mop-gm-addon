# Development Rules

## Branch policy

- `main`: 통합 기준선
- `port/<module>`: 모듈 포팅
- `fix/<module>-<problem>`: 버그 수정
- `docs/<topic>`: 문서 전용

## PR checklist

각 PR은 최소한 다음을 기록합니다.

- WotLK reference feature
- MoP server evidence
- MoP client API assumptions
- static test result
- in-game test result
- known limitations

## Data policy

다음은 MoP용으로 재검증/재생성해야 합니다.

- quest rewards / quest drop sources
- item classification
- profession recipe data
- NPC/creature datasets
- teleport datasets
- Korean search aliases

## Command policy

명령은 실제 MoP 소스에서 명령 문자열과 security level을 확인한 경우에만 `verified`로 표시합니다.

## PlayerBot policy

PlayerBot V2는 서버측 POC gate와 command contract가 확정된 뒤에만 애드온 제어를 활성화합니다. Draft PR 상태만으로 완료 처리하지 않습니다.
