# Adventure Puzzle Game на GameMaker Studio 2

## Обзор

Это основная продуктовая версия `Adventure Puzzle Game`. Проект ориентирован на GameMaker Studio 2 и содержит 12-пещерный маршрут, хаб с NPC-активностями, систему прогресса, сохранения, аудио, UI и VN-слой.

## Как Открыть Проект

Открывайте в GameMaker Studio 2 именно эту папку:

`pazzle-game-gamemaker/`

Если GameMaker просит файл проекта, выберите `.yyp` внутри этой папки.

## Структура

```text
pazzle-game-gamemaker/
├── objects/
│   ├── obj_game_manager.gml
│   ├── obj_player.gml
│   ├── obj_puzzle.gml
│   ├── obj_lever.gml
│   ├── obj_npc.gml
│   └── obj_interactable.gml
├── scripts/
│   ├── scr_game_state.gml
│   ├── scr_save_system.gml
│   ├── scr_audio_manager.gml
│   ├── scr_ui_manager.gml
│   ├── scr_vn_*.gml
│   └── puzzle_scripts/
├── rooms/
├── assets/
├── dialogues/
└── test_scenarios/
```

## Основные Системы

- `scr_game_state.gml` - прогресс, цели и состояние 12 уровней.
- `scr_save_system.gml` - сохранение, загрузка, reset и восстановление состояния.
- `scr_audio_manager.gml` - музыка, SFX, контексты и приоритеты.
- `scr_ui_manager.gml` - HUD, уведомления, диалоги и служебные UI-слои.
- `scr_puzzle_manager.gml` - выбор и запуск головоломок.
- `scr_vn_*.gml` - портреты, печатающийся текст и VN-диалоги.

## Головоломки

1. Лабиринт.
2. Поиск слов.
3. Ритм/паттерн.
4. Memory match.
5. Платформер.
6. Финальное испытание первой арки.
7. Загадки.
8. Звуковые ловушки.
9. Прыгающий путь.
10. Advanced memory.
11. Песнь пещер.
12. Эпический финал.

## Тестирование

В проекте есть ручные и полуавтоматические сценарии:

- `test_scenarios/test_game_state.gml`
- `test_scenarios/test_save_system.gml`
- `test_scenarios/test_audio_manager.gml`
- `test_scenarios/test_ui_manager.gml`

Автоматический Biome-линтинг `.gml` сейчас недоступен, потому что текущая конфигурация игнорирует эти файлы.

## Текущий Статус

Проект находится в активной разработке. Основной технический фокус: runtime-стабилизация маршрута, устранение legacy-расхождений и ручной smoke/regression-проход в GameMaker Studio 2.
