# План переноса логики из Rust-версии в GameMaker Studio 2

## Обзор

Этот документ описывает поэтапный план переноса игровой логики из Rust-версии "Adventure Puzzle Game" в GameMaker Studio 2. Цель - обеспечить максимально близкую функциональную эквивалентность оригиналу.

## Архитектурное соответствие

### 1. Структура проекта GameMaker
Соответствие компонентов Rust-версии объектам GameMaker:

| Rust | GameMaker 2 |
|------|-------------|
| `GameState` enum | Глобальная переменная `global.game_state` |
| `GameProgress` struct | `global.game_progress` структура с полями |
| `Scene` trait | Скрипты объектов с методами `handle_input`, `update`, `draw` |
| `Puzzle` structs | Отдельные объекты для каждой головоломки |

### 2. Основные объекты GameMaker

#### `obj_game_manager`
- Глобальные переменные:
  - `global.game_state` - текущее состояние игры (menu, town, playing, victory)
  - `global.game_progress` - структура с информацией о прогрессе
- Методы:
  - `set_state(new_state)` - установка нового состояния
  - `save_game()` - сохранение игры
  - `load_game()` - загрузка игры

#### `obj_scene_manager`
- Отвечает за текущую сцену
- Содержит логику текущей комнаты
- Обрабатывает переходы между комнатами

#### `obj_player`
- Перемещение игрока
- Обработка взаимодействия
- Визуализация игрока

#### `obj_puzzle_controller`
- Базовый объект для головоломок
- Обеспечивает общий интерфейс для всех видов головоломок
- Контролирует состояние активной головоломки

## Перенос игровой логики

### 1. Меню (Menu Scene)
**Rust:** `MenuScene` в `scenes/menu.rs`
**GMS2:** `rm_menu` с объектом `obj_menu_handler`

**Функциональность:**
- Отображение главного меню
- Навигация (новая игра, загрузка, настройки)
- Обработка ввода
- Переходы между состояниями

### 2. Хаб-город (Town Scene)
**Rust:** `TownScene` в `scenes/town.rs`
**GMS2:** `rm_hub_city` с объектом `obj_town_handler`

**Функциональность:**
- Движение игрока по городу
- Взаимодействие с NPC
- Диалоги с NPC
- Навигация к уровням
- Мини-игры у NPC:
  - `obj_npc_mechanic_game` - калибровка механика
  - `obj_npc_archivist_game` - викторина архивариуса
  - `obj_npc_elder_game` - испытание старосты
- Отображение прогресса
- Переход к первому уровню

### 3. Игровые уровни (Gameplay Scenes)
**Rust:** `GameplayScene` в `scenes/gameplay.rs`
**GMS2:** Каждый уровень в отдельной комнате:
- `rm_level_1_maze` - Лабиринт
- `rm_level_2_word_search` - Поиск слов
- `rm_level_3_pattern` - Паттерны
- `rm_level_4_memory` - Игра на память
- `rm_level_5_platformer` - Платформер
- `rm_level_6_final` - Финальный уровень

## Перенос головоломок

### 1. Головоломка "Лабиринт" (Maze Puzzle)
**Rust:** `MazePuzzle` в `scenes/puzzles/maze.rs`
**GMS2:** `obj_maze_puzzle`

**Функциональность:**
- Генерация лабиринта (алгоритм прохождения dead-end filling)
- Скольжение до стены
- Поиск пути к выходу
- Обработка ввода (WASD)
- Визуализация сетки лабиринта

**GML реализация:**
```gml
// Генерация лабиринта
function generate_maze(width, height) {
    // Создание массива стен
    var grid = array_create(width, height);
    // Заполнение всех клеток стенами
    for (var x = 0; x < width; x++) {
        for (var y = 0; y < height; y++) {
            grid[x,y] = true;
        }
    }
    
    // Использование рекурсивного бэк трекинга для создания проходов
    var stack = ds_stack_create();
    var current_x = 1;
    var current_y = 1;
    grid[current_x, current_y] = false; // Начальная точка
    
    while (!ds_stack_empty(stack) || (current_x != undefined)) {
        // Реализация алгоритма генерации
    }
    
    return grid;
}

// Скольжение до стены
function slide_to_wall(from_x, from_y, dx, dy) {
    var x = from_x;
    var y = from_y;
    
    while (true) {
        var next_x = x + dx;
        var next_y = y + dy;
        
        // Проверка границ и стен
        if (next_x < 0 || next_y < 0 || next_x >= maze_width || next_y >= maze_height || maze_grid[next_x, next_y]) {
            break;
        }
        
        x = next_x;
        y = next_y;
    }
    
    return [x, y];
}
```

### 2. Головоломка "Поиск слов" (Word Search Puzzle)
**Rust:** `WordSearchPuzzle` в `scenes/puzzles/wordsearch.rs`
**GMS2:** `obj_word_search_puzzle`

**Функциональность:**
- Генерация сетки букв
- Поиск слов (drag мышью или два клика)
- Проверка корректности найденных слов
- Две фазы для уровня 2

### 3. Головоломка "Паттерны" (Pattern Puzzle)
**Rust:** `PatternPuzzle` в `scenes/puzzles/pattern.rs`
**GMS2:** `obj_pattern_puzzle`

