# Чеклист для разработчиков GameMaker Studio 2

## Быстрая проверка перед началом работы

### Документация
- [ ] Прочитан `docs/README.md` - архитектура проекта
- [ ] Изучен `memory_bank/activeContext.md` - текущий фокус
- [ ] Просмотрен `memory_bank/progress.md` - последние изменения

### Интеграция ассетов пещер
- [ ] Изучен `docs/quick_asset_integration_guide.md`
- [ ] Проверены конфигурации в `pazzle-game-gamemaker/assets/sprites/cave{N}_{theme}/`
- [ ] Созданы необходимые спрайты в GameMaker Studio 2
- [ ] Настроены слои комнат согласно конфигурации
- [ ] Добавлено освещение для источников света
- [ ] Интегрированы ambient sounds

### Работа с головоломками
- [ ] Изучен `docs/levels_7_12_guide.md` для уровней 7-12
- [ ] Проверен `scr_puzzle_manager.gml` на поддержку типа головоломки
- [ ] Реализованы функции: init, update, draw, check_complete
- [ ] Добавлены тесты в `test_scenarios/`

### Перед коммитом
- [ ] Проверен код на синтаксические ошибки
- [ ] Запущены тесты (если применимо)
- [ ] Обновлен `memory_bank/progress.md` с описанием изменений
- [ ] Обновлен `memory_bank/activeContext.md` если изменилась архитектура
- [ ] Коммит с осмысленным сообщением

### Стандарты именования
- Спрайты: `spr_cave{N}_{element_name}`
- Объекты: `obj_{name}`
- Скрипты: `scr_{category}_{name}`
- Комнаты: `rm_cave_{theme}` или `rm_{location}`
- Звуки: `snd_cave{N}_{sound_name}`

### Полезные ссылки
- Конфигурации пещер 1-2: `docs/thematic_assets_guide.md`
- Конфигурации пещер 3-6: `docs/cave_assets_3_6_guide.md`
- Интеграция ассетов: `docs/quick_asset_integration_guide.md`
- Уровни 7-12: `docs/levels_7_12_guide.md`
- Тестирование: `docs/TESTING.md`, `docs/UNIT_TESTS.md`

---
**Обновлено**: 17 апреля 2026
