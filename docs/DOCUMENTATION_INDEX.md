# Индекс документации проекта Adventure Puzzle Game

**Последнее обновление**: 17 апреля 2026

## Быстрая навигация

### 🎯 Начало работы
- [README.md](README.md) - Архитектура проекта (источник правды)
- [DEVELOPER_CHECKLIST.md](DEVELOPER_CHECKLIST.md) - Чеклист для разработчиков

### 📦 Memory Bank (Операционный контекст)
- [projectbrief.md](../memory_bank/projectbrief.md) - Цели, рамки, Project Deliverables
- [activeContext.md](../memory_bank/activeContext.md) - Текущий фокус разработки
- [progress.md](../memory_bank/progress.md) - Статус, история изменений
- [productContext.md](../memory_bank/productContext.md) - Продуктовый контекст
- [systemPatterns.md](../memory_bank/systemPatterns.md) - Архитектурные решения
- [techContext.md](../memory_bank/techContext.md) - Технологический стек

---

## 🎨 Ассеты и визуал

### Тематические ассеты пещер
- [thematic_assets_guide.md](thematic_assets_guide.md) - Пещеры 1-2 (лабиринт, архив)
- [cave_assets_3_6_guide.md](cave_assets_3_6_guide.md) - Пещеры 3-6 (ритм, пары, платформер, финал)
- [quick_asset_integration_guide.md](quick_asset_integration_guide.md) - Пошаговая интеграция в GMS2

### Конфигурационные файлы
```
pazzle-game-gamemaker/assets/sprites/
├── cave1_maze/cave1_assets_config.json
├── cave2_archive/cave2_assets_config.json
├── cave3_rhythm/cave3_assets_config.json
├── cave4_pairs/cave4_assets_config.json
├── cave5_platformer/cave5_assets_config.json
└── cave6_final/cave6_assets_config.json
```

---

## 🎮 Уровни и головоломки

### Базовые уровни (1-6)
- Уровень 1: Лабиринт со скольжением
- Уровень 2: Поиск слов
- Уровень 3: Паттерн-память (Simon Says)
- Уровень 4: Поиск пар карточек
- Уровень 5: Платформер со сбором кристаллов
- Уровень 6: Финальное испытание на время

### Расширенные уровни (7-12)
- [levels_7_12_guide.md](levels_7_12_guide.md) - Детальное описание
  - Уровень 7: Загадки Сфинкса
  - Уровень 8: Звуковые Ловушки
  - Уровень 9: Прыгающий Путь
  - Уровень 10: Запоминалка (продвинутая)
  - Уровень 11: Песнь Пещер
  - Уровень 12: Финальный Подвиг

---

## 🎵 Аудио

### Музыкальные темы
- [music_themes_config.md](music_themes_config.md) - Конфигурация всех музыкальных тем
- [audio_system_guide.md](audio_system_guide.md) - Руководство по аудио-системе
- [audio_dramaturgy_guide.md](audio_dramaturgy_guide.md) - Звуковая драматургия
- [audio_enhancement_plan.md](audio_enhancement_plan.md) - План улучшения аудио

---

## 🔧 Миграция на GameMaker Studio 2

### Планирование
- [gamemaker_migration_plan.md](gamemaker_migration_plan.md) - Общий план миграции
- [rust_to_gms2_port_plan.md](rust_to_gms2_port_plan.md) - Перенос логики из Rust
- [migration_tz.md](migration_tz.md) - Техническое задание на миграцию
- [migration_guide.md](migration_guide.md) - Руководство по миграции

### Архитектура
- [gms2_architecture.md](gms2_architecture.md) - Архитектурный документ GMS2
- [gms_architecture.md](gms_architecture.md) - Архитектура GameMaker
- [gamemaker_project_structure.md](gamemaker_project_structure.md) - Структура проекта

### Ассеты
- [asset_integration_plan.md](asset_integration_plan.md) - План интеграции ассетов
- [gms2_asset_migration_technical_spec.md](gms2_asset_migration_technical_spec.md) - Техническая спецификация
- [cave_assets_plan.md](cave_assets_plan.md) - План создания ассетов пещер

---

## 🧪 Тестирование

