#!/usr/bin/env python3
from pathlib import Path
import hashlib

root = Path('AzerothAdmin')

replacements = {
    root / 'AzerothAdmin.toc': [
        ('## Version: 3.5.0-548-r10-feedback-rc10', '## Version: 1.0.0'),
        ('## X-Test-Build-Date: 2026-09-04', '## X-Release-Date: 2026-09-04'),
        ('## X-Release-Channel: prerelease', '## X-Release-Channel: stable'),
    ],
    root / 'Framework/Bootstrap.lua': [
        ('A.version = "3.5.0-548-r10-feedback-rc10"', 'A.version = "1.0.0"'),
    ],
    root / 'Data/MoP/SourceInfo.lua': [
        ('release = "3.5.0-548-r10-feedback-rc10"', 'release = "1.0.0"'),
    ],
    root / 'Modules/Verification/StaticChecks.lua': [
        ('version = "3.5.0-548-r10-feedback-rc10"', 'version = "1.0.0"'),
    ],
}
for path, pairs in replacements.items():
    text = path.read_text(encoding='utf-8')
    for old, new in pairs:
        if old not in text:
            raise SystemExit(f'missing promotion marker in {path}: {old}')
        text = text.replace(old, new)
    path.write_text(text, encoding='utf-8', newline='\n')

readme = root / 'README_KR.txt'
text = readme.read_text(encoding='utf-8')
text = text.replace('AzerothAdmin 3.5.0-548-r10-feedback-rc10', 'AzerothAdmin 1.0.0', 1)
readme.write_text(text, encoding='utf-8', newline='\n')

toc = root / 'AzerothAdmin.toc'
text = toc.read_text(encoding='utf-8')
marker = '## X-Release-Channel: stable\n'
if '## X-Release-Tag: v1.0.0' not in text:
    text = text.replace(marker, marker + '## X-Release-Tag: v1.0.0\n## X-Release-Source: R10 game-tested candidate\n', 1)
toc.write_text(text, encoding='utf-8', newline='\n')

notes = Path('docs/releases/v1.0.0')
notes.mkdir(parents=True, exist_ok=True)
(notes / 'RELEASE_NOTES.md').write_text('''# AzerothAdmin MoP 5.4.8 v1.0.0

첫 공식 안정 릴리즈입니다.

## 기준

- Client: WoW MoP 5.4.8 Build 18414 / Interface 50400
- Canonical UI: AzerothAdmin 3.5.0-335a
- Server authority: MOP_V2_Repack
- Server baseline: 0739d072f8f1f42523f04cca4b2607d88a01def4
- Operator access value used in the game-tested environment: 9
- Source candidate: R10 game-tested build

## 주요 기능

- 정본형 GM 메뉴, 미니바, 미니맵 버튼, 뒤로가기와 다국어 전환
- 아이템 80,072개, 퀘스트 18,144개, 크리처 57,526개
- 서버 game_tele 1,602개 중 ScottTest 제외 1,601개 선택 가능
- 순간이동 한국어 표시, 대륙/지역·목적지·레벨·진영 정렬, 내 진영 필터, 즐겨찾기
- 퀘스트 시작/종료/목표 이동과 현지화 이름 기반 NPC·오브젝트·아이템 찾기
- 전문기술 11종, 제작법 5,129개, 재료 연결 11,461개, 숙련도/학습 제한과 결과 아이콘
- 아이템 검색 + 접이식 상세 종류/등급 필터

## R8-R10 게임 피드백 반영

- 동일 미니바 아이콘 재클릭 시 창 닫기
- 짧은 메인 정보줄과 배포일자 표시
- 서버 재시작/종료 계열 명령 기본 숨김
- Quest ID 기반 선택/목표 이동 stale-state 차단
- AreaTable.csv를 보강 자료로 사용하되 기존 의미 있는 한글화 보존
- 위험한 ScottTest 순간이동 제외
- 순간이동 표 열 정렬, UTF-8 ellipsis, 내 진영만 필터
- 전문기술 제작 결과 아이콘 우선 표시 및 InvenCraftInfo2 화면 브랜드 문구 제거

## 알려진 제한

- PlayerBot 조작은 서버 기능 검증 전까지 비활성입니다.
- 활성 스폰/신뢰할 좌표가 없는 스크립트 전용 퀘스트는 이동 버튼이 비활성일 수 있습니다.
- 권위 있는 한글명이 확인되지 않는 서버 전용 teleport 별칭은 기존 검증된 표기를 유지합니다.
''', encoding='utf-8', newline='\n')
(notes / 'R10_GAME_TEST_ACCEPTANCE.md').write_text('''# R10 game-test acceptance

Date: 2026-09-04

R10 was explicitly accepted by the project owner for GitHub synchronization and stable release after iterative in-game testing from R4 through R10.

The stable promotion changes release metadata only; runtime behavior is the accepted R10 candidate.
''', encoding='utf-8', newline='\n')

manifest = root / 'FILE_MANIFEST.sha256'
lines = []
for path in sorted(p for p in root.rglob('*') if p.is_file() and p != manifest):
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    lines.append(f'{digest}  {path.relative_to(root).as_posix()}')
manifest.write_text('\n'.join(lines) + '\n', encoding='utf-8', newline='\n')
print(f'PROMOTE_METADATA_PASS manifest={len(lines)}')
