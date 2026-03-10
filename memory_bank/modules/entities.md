# 🎮 Игровые сущности

## Обзор

Сущности представляют объекты в игре: игрока, врагов, предметы, NPC.

## Список сущностей

### Player

**Файл**: `src/entities/player.py`

**Атрибуты**:
- `x`, `y` - координаты
- `speed` - скорость движения
- `inventory` - инвентарь

**Методы**:
- `move(dx, dy)` - движение
- `add_item(item)` - добавление предмета
- `use_item(item)` - использование предмета

### Item

**Файл**: `src/entities/item.py`

**Атрибуты**:
- `name` - название
- `description` - описание
- `type` - тип (gold, weapon, armor, etc.)
- `value` - ценность

**Методы**:
- `get_value()` - получение ценности

### NPC

**Файл**: `src_rust/entities/mod.rs`

**Атрибуты**:
- `name` - имя
- `position` - позиция
- `dialogue` - диалог
- `minigame` - мини-игра

**Методы**:
- `interact()` - взаимодействие
- `start_minigame()` - запуск мини-игры

## Система инвентаря

### Структура

```python
inventory = {
    'gold': 100,
    'items': [],
    'won_minigames': []
}
```

### Операции

- `add_item(item)` - добавление предмета
- `remove_item(item)` - удаление предмета
- `add_gold(amount)` - добавление золота
- `remove_gold(amount)` - удаление золота

## Система прогресса

### Структура

```python
progress = {
    1: {'completed': False, 'lever_pulled': False},
    2: {'completed': False, 'lever_pulled': False},
    ...
}
```

### Операции

- `mark_completed(level)` - пометить уровень как пройденный
- `mark_lever_pulled(level)` - пометить рычаг как активированный
- `is_completed(level)` - проверить, пройден ли уровень
