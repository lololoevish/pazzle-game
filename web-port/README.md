# Adventure Puzzle Game — Web Port

Это отдельная playable-копия игры на Phaser 3 + TypeScript. Она не требует GameMaker Studio 2.

## Запуск

```bash
cd web-port
bun install
bun run dev
```

Открой адрес, который покажет Vite, обычно `http://localhost:5173`.

## Управление

Игра проходится без мышки:

- `WASD` / стрелки — движение героя;
- `E` / `Space` — взаимодействие;
- `Esc` — назад в хаб/меню.

В пещерах не нужно кликать по элементам пазла. Подведи героя к объекту пазла или рычагу и нажми `E`/`Space`.

Герой больше не проходит сквозь стены: в хабе и пещерах есть физические препятствия. Проходы работают автоматически — если герой заходит во вход/выход, сцена меняется без отдельного нажатия.

## Свои спрайты

1. Положи PNG-файлы в:

```text
web-port/public/sprites/
```

2. Открой:

```text
web-port/public/sprites/manifest.json
```

3. Пропиши имена файлов:

```json
{
  "player": "my-player.png",
  "npcElder": "elder.png",
  "npcMechanic": "mechanic.png",
  "npcArchivist": "archivist.png",
  "lever": "lever.png",
  "caveEntrance": "cave.png",
  "crystal": "crystal.png"
}
```

Если файл не указан или не найден, игра использует цветную заглушку.

## Что уже есть

- меню;
- хаб-город;
- 3 NPC с наградами;
- 24-уровневая модель прогресса;
- сохранение в `localStorage`;
- пещеры с более близкими к GMS2 механиками: лабиринт со стенами, поиск слов, ритм/паттерн и memory match;
- victory screen после 24-й пещеры;
- система подключения пользовательских спрайтов через manifest.

## Проверка

```bash
bun run build
bun run check
```
