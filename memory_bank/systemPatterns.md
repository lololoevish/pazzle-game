# Adventure Puzzle Game - System Patterns

## 🎯 Архитектура

### Общая архитектура

Проект использует модульную архитектуру с двумя историческими ветками реализации, где основной исполняемой веткой сейчас является Rust:

```
Игровой цикл (main.py / main.rs)
    ↓
Сцены (scenes/)
    ├── Меню (menu.py / menu.rs)
    ├── Город (town.py / town.rs)
    ├── Геймплей (gameplay.py / gameplay.rs)
    └── Головоломки / мини-игры
    ↓
Данные прогресса и сохранения
    └── GameProgress / save_system.py
```

### Паттерны проектирования

#### 1. State Pattern (Состояние)

**Python**:
```python
class MenuScene:
    def handle_events(self, events): ...
    def update(self, keys): ...
    def draw(self, screen): ...
    def is_transition_complete(self): ...
    def get_result(self): ...
```

**Rust**:
```rust
trait Scene {
    fn handle_input(&mut self);
    fn update(&mut self);
    fn draw(&self);
    fn get_next_state(&self) -> Option<GameState>;
    fn take_completed_level(&mut self) -> Option<u8> { None }
    fn take_progress_update(&mut self) -> Option<ProgressUpdate> { None }
}
```

**Применение**: управление состояниями игры и переключение между `Menu`, `Town`, `Playing`, `Quit`.

#### 2. Модульная изоляция головоломок

Каждая Rust-головоломка живёт в отдельном модуле и подключается в `GameplayScene` по номеру уровня.

**Применение**: локализация логики уровня, упрощение поддержки и расширения.

#### 3. Одноразовый сигнал завершения уровня

Трейт `Scene` содержит `take_completed_level()`, чтобы сцена один раз сообщила главному циклу о завершении уровня.

**Применение**: синхронизация прогресса без постоянного опроса внутреннего состояния пазла.

#### 4. Точечные обновления прогресса

`GameplayScene` использует `take_progress_update()` для сохранения состояния рычага без прямого доступа сцены к файловой системе.

**Применение**: хранение `lever_pulled` в `savegame.json`, когда игрок открыл проход в следующую пещеру.

## 📁 Структура файловой системы

### Python

```
src/
├── main.py                    # Точка входа
├── scenes/                    # Игровые сцены
│   ├── __init__.py
│   ├── menu.py               # Главное меню
│   ├── town.py               # Город-хаб
│   ├── gameplay.py           # Игровой процесс
│   ├── minigames.py          # Мини-игры
│   ├── puzzle_types.py       # Типы головоломок
│   └── story.py              # Сюжетные сцены
├── entities/                  # Игровые объекты
│   ├── __init__.py
│   ├── player.py             # Игрок
│   └── item.py               # Предметы
└── utils/                     # Утилиты
    ├── __init__.py
    ├── helpers.py            # Вспомогательные функции
    ├── visual_effects.py     # Визуальные эффекты
    ├── save_system.py        # Система сохранений
    ├── dialogue_system.py    # Система диалогов
    └── ui_elements.py        # UI элементы
```

### Rust

```
src_rust/
├── main.rs                    # Точка входа
├── game_state.rs              # Состояние игры, сохранения
├── scenes/                    # Игровые сцены
│   ├── mod.rs                # Трейт Scene
│   ├── menu.rs               # Главное меню
│   ├── town.rs               # Город-хаб
│   ├── gameplay.rs           # Игровой процесс
│   └── puzzles/              # Головоломки
│       ├── mod.rs
│       ├── maze.rs           # Лабиринт
│       ├── memory_match.rs   # Поиск пар карточек
│       ├── platformer.rs     # Платформер со сбором кристаллов
│       ├── final_challenge.rs # Финальное испытание на время
│       ├── wordsearch.rs     # Поиск слов
│       └── pattern.rs        # Память
```

## 🔄 Потоки данных

### Игровой цикл

`main.rs` загружает сохранение, создаёт активную сцену и в цикле вызывает:

