AzerothAdminMoP = AzerothAdminMoP or {}
local AAM = AzerothAdminMoP

local locale = GetLocale and GetLocale() or "enUS"
local packs = {
  enUS = { title="AzerothAdmin MoP", subtitle="MoP 5.4.8 / Build 18414", arg="Argument", send="Send", raw="Raw command", search="Filter", ready="Ready", sent="Sent", categories="Categories", note="Commands are matched to MOP_V2_Repack source.", minimapTitle="AzerothAdmin MoP", minimapLeft="Left click: GM panel", minimapRight="Right click: Teleports", minimapMiddle="Middle click: Favorite teleports", minimapDrag="Drag: Move icon", favoriteAdded="Favorite added", favoriteRemoved="Favorite removed" },
  koKR = { title="AzerothAdmin MoP", subtitle="판다리아 5.4.8 / 빌드 18414", arg="인수", send="전송", raw="직접 명령", search="필터", ready="준비", sent="전송", categories="분류", note="MOP_V2_Repack 소스의 명령 체계에 맞춘 버전입니다.", minimapTitle="AzerothAdmin MoP", minimapLeft="왼쪽 클릭: GM 패널", minimapRight="오른쪽 클릭: 순간이동 목록", minimapMiddle="가운데 클릭: 즐겨찾기 순간이동", minimapDrag="드래그: 아이콘 이동", favoriteAdded="즐겨찾기 등록", favoriteRemoved="즐겨찾기 해제" },
  zhCN = { title="AzerothAdmin MoP", subtitle="熊猫人之谜 5.4.8 / 18414", arg="参数", send="发送", raw="直接命令", search="筛选", ready="就绪", sent="已发送", categories="分类", note="命令已按 MOP_V2_Repack 源码适配。", minimapTitle="AzerothAdmin MoP", minimapLeft="左键：GM面板", minimapRight="右键：传送列表", minimapMiddle="中键：收藏传送", minimapDrag="拖动：移动图标", favoriteAdded="已添加收藏", favoriteRemoved="已移除收藏" },
  zhTW = { title="AzerothAdmin MoP", subtitle="潘達利亞 5.4.8 / 18414", arg="參數", send="傳送", raw="直接指令", search="篩選", ready="就緒", sent="已傳送", categories="分類", note="指令已依 MOP_V2_Repack 原始碼調整。", minimapTitle="AzerothAdmin MoP", minimapLeft="左鍵：GM面板", minimapRight="右鍵：傳送列表", minimapMiddle="中鍵：收藏傳送", minimapDrag="拖曳：移動圖示", favoriteAdded="已加入收藏", favoriteRemoved="已移除收藏" },
  ruRU = { title="AzerothAdmin MoP", subtitle="Pandaria 5.4.8 / 18414", arg="Аргумент", send="Отправить", raw="Команда", search="Фильтр", ready="Готово", sent="Отправлено", categories="Категории", note="Команды сверены с исходниками MOP_V2_Repack.", minimapTitle="AzerothAdmin MoP", minimapLeft="ЛКМ: панель GM", minimapRight="ПКМ: телепорты", minimapMiddle="СКМ: избранные телепорты", minimapDrag="Перетащить: переместить значок", favoriteAdded="Добавлено в избранное", favoriteRemoved="Удалено из избранного" },
}
AAM.L = packs[locale] or packs.enUS