### Стратегия и сценарии
- [TESTING.md](TESTING.md) - Документ тестирования GMS2 проекта
- [UNIT_TESTS.md](UNIT_TESTS.md) - Сценарии модульного тестирования
- [gms2_testing_strategy.md](gms2_testing_strategy.md) - Стратегия тестирования
- [gms2_unit_test_scenarios.md](gms2_unit_test_scenarios.md) - Сценарии тестов

### Тестовые файлы
```
pazzle-game-gamemaker/test_scenarios/
├── test_game_state.gml
├── test_save_system.gml
├── test_audio_manager.gml
└── test_ui_manager.gml
```

---

## 🎯 Игровые механики

### Специальные системы
- [deltarune_mechanics_integration_plan.md](deltarune_mechanics_integration_plan.md) - Интеграция механик Deltarune
- [achievements_system.md](achievements_system.md) - Система достижений
- [vn_system_plan.md](vn_system_plan.md) - План VN-системы
- [vn_system_integration.md](vn_system_integration.md) - Интеграция VN-системы

### Переходы между уровнями
- [SEQUENTIAL_LEVEL_TRANSITIONS.md](SEQUENTIAL_LEVEL_TRANSITIONS.md) - Последовательные переходы
- [INTERLEVEL_PLATFORMER.md](INTERLEVEL_PLATFORMER.md) - Межуровневые платформеры

---

## 📁 Структура файлов проекта

### Основные директории
```
project-root/
├── docs/                    # Вся документация
├── memory_bank/             # Операционный контекст
├── pazzle-game-gamemaker/   # GameMaker Studio 2 проект
│   ├── assets/              # Ассеты (спрайты, звуки)
│   ├── objects/             # Игровые объекты
│   ├── scripts/             # Скрипты GML
│   ├── rooms/               # Комнаты/уровни
│   └── test_scenarios/      # Тестовые сценарии
├── assets/                  # Исходные ассеты
│   ├── audio/               # Звуки и музыка
│   └── sprites/             # Спрайты PNG
└── plans/                   # Планы разработки
```

---

## 🔍 Поиск по темам

### По типу документа
- **Руководства**: thematic_assets_guide.md, quick_asset_integration_guide.md, audio_system_guide.md
- **Планы**: gamemaker_migration_plan.md, asset_integration_plan.md, audio_enhancement_plan.md
- **Конфигурации**: music_themes_config.md, cave{N}_assets_config.json
- **Технические спецификации**: gms2_asset_migration_technical_spec.md, migration_tz.md

### По области
- **Визуал**: thematic_assets_guide.md, cave_assets_3_6_guide.md, cave_assets_plan.md
- **Аудио**: music_themes_config.md, audio_dramaturgy_guide.md, audio_system_guide.md
- **Геймплей**: levels_7_12_guide.md, deltarune_mechanics_integration_plan.md
- **Архитектура**: README.md, gms2_architecture.md, systemPatterns.md

---

## 📊 Статус документации

| Категория | Документов | Статус |
|-----------|-----------|--------|
| Memory Bank | 6 | ✅ Актуально |
| Ассеты | 4 | ✅ Актуально |
| Уровни | 2 | ✅ Актуально |
| Аудио | 4 | ✅ Актуально |
| Миграция GMS2 | 8 | ✅ Актуально |
| Тестирование | 4 | ✅ Актуально |
| Механики | 5 | ✅ Актуально |

**Всего документов**: 33+

---

## 🚀 Быстрые ссылки для разных ролей

### Для новых разработчиков
1. [DEVELOPER_CHECKLIST.md](DEVELOPER_CHECKLIST.md)
2. [README.md](README.md)
3. [activeContext.md](../memory_bank/activeContext.md)

### Для художников/дизайнеров
1. [quick_asset_integration_guide.md](quick_asset_integration_guide.md)
2. [cave_assets_3_6_guide.md](cave_assets_3_6_guide.md)
3. [thematic_assets_guide.md](thematic_assets_guide.md)

### Для звукорежиссеров
1. [music_themes_config.md](music_themes_config.md)
2. [audio_dramaturgy_guide.md](audio_dramaturgy_guide.md)
3. [audio_system_guide.md](audio_system_guide.md)

### Для геймдизайнеров
1. [levels_7_12_guide.md](levels_7_12_guide.md)
2. [deltarune_mechanics_integration_plan.md](deltarune_mechanics_integration_plan.md)
3. [achievements_system.md](achievements_system.md)

---

**Поддержка документации**: Все изменения должны отражаться в `memory_bank/progress.md`
