# Architecture Decisions

## ADR-001: Separate repository

MoP GM addon은 WotLK addon 및 server repack과 독립 저장소로 관리합니다.

## ADR-002: Runtime addon folder name

실제 클라이언트 설치 폴더는 `AzerothAdmin/`으로 통일합니다. 저장소 이름이 `mop-gm-addon`이므로 WotLK 저장소와 충돌하지 않습니다.

## ADR-003: WotLK data is reference only

3.3.5a 데이터는 MoP용 사실 데이터로 간주하지 않습니다.

## ADR-004: Server command source wins

버튼/입력창의 명령은 치파 MoP 서버 소스의 실제 CommandScript 정의가 정본입니다.

## ADR-005: PlayerBot disabled until runtime proof

PlayerBot V2는 build만으로 활성화하지 않습니다. worldserver boot, human smoke 및 후속 POC gate 증거가 필요합니다.
