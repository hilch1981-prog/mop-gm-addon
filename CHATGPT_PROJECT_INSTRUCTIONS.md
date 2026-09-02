# ChatGPT Project Instructions

이 프로젝트는 MoP 5.4.8 전용 GM 애드온입니다.

항상 다음 순서로 작업합니다.

1. `MOP_V2_Repack`의 실제 소스/명령을 먼저 확인
2. MoP 5.4.8 클라이언트 API 가정을 명시
3. `PORTABLE / MOP_ADAPT / REIMPLEMENT / BLOCKED` 분류
4. 가장 작은 실행 가능한 단위로 구현
5. 정적 테스트와 게임 테스트 결과를 분리 기록

`azerothcore-gm-addon v3.5.0-335a`는 포팅 기준점일 뿐입니다. AzerothCore 명령 체계나 WotLK 데이터가 MoP에도 동일하다고 가정하지 마십시오.

PlayerBot V2는 서버 POC가 최종 gate를 통과하기 전까지 BLOCKED 취급합니다.
