# 🏗️ Adventure Puzzle Game - System Patterns

## 🎯 Архитектура

### Общая архитектура

Проект использует **модульную архитектуру** с разделением на слои:

```
Игровой движок (main.py / main.rs)
    ↓
Сцены (scenes/)
    ├── Меню (menu.py / menu.rs)
    ├── Город (town.py / town.rs)
    ├── Геймплей (gameplay.py / gameplay.rs)
    └── Мини-игры (minigames.py / minigames.rs)
    ↓
Сущности (entities/)
    ├── Игрок (player.py / mod.rs)
    └── Предметы (item.py / mod.rs)
    ↓
Утилиты (utils/)
    ├── Помощники (helpers.py / mod.rs)
    ├── Эффекты (visual_effects.py / mod.rs)
    └── Сохранения (save_system.py / mod.rs)
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
}
```

**Применение**: Управление состояниями игры (меню, город, игра, мини-игры)

#### 2. Component Pattern (Компоненты)

**Python**:
```python
class Player:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.speed = 5
        self.inventory = []
```

**Rust**:
```rust
struct Player {
    x: f32,
    y: f32,
    speed: f32,
    inventory: Vec<String>,
}
```

**Применение**: Разделение логики на независимые компоненты

#### 3. Observer Pattern (Наблюдатель)

**Python**:
```python
class Game:
    def __init__(self):
        self.observers = []
    
    def add_observer(self, observer):
        self.observers.append(observer)
    
    def notify_observers(self, event):
        for observer in self.observers:
            observer.update(event)
```

**Применение**: Система событий и переходов между сценами

#### 4. Singleton Pattern (Одиночка)

**Python**:
```python
class SaveSystem:
    _instance = None
    
    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance
```

**Применение**: Система сохранений (один глобальный доступ)

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
├── entities/                  # Игровые объекты
│   └── mod.rs                # Игрок, предметы, NPC
├── scenes/                    # Игровые сцены
│   ├── mod.rs                # Трейт Scene
│   ├── menu.rs               # Главное меню
│   ├── town.rs               # Город-хаб
│   ├── village.rs            # Деревня
│   ├── room.rs               # Комната
│   ├── gameplay.rs           # Игровой процесс
│   └── puzzles/              # Головоломки
│       ├── mod.rs
│       ├── maze.rs           # Лабиринт
│       ├── wordsearch.rs     # Поиск слов
│       ├── pattern.rs        # Память
│       └── wordsearch.rs     # Поиск слов
└── utils/                     # Вспомогательные функции
    └── mod.rs
```

## 🔄 Потоки данных

### Игровой цикл

```
1. Инициализация
   ↓
2. Загрузка сохранения
   ↓
3. Создание начальной сцены
   ↓
4. Игровой цикл
   ├─ Обработка ввода
   ├─ Обновление состояния
   ├─ Отрисовка
   └─ Проверка смены сцены
   ↓
5. Сохранение при выходе
```

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
├── Village (Город-хаб)
├── Room (Комната)
├── Playing (Игровой процесс)
│   ├── Maze (Лабиринт)
│   ├── WordSearch (Поиск слов)
│   └── Pattern (Память)
└── Quit
```

### Система сохранений

**Формат**: JSON  
**Расположение**: Рядом с exe или в корне проекта  
**Содержимое**:
```json
{
  "levels": {
    "1": {"completed": true, "lever_pulled": false},
    "2": {"completed": false, "lever_pulled": false}
  },
  "inventory": {
    "gold": 100,
    "items": [],
    "won_minigames": []
  }
}
```

### Система прогрессии

1. Игрок проходит уровень
2. Прогресс сохраняется
3. Уровень помечается как пройденный
4. Доступны новые уровни

## 🛠️ Технические решения

### Python

- **Язык**: Python 3.12
- **Движок**: Pygame 2.5.2
- **Сборка**: PyInstaller 6.5.0
- **Формат сохранений**: JSON
- **Логирование**: logging

### Rust

- **Язык**: Rust 1.70+
- **Движок**: macroquad 0.4
- **Сериализация**: serde + serde_json
- **Рандом**: rand 0.8
- **Формат сохранений**: JSON

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

### Добавление нового уровня

1. Создать файл в `src/scenes/puzzles/` (Python) или `src_rust/scenes/puzzles/` (Rust)
2. Реализовать методы: `new()`, `handle_input()`, `update()`, `draw()`, `is_solved()`
3. Добавить в `gameplay.py` или `gameplay.rs`
4. Обновить `game_state.rs` (Rust) или `save_system.py` (Python)

### Добавление нового NPC

1. Создать класс в `src/entities/` (Python) или в `src_rust/entities/mod.rs` (Rust)
2. Добавить отрисовку в `town.py` или `town.rs`
3. Реализовать взаимодействие

### Добавление звуков

**Python**:
```python
pygame.mixer.init()
sound = pygame.mixer.Sound("sound.wav")
sound.play()
```

**Rust**:
```rust
use macroquad::audio::*;

let sound = load_sound("sound.wav").await.unwrap();
play_sound_once(sound);
```
