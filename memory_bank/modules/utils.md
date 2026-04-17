# 🛠️ Утилиты

## Обзор

Утилиты предоставляют вспомогательные функции для игры.

## Список утилит

### SaveSystem

**Файл**: `src/utils/save_system.py`

**Функции**:
- `save_game(progress, inventory)` - сохранение игры
- `load_game()` - загрузка игры
- `has_save()` - проверка наличия сохранения

**Формат**: JSON  
**Расположение**: Рядом с exe или в корне проекта

### Helpers

**Файл**: `src/utils/helpers.py`

**Функции**:
- `clamp(value, min, max)` - ограничение значения
- `distance(x1, y1, x2, y2)` - расстояние между точками
- `random_color()` - случайный цвет

### VisualEffects

**Файл**: `src/utils/visual_effects.py`

**Функции**:
- `create_particles(x, y, color)` - создание частиц
- `create_text_effect(text, x, y)` - создание текстового эффекта
- `create_screen_shake()` - тряска экрана

### DialogueSystem

**Файл**: `src/utils/dialogue_system.py`

**Функции**:
- `show_dialogue(text, portrait)` - показ диалога
- `animate_text(text)` - анимация текста
- `show_portrait(portrait)` - показ портрета

### UIElements

**Файл**: `src/utils/ui_elements.py`

**Функции**:
- `create_button(text, x, y, width, height)` - создание кнопки
- `draw_button(button)` - отрисовка кнопки
- `check_button_click(button, mouse_pos)` - проверка клика по кнопке

## Паттерны использования

### Логирование

```python
import logging
logging.basicConfig(filename='game.log', level=logging.DEBUG)
logger = logging.getLogger()
logger.info("Сообщение")
```

### Работа с файлами

```python
import json

# Сохранение
with open('savegame.json', 'w') as f:
    json.dump(data, f)

# Загрузка
with open('savegame.json', 'r') as f:
    data = json.load(f)
```