1. `handle_input()`
2. `update()`
3. `take_completed_level()`
4. `take_progress_update()`
5. сохранение прогресса при необходимости
6. `draw()`
7. переход между сценами при наличии `get_next_state()`

### Обработка ввода

**Python**:
```python
for event in pygame.event.get():
    if event.type == pygame.QUIT:
        running = False
    elif event.type == pygame.KEYDOWN:
        # Обработка нажатия клавиш
```

**Rust**:
```rust
if is_key_pressed(KeyCode::Escape) {
    // Обработка нажатия ESC
}
```

### Отрисовка

**Python**:
```python
screen.fill(BLACK)
current_scene.draw(screen)
pygame.display.flip()
```

**Rust**:
```rust
clear_background(BLACK);
current_scene.draw();
next_frame().await
```

## 🎮 Игровая логика

### Состояния игры

```
GameState
├── Menu
├── Town (стартовый хаб и шахтный спуск)
├── Playing(level)
│   ├── 1 -> Maze
│   ├── 2 -> WordSearch
│   ├── 3 -> Pattern
│   ├── 4 -> MemoryMatch
│   ├── 5 -> Platformer
│   └── 6 -> FinalChallenge
└── Quit
```

### Система сохранений

**Формат**: JSON
**Расположение**: в рабочей директории приложения
**Содержимое**:
```json
{
  "levels": {
    "1": {"completed": true, "lever_pulled": false},
    "2": {"completed": false, "lever_pulled": false}
  },
  "gold": 100,
  "items": []
}
```

### Система прогрессии

1. Игрок из `TownScene` входит в шахтный спуск и попадает в текущую активную пещеру.
2. Внутри `GameplayScene` пещера содержит алтарь головоломки, рычаг и физический проход в следующую пещеру.
3. После первого решения печати сцена одноразово сообщает о завершении уровня через `take_completed_level()`.
4. После опускания рычага сцена сообщает о `lever_pulled` через `take_progress_update()`, и только это открывает следующий уровень.
5. Повторный вход в уже решённую головоломку позволяет нажать `L` и пропустить повторное решение перед рычагом.
6. `TownScene` использует сохранённый прогресс только для выбора текущей активной пещеры и для визуализации статуса шести печатей.
7. Для уровня 1 движение реализовано как скольжение до ближайшей стены.
8. Для уровня 2 `GameplayScene` использует последовательные фазы: сначала `WordSearchPuzzle`, затем `MemoryMatchPuzzle`.

## 🛠️ Технические решения

### Rust

- **Язык**: Rust 1.70+
- **Движок**: macroquad 0.4
- **Сериализация**: serde + serde_json
- **Рандом**: rand 0.8
- **Формат сохранений**: JSON
- **Ключевая модель**: `Scene` trait + `GameState` enum + отдельные puzzle modules

## 📊 Сравнение подходов

| Аспект | Python | Rust |
|--------|--------|------|
| **Производительность** | Средняя | Высокая |
| **Размер exe** | 50-80 МБ | 5-10 МБ |
| **Сложность кода** | Простая | Средняя |
| **Безопасность** | Средняя | Высокая |
| **Кросс-платформа** | Да | Да + Web |
| **Время сборки** | 30-60 сек | 60-120 сек |

## 🎯 Паттерны использования

### Добавление нового уровня в Rust

1. Создать модуль в `src_rust/scenes/puzzles/`
2. Реализовать `new()`, `handle_input()`, `update()`, `draw()`, `is_solved()`
3. Подключить модуль в `src_rust/scenes/puzzles/mod.rs`
4. Добавить выбор пазла в `src_rust/scenes/gameplay.rs`
5. При необходимости обновить тексты и маршрут шахтного спуска в `src_rust/scenes/town.rs`

### Добавление NPC-логики в Rust

1. Расширить `TownScene` визуальным и интерактивным объектом
2. Добавить отдельный модуль сцены или мини-игры
3. Зафиксировать новые маршруты в `docs/README.md` и `memory_bank/`
