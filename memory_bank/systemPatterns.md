# System Patterns

## Архитектура
Система Memory Bank организована как набор взаимосвязанных Markdown-файлов, каждый из которых отвечает за определенный аспект проектной документации.

## Технические решения

### Структура файлов
- `projectbrief.md` - фундаментальный документ с целями и Project Deliverables
- `productContext.md` - продуктовый контекст и проблемы пользователей
- `activeContext.md` - текущий фокус работы
- `systemPatterns.md` - архитектурные решения
- `techContext.md` - технологический стек
- `progress.md` - статус выполнения и история изменений

### Паттерны
- **Single Source of Truth**: `projectbrief.md` - единственный источник процента выполнения
- **Canonical Status Values**: только `pending`, `in_progress`, `completed`, `blocked`
- **Weight Validation**: сумма весов всегда должна быть ровно 100

## Связи подсистем
Все файлы Memory Bank связаны через перекрестные ссылки и общую систему идентификаторов deliverables.
