# Интеграция VN-системы с портретами

## Обзор

VN-система с портретами интегрирована в GameMaker 2 версию игры для обеспечения более выразительных диалогов с NPC. Система поддерживает:
- Анимированные портреты персонажей
- Печатающийся текст
- Ветвящиеся диалоги с выбором
- Интеграцию с мини-играми

## Архитектура

### Основные компоненты

1. **scr_vn_portrait_manager.gml** - Управление портретами и их анимацией
2. **scr_vn_text_engine.gml** - Система печатающегося текста
3. **scr_vn_dialogue_system.gml** - Управление деревом диалогов
4. **scr_vn_ui_manager.gml** - Отрисовка UI элементов
5. **scr_vn_master.gml** - Главный контроллер системы

### Интеграция с obj_npc

VN-система интегрирована в `obj_npc.gml` через следующие изменения:

#### Create Event
```gml
// VN-система
use_vn_system = true; // Использовать ли VN-систему с портретами
vn_character_id = ""; // ID персонажа для VN-системы
vn_dialogue_tree = ""; // ID дерева диалогов
vn_initialized = false;
```

#### Step Event
```gml
// Инициализация VN-системы при первом запуске
if (!vn_initialized && use_vn_system) {
    vn_system_init();
    vn_initialized = true;
}

// Обновление VN-системы
if (use_vn_system && vn_is_dialogue_active()) {
    vn_system_update();
}
```

#### Draw GUI Event
```gml
// Отрисовка VN-системы
if (in_dialogue && use_vn_system && vn_is_dialogue_active()) {
    vn_system_draw();
}
```

## Структура диалоговых деревьев

Диалоги хранятся в JSON-файлах в папке `dialogues/`. Формат:

```json
{
  "tree_id": "character_main",
  "character": "character_id",
  "nodes": {
    "start": {
      "speaker": "character_id",
      "text": "Текст диалога",
      "portrait": "neutral",
      "next": "next_node_id"
    },
    "node_with_choices": {
      "speaker": "character_id",
      "text": "Текст с выбором",
      "portrait": "neutral",
      "choices": [
        {
          "text": "Вариант 1",
          "next": "node_1"
        },
        {
          "text": "Вариант 2",
          "next": "node_2"
        }
      ]
    },
    "node_with_action": {
      "speaker": "character_id",
      "text": "Запуск действия",
      "portrait": "neutral",
      "action": "start_minigame_name",
      "next": "end"
    }
  }
}
```

## Созданные диалоговые деревья

1. **elder_dialogue_tree.json** - Диалоги старосты Иара
   - Приветствие и представление
   - Предложение испытания на угадывание числа
   - Ветвление: принять/отклонить испытание
   - Интеграция с мини-игрой elder_trial

2. **mechanic_dialogue_tree.json** - Диалоги механика Роана
   - Просьба о помощи с калибровкой
   - Выбор: помочь/отказать
   - Интеграция с мини-игрой mechanic_calibration
   - Разные портреты (neutral/happy)

3. **archivist_dialogue_tree.json** - Диалоги архивариуса Теля
   - Представление архива
   - Предложение викторины
   - Выбор: пройти викторину/отказаться
   - Интеграция с мини-игрой archivist_quiz

## Настройка NPC для использования VN-системы

Для включения VN-системы для конкретного NPC:

```gml
// В Create Event конкретного NPC
use_vn_system = true;
vn_character_id = "elder"; // или "mechanic", "archivist"
vn_dialogue_tree = "elder_main"; // ID дерева диалогов
```

## Портреты персонажей

Портреты хранятся в `assets/sprites/portraits/`:
- `spr_portrait_elder_neutral.txt` - Нейтральный портрет старосты
- `spr_portrait_mechanic_neutral.txt` - Нейтральный портрет механика
- `spr_portrait_mechanic_happy.txt` - Радостный портрет механика
- `spr_portrait_archivist_neutral.txt` - Нейтральный портрет архивариуса

## Управление в диалогах

- **Space/Enter/ЛКМ** - Продолжить диалог / Выбрать вариант
- **Стрелки вверх/вниз** - Навигация по вариантам выбора
- **ESC** - Закрыть диалог

## Интеграция с мини-играми

VN-система поддерживает запуск мини-игр через поле `action` в узлах диалога:

```json
{
  "action": "start_elder_trial",
  "next": "end"
}
```

Доступные действия:
- `start_elder_trial` - Испытание старосты
- `start_mechanic_calibration` - Калибровка механика
- `start_archivist_quiz` - Викторина архивариуса

## Проверка завершения мини-игр

Система автоматически проверяет статус завершения мини-игр через:
- `global.game_progress.elder_trial_completed`
- `global.game_progress.mechanic_training_completed`
- `global.game_progress.archivist_quiz_completed`

При повторном взаимодействии с NPC после завершения мини-игры показывается узел `already_completed`.

## Следующие шаги

1. Создание реальных спрайтов портретов (сейчас используются текстовые заглушки)
2. Добавление анимации портретов (моргание, смена эмоций)
3. Расширение диалоговых деревьев с дополнительными ветвлениями
4. Добавление звуковых эффектов для печатающегося текста
5. Тестирование в GameMaker Studio 2
