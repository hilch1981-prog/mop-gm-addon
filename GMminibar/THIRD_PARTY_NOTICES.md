# 출처 및 고지
기존 LICENSE와 내장 구성요소의 고지를 함께 확인하세요.


## Native UI / UX RC1 (2026-09-05)

공통 배치와 탐색 구조는 사용자 제공 `GM 패널 UI 디자인-handoff.zip`을 참고했습니다. 해당 HTML/CSS/JS, 외부 디자인 번들, 시안 폰트는 애드온에 포함하지 않았습니다. 새 Lua 구현은 각 애드온의 기존 라이선스 아래 제공됩니다.

테두리와 버튼은 사용자의 WoW 클라이언트에 있는 `Interface/DialogFrame`, `Interface/Buttons`, `Interface/QuestFrame` 리소스 경로를 참조합니다. Blizzard 원본 텍스처나 클라이언트 파일을 새로 재배포하지 않습니다.

퀘스트 창 API 검증 참고: Gethe/wow-ui-source의 Blizzard UI 소스 미러, 3.3.5 태그(c4e0255fc574598428ee1c25f160ab949798bc98), 5.4.8 태그(11b454a5a48833cf4aaf60269f289b2bacaa6dc6), FrameXML/QuestLogFrame.lua. 소스 미러는 검증 참고용이며 이 애드온에 복사하지 않았습니다.


RC2 command index: MOP_V2_Repack core 0739d072f8f1f42523f04cca4b2607d88a01def4 and its command table; AzerothCore reference 8c8ab800f4c3331bdbe25fe4ef01ffb25b0d1af8 (https://github.com/azerothcore/azerothcore-wotlk, GPL-2.0) plus the user-provided repack command table. Reference and database entries are distinguished in ServerIndex.lua. Existing upstream notices and licenses remain applicable.

## RC4 사용자 제공 참고 자료

- `260906 수정사항(1).pptx`: 사용자 제공 UI 피드백. 이미지를 애드온 리소스로 재배포하지 않음.
- `GM명령어_정리표_MOP_한글.xlsx`: 사용자가 애드온 반영을 요청한 MoP 명령 분류·설명 517행 및 핵심 편의 35행. MoP 표시 메타데이터에 사용하며 원본 권한 숫자로 서버 권한을 변경하지 않음. AzerothCore 명령 목록은 별도 유지.
