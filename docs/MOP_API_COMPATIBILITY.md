# MoP 5.4.8 API Compatibility

Target: Build 18414 / Interface 50400.

## P0 API surface

의도적으로 작은 API만 사용합니다.

- `CreateFrame`
- `UIParent`
- `GetLocale`
- `SendChatMessage`
- `SlashCmdList`
- 기본 Frame/Button/EditBox API
- `GameFontNormal`, `GameFontNormalLarge`

## Later audits

### Items

- `GetItemInfo`
- item hyperlink parsing
- tooltip population/cache timing

### Professions

5.4.8 tradeskill API를 실제 클라이언트에서 확인한 뒤 WotLK embedded 구현을 가져옵니다.

### Map / coordinates

WotLK map assumptions를 복사하지 않고 Pandaria 포함 5.4.8 map/zone ID를 재검증합니다.

### Bank

기본 BankFrame과 서버측 remote-bank 동작을 실게임에서 검증합니다.

### Protected actions

애드온 자동화가 보호 동작에 걸리는지 실제 5.4.8 클라이언트에서 확인합니다.

정적 API 이름 일치만으로 PASS 처리하지 않습니다.
