# 🛠️ Adventure Puzzle Game - Tech Context

## 🖥️ Окружение

### Разработка

- **ОС**: Windows (win32)
- **Shell**: bash
- **Python**: 3.12
- **Rust**: 1.70+
- **IDE**: VS Code

### Зависимости

#### Python

```
pygame==2.5.2
pyinstaller==6.5.0
```

#### Rust

```toml
[dependencies]
macroquad = "0.4"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
rand = "0.8"
```

## 📦 Сборка

### Python

```bash
# Установка зависимостей
pip install -r requirements.txt

# Сборка в exe
pyinstaller AdventurePuzzleGame.spec

# Или через скрипт
ЗАПУСК_СБОРКИ.bat
```

### Rust

```bash
# Установка Rust
winget install Rustlang.Rustup

# Сборка (разработка)
cargo build

# Сборка (релиз)
cargo build --release

# Или через скрипт
BUILD_RUST.bat
```

## 🚀 Запуск

### Python

```bash
# Из исходников
python src/main.py

# Из exe
dist/AdventurePuzzleGame.exe
```

### Rust

```bash
# Из исходников
cargo run --release

# Из exe
target/release/game.exe
# или
AdventurePuzzleGame_Rust.exe
```

## 📁 Структура проекта

```
pazzle-game/
├── src/                    # Python код
│   ├── main.py            # Точка входа
│   ├── scenes/            # Игровые сцены
│   ├── entities/          # Игровые объекты
│   └── utils/             # Утилиты
├── src_rust/              # Rust код
│   ├── main.rs           # Точка входа
│   ├── game_state.rs     # Состояние игры
│   ├── scenes/           # Сцены
│   ├── entities/         # Сущности
│   └── utils/            # Утилиты
├── assets/                # Ресурсы
│   └── sprites/          # Спрайты
├── dist/                  # Готовые exe
├── requirements.txt       # Python зависимости
├── Cargo.toml            # Rust конфигурация
├── BUILD_RUST.bat        # Скрипт сборки Rust
└── memory_bank/          # Документация (Memory Bank)
```

## 🔧 Настройки

### Python

- **Размер экрана**: 800x600
- **FPS**: 60
- **Формат сохранений**: JSON
- **Логирование**: game.log

### Rust

- **Размер экрана**: 800x600
- **FPS**: 60
- **Формат сохранений**: JSON
- **Профиль релиза**: opt-level = 3, lto = true

## 🌐 Кросс-платформенность

### Python

- ✅ Windows
- ✅ Linux
- ✅ Mac

### Rust

- ✅ Windows
- ✅ Linux
- ✅ Mac
- 🚧 Web (WASM)

## 📊 Производительность

### Требования к системе

**Минимальные**:
- CPU: 1 GHz
- RAM: 512 MB
- GPU: Интегрированная графика
- OS: Windows 7+

**Рекомендуемые**:
- CPU: 2 GHz+
- RAM: 1 GB+
- GPU: Любая
- OS: Windows 10+

### Оптимизация

- Стабильные 60 FPS на любом современном ПК
- Низкое потребление ресурсов
- Быстрый запуск (~1-2 секунды для Python, ~0.1 сек для Rust)
- Малый размер exe (~5-10 MB для Rust)

## 🔐 Безопасность

- Нет сбора персональных данных
- Локальные сохранения
- Отсутствие внешних зависимостей (Rust версия)
- Антивирусы могут ложно срабатывать на exe (добавьте в исключения)

## 📝 CI/CD

### Текущее состояние

- ✅ Ручная сборка через .bat скрипты
- 🚧 Автоматическая сборка (не настроена)
- 🚧 Автоматические тесты (не настроены)

### Планируемые улучшения

- GitHub Actions для автоматической сборки
- Автоматические тесты
- Деплой на GitHub Releases

## 🛠️ Инструменты разработки

### Python

- **Pygame**: Игровой фреймворк
- **PyInstaller**: Сборка в exe
- **Logging**: Система логирования
- **JSON**: Формат сохранений

### Rust

- **macroquad**: Игровой движок
- **serde**: Сериализация
- **serde_json**: JSON
- **rand**: Генератор случайных чисел
- **cargo**: Менеджер пакетов

## 📚 Документация

### Python

- **Pygame Docs**: https://www.pygame.org/docs/
- **PyInstaller Docs**: https://pyinstaller.org/

### Rust

- **Rust Book**: https://doc.rust-lang.org/book/
- **macroquad Docs**: https://docs.rs/macroquad/
- **Rust by Example**: https://doc.rust-lang.org/rust-by-example/

## 🐛 Известные проблемы

### Python

- Антивирусы могут ложно срабатывать на exe
- Размер exe ~50-80 МБ
- Зависимость от Python

### Rust

- Время сборки 1-2 минуты (первая)
- Сложность кода выше, чем в Python
- Требуется установка Rust

## 🚀 Быстрый старт для разработчиков

### Установка

```bash
# Клонировать репозиторий
git clone https://github.com/lololoevish/pazzle-game.git
cd pazzle-game

# Установить Python зависимости
pip install -r requirements.txt

# Установить Rust
winget install Rustlang.Rustup
```

### Запуск

```bash
# Python
python src/main.py

# Rust
cargo run --release
```

### Сборка

```bash
# Python
pyinstaller AdventurePuzzleGame.spec

# Rust
cargo build --release
```