**Функциональность:**
- "Simon Says" механика
- Генерация последовательностей
- Проверка ответов игрока
- Прогрессия сложности

### 4. Головоломка "Игра на память" (Memory Match Puzzle)
**Rust:** `MemoryMatchPuzzle` в `scenes/puzzles/memory_match.rs`
**GMS2:** `obj_memory_match_puzzle`

**Функциональность:**
- Карточная игра
- Открытие пар карточек
- Проверка совпадений
- Визуализация карточек

### 5. Головоломка "Платформер" (Platformer Puzzle)
**Rust:** `PlatformerPuzzle` в `scenes/puzzles/platformer.rs`
**GMS2:** `obj_platformer_puzzle`

**Функциональность:**
- Физика прыжков
- Коллизии с платформами
- Сбор элементов
- Враги и препятствия

### 6. Головоломка "Финальный вызов" (Final Challenge Puzzle)
**Rust:** `FinalChallengePuzzle` в `scenes/puzzles/final_challenge.rs`
**GMS2:** `obj_final_challenge_puzzle`

**Функциональность:**
- Комбинация механик из других уровней
- Таймер (если применимо)
- Несколько целей для выполнения

## Системы сохранения

### Rust:
```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GameProgress {
    pub levels: HashMap<u8, LevelProgress>,
    pub gold: i32,
    pub items: Vec<String>,
    pub mechanic_training_completed: bool,
    pub archivist_quiz_completed: bool,
    pub elder_trial_completed: bool,
}
```

### GMS2:
```gml
// Структура сохранения
global.game_progress = {
    levels: ds_map_create(),
    gold: 100,
    items: ds_list_create(),
    mechanic_training_completed: false,
    archivist_quiz_completed: false,
    elder_trial_completed: false
};

// Добавление прогресса уровня
var level_data = {
    completed: false,
    lever_pulled: false
};
ds_map_set(global.game_progress.levels, string(level_num), level_data);
```

## Система аудио

### Соответствие аудио в GMS2:
- `snd_menu_bg` - фоновая музыка меню
- `snd_town_bg` - фоновая музыка города
- `snd_level_bg` - фоновая музыка уровней
- `snd_victory_bg` - победная музыка
- `snd_ui_confirm`, `snd_ui_cancel`, `snd_ui_move`, `snd_ui_success` - звуки интерфейса
- `snd_lever_pull` - звук активации рычага

## Система UI

### Rust:
```rust
fn draw_game_text(text, x, y, size, color)
```

### GMS2:
```gml
draw_set_font(fnt_game);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text_transformed(x, y, text, scale_x, scale_y, angle);
```

## Миграционные задачи

### Этап 1: Подготовка архитектуры (Week 1)
- [ ] Создание глобальных переменных и структур
- [ ] Создание базовых объектов (менеджеры состояний)
- [ ] Создание скриптов для вспомогательных функций
- [ ] Настройка шрифтов и аудио ресурсов

### Этап 2: Реализация меню и хаба (Week 2)
- [ ] Реализация главного меню
- [ ] Реализация хаб-города
- [ ] Движение игрока в городе
- [ ] Взаимодействие с объектами

### Этап 3: Реализация системы диалогов (Week 3)
- [ ] Создание системы диалогов
- [ ] Реализация NPC с диалогами
- [ ] Система обмена сообщениями между сценами

### Этап 4: Реализация базовых уровней (Week 4)
- [ ] Создание комнат для уровней
- [ ] Реализация объекта игрока для уровней
- [ ] Основная механика перемещения по уровням
- [ ] Система алтарей и рычагов

### Этап 5: Реализация лабиринта (Week 5)
- [ ] Алгоритм генерации лабиринта
- [ ] Реализация скольжения
- [ ] Обработка ввода и визуализация

### Этап 6: Реализация других головоломок (Week 6-8)
- [ ] Реализация поиска слов
- [ ] Реализация паттернов
- [ ] Реализация игры на память
- [ ] Реализация платформера
- [ ] Реализация финального уровня

### Этап 7: Реализация мини-игр у NPC (Week 9)
- [ ] Мини-игра механика Роана
- [ ] Викторина архивариуса Теля
- [ ] Испытание старосты Иара

### Этап 8: Интеграция аудио и визуальных эффектов (Week 10)
- [ ] Подключение аудио-менеджера
- [ ] Синхронизация музыки с состояниями игры
- [ ] Визуальные эффекты переходов

### Этап 9: Тестирование и отладка (Week 11-12)
- [ ] Функциональное тестирование всех систем
- [ ] Тестирование сохранений
- [ ] Исправление багов
- [ ] Оптимизация производительности

## Требования к качеству

### Функциональная эквивалентность
- [ ] Все игровые механики работают как в оригинале
- [ ] Система прогресса работает правильно
- [ ] Система наград работает правильно
- [ ] Все головоломки имеют тот же уровень сложности

### Визуальная эквивалентность
- [ ] Интерфейс отображается схожим образом
- [ ] Цветовая палитра сохранена
- [ ] Основные визуальные элементы присутствуют

### Аудио эквивалентность
- [ ] Соответствующая фоновая музыка для каждого состояния
- [ ] Все интерфейсные звуки на месте
- [ ] Аудио-обратная связь для действий игрока