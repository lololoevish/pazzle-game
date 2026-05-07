# Adventure Puzzle Game - Tech Context

## Окружение

### Разработка

- ОС: Windows (`win32`)
- Shell: PowerShell
- Git-ветка: `main`
- Основной проект: `pazzle-game-gamemaker/`
- Альтернативный runnable-порт: `web-port/`
- Исторический референс: `src_rust/`
- Основной редактор/IDE: VS Code и инструменты GameMaker Studio 2

### Ключевая технология

- Основная целевая среда: GameMaker Studio 2
- Основной язык продуктовой логики: GML
- Альтернативный web runtime: Phaser 3 + TypeScript + Vite
- Формальная проверка `.gml` через `Biome` недоступна в текущей конфигурации

## Структура проекта

```text
pazzle-game/
├── pazzle-game-gamemaker/        # Основной код GameMaker Studio 2
│   ├── objects/                  # Игровые объекты
│   ├── scripts/                  # GML-скрипты и puzzle logic
│   ├── rooms/                    # Комнаты меню, хаба, пещер и финала
│   ├── dialogues/                # Диалоговые деревья
│   ├── assets/                   # Конфиги и игровые ассеты GMS2
│   └── test_scenarios/           # Ручные и полуавтоматические сценарии проверки
├── web-port/                     # Phaser 3 web-port без GameMaker
│   ├── public/sprites/           # Пользовательские PNG и manifest.json
│   └── src/                      # TypeScript scenes, systems, progress/save model
├── src_rust/                     # Историческая референс-ветка
├── docs/                         # Архитектура, ТЗ, тестовая документация
├── memory_bank/                  # Операционная документация проекта
└── plans/                        # Плановые и вспомогательные материалы
```

## Основные технические подсистемы

1. `scr_game_state.gml` - прогресс, глобальные структуры, целевой маршрут.
2. `scr_save_system.gml` - сохранение, загрузка, reset, конвертация состояния.
3. `scr_audio_manager.gml` - музыка, SFX, контексты и приоритеты.
4. `scr_ui_manager.gml` - HUD, уведомления и сервисные оверлеи.
5. `scr_vn_*.gml` - портреты, печать текста и диалоговый слой.
6. `scr_puzzle_manager.gml` и puzzle-скрипты - маршрутизация и реализация 12 пазлов.
7. `web-port/src/game/*` - TypeScript-модель 24-уровневого прогресса и localStorage save system.
8. `web-port/src/scenes/*` - Phaser scenes для меню, хаба, пещер и победы.
9. `web-port/src/systems/SpriteManifest.ts` - подключение пользовательских спрайтов из `public/sprites/manifest.json` с fallback-заглушками.
10. `web-port/src/scenes/CaveScene.ts` - keyboard-only пещерные прототипы, где герой взаимодействует с объектами пазла и рычагом через `E`/`Space`.
11. `web-port/src/scenes/TownScene.ts` и `CaveScene.ts` - Arcade Physics static collision walls и auto-overlap зоны переходов между хабом и пещерами.

## Проверка качества

- Для Markdown-файлов `Biome` не применяется по правилам проекта.
- Для `.gml` автоматический линтинг отсутствует.
- Основная верификация опирается на чтение кода, актуальность документации и ручные/полуавтоматические сценарии из `pazzle-game-gamemaker/test_scenarios/`.
- Для `web-port/` доступны `bun run check` и `bun run build` внутри `web-port/`.
- Сервер разработки не управляется агентом и не должен запускаться, останавливаться или проверяться.

## Сборка и запуск

- Основной runtime и сборка выполняются средствами GameMaker Studio 2.
- Альтернативный web-port запускается командами `bun install` и `bun run dev` из `web-port/`; production build - `bun run build`.
- Репозиторий содержит сопутствующие исторические Rust-материалы, но они не считаются основной исполняемой целью.
- В рамках этой синхронизации не вводится новый CI/CD-пайплайн и не меняется процесс пользовательского запуска.

## Ограничения

1. В проекте остаются legacy-следы прошлой 6-уровневой модели.
2. Крупные GML-скрипты повышают риск регрессий при локальных изменениях.
3. Формальный автоматический линтинг и unit-runner для GML сейчас отсутствуют.
4. Phaser web-port пока не покрывает весь финальный контент GMS2, а даёт runnable skeleton с прототипами пазлов и заменяемыми спрайтами.

## Связанные документы

- `docs/README.md` - каноническая верхнеуровневая архитектура.
- `docs/gms2_architecture.md` - детали структуры GMS2-проекта.
- `docs/gms2_testing_strategy.md` - стратегия тестирования.
- `docs/gms2_unit_test_scenarios.md` - сценарии модульной проверки.
- `web-port/README.md` - запуск Phaser web-port и подключение пользовательских спрайтов.
