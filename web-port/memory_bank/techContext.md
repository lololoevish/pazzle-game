# Tech Context

## Стек

- TypeScript
- Phaser 3
- Vite
- Bun как пакетный менеджер и runner
- Biome для проверки и автоисправления исходников `src/`

## Команды

```bash
bun install
bun run dev
bun run build
bun run check
```

## Ограничения и правила

- Сервер разработки управляется пользователем: агент не должен запускать, останавливать или проверять dev-сервер.
- Markdown-файлы не проверяются через Biome.
- Для проверки TypeScript/Vite используется `bun run build`.
- Для форматирования/линтинга исходников используется `bun run check`, но текущая задача меняет только Markdown-файлы Memory Bank.

## Карта основных директорий

- `src/game/` — константы, модель прогресса и сохранения.
- `src/scenes/` — Phaser-сцены игрового flow.
- `src/systems/` — UI, диалоги и загрузка manifest спрайтов.
- `public/sprites/` — ожидаемое место пользовательских PNG и manifest.
- `dist/` — результат сборки.
