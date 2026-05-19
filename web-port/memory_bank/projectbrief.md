# Project Brief

## Цель проекта

Adventure Puzzle Game — Web Port — самостоятельная playable-версия приключенческой puzzle-игры на Phaser 3 и TypeScript, запускаемая в браузере без GameMaker Studio 2.

## Рамки проекта

- Браузерная игра с меню, городом-хабом, пещерами-пазлами и финальным экраном победы.
- Управление должно быть полностью доступно с клавиатуры: WASD/стрелки, E/Space, Esc.
- Прогресс игрока хранится локально в `localStorage`.
- Пользовательские спрайты подключаются через `public/sprites/manifest.json`; при отсутствии файлов используются заглушки.

## Project Deliverables

| ID | Deliverable | Status | Weight |
| --- | --- | --- | --- |
| PR-01 | Runnable Phaser 3 + TypeScript web-port with Vite/Bun build flow | completed | 15 |
| PR-02 | Keyboard-first menu, hub navigation and scene flow | completed | 15 |
| PR-03 | Town hub with NPC rewards, collision and cave entrance | completed | 15 |
| PR-04 | 24-level cave progression with puzzle mechanics and completion flow | completed | 25 |
| PR-05 | Persistent localStorage save/reset/continue system | completed | 10 |
| PR-06 | Custom sprite manifest loading with fallback placeholders and help screen | completed | 10 |
| PR-07 | Victory screen and documented run/check workflow | completed | 10 |

Арифметическая самопроверка Weight: 15 + 15 + 15 + 25 + 10 + 10 + 10 = 100.

## Источники scope

- `README.md` — текущий пользовательский README проекта и временный источник высокоуровневого описания, так как `docs/README.md` отсутствует.
- Фактическая структура кода в `src/`.
