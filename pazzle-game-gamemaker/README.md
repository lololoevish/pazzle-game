# Проект Adventure Puzzle Game для GameMaker 2

Это GameMaker 2 версия проекта Adventure Puzzle Game, перенесенная из Rust (macroquad).

## 📁 Структура проекта

```
pazzle-game-gamemaker/
├── assets/
│   ├── sprites/          # Спрайты (.png)
│   ├── sounds/           # Звуки (.wav, .mp3)
│   ├── music/            # Музыка (.wav, .mp3)
│   └── fonts/            # Шрифты
├── objects/
│   ├── obj_game_manager  # Управление состоянием
│   ├── obj_player        # Игрок
│   ├── obj_ui_manager    # UI элементы
│   └── puzzle_objects/   # Объекты головоломок
├── rooms/
│   ├── rm_menu           # Главное меню
│   ├── rm_town           # Город-хаб
│   ├── rm_caves/         # Пещеры (6 штук)
│   └── rm_victory        # Финальная сцена
├── scripts/
│   ├── scr_game_state    # Управление прогрессом
│   ├── scr_save_system   # Сохранения
│   └── puzzle_scripts/   # Логика головоломок
├── shaders/              # Эффекты (если нужны)
└── data/
    └── savegame.json     # Файл сохранения
```

## 🏗️ Реализованные компоненты

- **Система управления состояниями** (GameState) - в `obj_game_manager`
- **Система сохранений** - в `scr_save_system`
- **Аудио система** - в `scr_audio_manager`
- **UI система** - в `scr_ui_manager`
- **Базовая механика игрока** - в `obj_player`
- **Система головоломок** - в `obj_puzzle`
- **Система рычагов** - в `obj_lever`

## 🔄 Состояния игры

- `MENU` - Главное меню
- `TOWN` - Город-хаб
- `PLAYING` - Игровой процесс
- `VICTORY` - Финальная сцена

## 🎮 Управление

- **Движение**: Стрелки или WASD
- **Взаимодействие**: Клавиша E или Enter

## 📊 Прогресс

- [ ] Создание остальных объектов
- [ ] Создание комнат
- [ ] Импорт ассетов
- [ ] Реализация конкретных головоломок
- [ ] Тестирование

## 📝 Примечания

Этот проект следует плану миграции, описанному в документе `plans/gamemaker_migration_plan.md` в основном репозитории.