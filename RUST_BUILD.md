# 🦀 Сборка Rust-версии игры

## Требования

1. **Rust** (версия 1.70+)
   - Установка: https://rustup.rs/
   - Команда: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

2. **Зависимости системы** (для Windows уже включены)

## Установка Rust

### Windows
```bash
# Скачайте и запустите rustup-init.exe
# Или используйте:
winget install Rustlang.Rustup
```

### Linux/Mac
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## Сборка проекта

### Режим разработки (быстрая сборка)
```bash
cargo build
```

### Режим релиза (оптимизированная сборка)
```bash
cargo build --release
```

## Запуск игры

### Из исходников (разработка)
```bash
cargo run
```

### Релизная версия
```bash
cargo run --release
```

### Запуск скомпилированного exe
```bash
# После сборки релиза:
./target/release/game.exe
```

## Структура проекта

```
src_rust/
├── main.rs              # Точка входа
├── game_state.rs        # Состояние игры и сохранения
├── entities/            # Игровые сущности
│   └── mod.rs
├── scenes/              # Игровые сцены
│   ├── mod.rs
│   ├── menu.rs          # Главное меню
│   ├── town.rs          # Город-хаб
│   ├── gameplay.rs      # Игровой процесс
│   └── puzzles/         # Головоломки
│       ├── mod.rs
│       ├── maze.rs      # Лабиринт
│       ├── wordsearch.rs # Поиск слов
│       └── pattern.rs   # Память
└── utils/               # Утилиты
    └── mod.rs
```

## Используемые библиотеки

- **macroquad** - игровой движок (аналог Pygame)
- **serde** - сериализация данных
- **serde_json** - работа с JSON
- **rand** - генерация случайных чисел

## Преимущества Rust-версии

✅ **Производительность**: В 10-50 раз быстрее Python
✅ **Безопасность памяти**: Нет утечек памяти
✅ **Один exe-файл**: Не нужен Python
✅ **Кросс-платформенность**: Windows, Linux, Mac, Web (WASM)
✅ **Маленький размер**: ~5-10 МБ вместо 50+ МБ

## Сборка для Web (WASM)

```bash
# Установка цели
rustup target add wasm32-unknown-unknown

# Сборка
cargo build --release --target wasm32-unknown-unknown

# Запуск локального сервера
# (требуется basic-http-server)
cargo install basic-http-server
basic-http-server .
```

## Оптимизация размера exe

В `Cargo.toml` уже настроено:
- `opt-level = 3` - максимальная оптимизация
- `lto = true` - Link Time Optimization
- `codegen-units = 1` - лучшая оптимизация
- `strip = true` - удаление отладочной информации

## Отладка

### Запуск с логами
```bash
RUST_LOG=debug cargo run
```

### Проверка кода
```bash
cargo check
```

### Форматирование
```bash
cargo fmt
```

### Линтер
```bash
cargo clippy
```

## Проблемы и решения

### Ошибка компиляции
```bash
# Очистка кэша
cargo clean
cargo build
```

### Медленная компиляция
```bash
# Используйте режим разработки для тестов
cargo run
# Релиз только для финальной сборки
cargo run --release
```

## Сравнение с Python-версией

| Характеристика | Python | Rust |
|---------------|--------|------|
| Скорость | 1x | 10-50x |
| Размер exe | 50+ МБ | 5-10 МБ |
| Запуск | Нужен Python | Один exe |
| Сборка | PyInstaller | Cargo |
| Время сборки | 30-60 сек | 60-120 сек |
| Безопасность | Средняя | Высокая |

## Следующие шаги

1. Завершить реализацию всех 6 уровней
2. Добавить систему спрайтов
3. Добавить звуки и музыку
4. Реализовать мини-игры
5. Добавить систему диалогов
6. Портировать на Web (WASM)

---

**Версия**: 1.2.0 (Rust Edition)  
**Дата**: 5 марта 2026
