# Утилиты

## Обзор

Актуальные утилиты находятся в `pazzle-game-gamemaker/scripts/`. Исторические Python utilities не являются основным runtime-кодом.

## Основные GMS2-утилиты

### `scr_game_state.gml`

Назначение: глобальное состояние игры, прогресс уровней, текущая цель и статус экспедиции.

Ключевые функции:

- `complete_level(level_num)`;
- `set_level_lever_pulled(level_num, pulled)`;
- `count_completed_levels()`;
- `count_opened_levels()`;
- `get_current_objective_level()`.

### `scr_save_system.gml`

Назначение: сохранение, загрузка, reset и расширение legacy-сохранений до 12 уровней.

Ключевые функции:

- `save_game()`;
- `load_game()`;
- `reset_game()`;
- `has_save()`;
- `get_save_info()`.

### `scr_audio_manager.gml`

Назначение: музыка, SFX, приоритеты и контекстные модификаторы громкости.

Особенность: отсутствующие ресурсы должны безопасно возвращать `-1`, а не падать в runtime.

### `scr_ui_manager.gml`

Назначение: HUD, уведомления, диалоги, сообщения и сервисные UI-оверлеи.

### `scr_vn_*.gml`

Назначение: VN-портреты, печатающийся текст, диалоговые деревья и VN UI.

### `scr_resource_manager.gml`, `scr_sprite_loader.gml`, `scr_asset_manager_master.gml`

Назначение: загрузка и кеширование ресурсов для GMS2-ветки.

## Паттерны использования

1. Перед чтением optional global использовать `variable_global_exists()`.
2. Для поиска комнаты по имени использовать `asset_get_index()` и проверку `asset_room`.
3. Для динамического доступа к struct-полям использовать `struct[$ key]`.
4. Не добавлять новые `.gml` зависимости без обновления Memory Bank и релевантной документации.
