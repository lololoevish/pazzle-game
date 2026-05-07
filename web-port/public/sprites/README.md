# Пользовательские спрайты

Клади свои PNG-файлы в эту папку и указывай их в `manifest.json`.

Минимальный набор ключей:

```json
{
  "player": "player.png",
  "npcElder": "npc-elder.png",
  "npcMechanic": "npc-mechanic.png",
  "npcArchivist": "npc-archivist.png",
  "lever": "lever.png",
  "caveEntrance": "cave-entrance.png",
  "crystal": "crystal.png"
}
```

Если файл не найден или ключ пустой, игра использует встроенную цветную заглушку и не падает.

Рекомендуемый размер:

- игрок/NPC: 32x48 или 48x64;
- рычаг/кристалл: 32x32;
- вход в пещеру: 64x64 или 96x96.

После замены файлов перезапусти dev-сервер или обнови страницу с очисткой кеша.
