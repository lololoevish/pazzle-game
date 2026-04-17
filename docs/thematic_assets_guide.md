# Руководство по тематическим ассетам ранних пещер

## Обзор

Данное руководство описывает систему тематических ассетов для ранних пещер (уровни 1-2) в GameMaker 2 версии игры. Каждая пещера имеет уникальную визуальную идентичность, соответствующую её тематике и геймплею.

## Структура ассетов

### Уровень 1: Лабиринт (cave1_maze)

**Тематика**: Исследование, эхо, загадочность  
**Цветовая палитра**: Темно-синие и серые тона  
**Особенности**: Скользящее движение, влажная атмосфера

#### Конфигурация
- **Файл**: `cave1_assets_config.json`
- **Локация**: `pazzle-game-gamemaker/assets/sprites/cave1_maze/`

#### Основные элементы

**Декорации потолка:**
- `spr_cave1_stalactite_small` (16x32) - Маленькие сталактиты
- `spr_cave1_stalactite_medium` (24x48) - Средние сталактиты
- `spr_cave1_stalactite_large` (32x64, 2 фрейма) - Большие с каплями

**Декорации пола:**
- `spr_cave1_stalagmite_small` (16x24) - Маленькие сталагмиты
- `spr_cave1_stalagmite_medium` (24x32) - Средние сталагмиты
- `spr_cave1_water_puddle_small` (32x16, 3 фрейма) - Лужи с рябью

**Источники света:**
- `spr_cave1_crystal_blue` (24x24, 4 фрейма) - Пульсирующие кристаллы
  - Радиус света: 64px
  - Цвет света: #4a90e2

**Эффекты:**
- `spr_cave1_fog` (128x128, 6 фреймов) - Плавающий туман
  - Alpha: 0.4
  - Движение: Медленное горизонтальное
- `spr_cave1_echo_effect` (64x64, 4 фрейма) - Визуальное эхо
  - Триггер: Движение игрока

#### Цветовая палитра
```
Основной: #1a2332 (темно-синий)
Акцент: #4a90e2 (голубой кристалл)
Детали: #2d3e50 (серо-синий)
Свет: #6bb6ff (яркий синий)
```

#### Освещение
- Ambient light: 0.3 (темная пещера)
- Shadow intensity: 0.7 (глубокие тени)
- Fog density: 0.4 (средний туман)

---

### Уровень 2: Архив (cave2_archive)

**Тематика**: Древние знания, библиотека, руны  
**Цветовая палитра**: Коричневые, золотистые тона  
**Особенности**: Двухфазная структура, книги и свитки

#### Конфигурация
- **Файл**: `cave2_assets_config.json`
- **Локация**: `pazzle-game-gamemaker/assets/sprites/cave2_archive/`

#### Основные элементы

**Мебель:**
- `spr_cave2_bookshelf_full` (64x96) - Полная книжная полка
- `spr_cave2_bookshelf_half` (64x96) - Частично заполненная
- `spr_cave2_lectern` (32x48) - Подставка для книг
- `spr_cave2_table_small` (48x32) - Стол со свитками

**Декорации:**
- `spr_cave2_scroll_rolled` (16x24) - Свернутые свитки
- `spr_cave2_scroll_open` (24x32) - Развернутые свитки
- `spr_cave2_book_pile` (32x24) - Стопки книг
- `spr_cave2_ancient_tablet` (48x64) - Древние таблички

**Руны и камни:**
- `spr_cave2_rune_stone_small` (32x32, 3 фрейма) - Малые рунные камни
- `spr_cave2_rune_stone_large` (48x48, 4 фрейма) - Большие рунные камни
  - Радиус света: 48px
  - Цвет света: #d4af37

**Источники света:**
- `spr_cave2_torch` (16x32, 6 фреймов) - Настенные факелы
  - Радиус света: 96px
  - Цвет света: #ff9933
- `spr_cave2_candle_holder` (16x24, 4 фрейма) - Подсвечники
  - Радиус света: 32px
  - Цвет света: #ffcc66

**Эффекты:**
- `spr_cave2_dust_particles` (64x64, 8 фреймов) - Частицы пыли
  - Alpha: 0.3
  - Движение: Медленное вертикальное
- `spr_cave2_glow_rune` (24x24, 4 фрейма) - Светящиеся руны на стенах
- `spr_cave2_letter_highlight` (32x32, 3 фрейма) - Подсветка букв в головоломке

#### Цветовая палитра
```
Основной: #3d2817 (темно-коричневый)
Акцент: #d4af37 (золотой)
Детали: #8b6f47 (коричневый)
Свет: #ff9933 (оранжевый огонь)
```

#### Освещение
- Ambient light: 0.4 (теплое освещение)
- Shadow intensity: 0.6 (мягкие тени)
- Warm tint: 0.3 (теплый оттенок)

---

## Использование в GameMaker

### Загрузка конфигурации

```gml
// Загрузка конфигурации пещеры 1
var cave1_config = load_json_file("assets/sprites/cave1_maze/cave1_assets_config.json");

// Загрузка конфигурации пещеры 2
var cave2_config = load_json_file("assets/sprites/cave2_archive/cave2_assets_config.json");
```

### Размещение декораций

```gml
// Пример размещения кристаллов в пещере 1
function place_cave1_crystals(room_width, room_height) {
    var crystal_count = 5;
    
    for (var i = 0; i < crystal_count; i++) {
        var x_pos = random_range(64, room_width - 64);
        var y_pos = random_range(64, room_height - 64);
        
        instance_create_layer(x_pos, y_pos, "Decorations_Bottom", obj_crystal_blue);
    }
}

// Пример размещения факелов в пещере 2
function place_cave2_torches(room_width, room_height) {
    var torch_spacing = 128;
    
    for (var x = torch_spacing; x < room_width; x += torch_spacing) {
        instance_create_layer(x, 64, "Decorations_Walls", obj_torch);
    }
}
```

### Управление освещением

```gml
// Применение освещения пещеры 1
function apply_cave1_lighting() {
    global.ambient_light = 0.3;
    global.shadow_intensity = 0.7;
    global.fog_density = 0.4;
}

// Применение освещения пещеры 2
function apply_cave2_lighting() {
    global.ambient_light = 0.4;
    global.shadow_intensity = 0.6;
    global.warm_tint = 0.3;
}
```

### Анимация эффектов

```gml
// Анимация тумана в пещере 1
function animate_fog() {
    if (instance_exists(obj_fog)) {
        with (obj_fog) {
            x += 0.5; // Медленное горизонтальное движение
            if (x > room_width + sprite_width) {
                x = -sprite_width;
            }
        }
    }
}

// Анимация частиц пыли в пещере 2
function animate_dust() {
    if (instance_exists(obj_dust_particles)) {
        with (obj_dust_particles) {
            y -= 0.3; // Медленное вертикальное движение вверх
            if (y < -sprite_height) {
                y = room_height + sprite_height;
            }
        }
    }
}
```

## Слои комнат

### Пещера 1: Лабиринт

Порядок слоев (снизу вверх):
1. **Background** - Основной фон пещеры
2. **Decorations_Floor** - Лужи, сталагмиты
3. **Instances** - Игровые объекты
4. **Decorations_Bottom** - Кристаллы
5. **Decorations_Top** - Сталактиты
6. **Effects_Player** - Эффект эха
7. **Effects_Foreground** - Туман

### Пещера 2: Архив

Порядок слоев (снизу вверх):
1. **Background** - Фон библиотеки
2. **Decorations_Floor** - Рунные камни
3. **Furniture** - Полки, столы
4. **Instances** - Игровые объекты
5. **Decorations_Items** - Свитки, книги
6. **Decorations_Walls** - Факелы, таблички
7. **Effects_Decorations** - Светящиеся руны
8. **Effects_Puzzle** - Подсветка букв
9. **Effects_Foreground** - Частицы пыли

## Частота размещения

### Пещера 1
- **Common** (часто): Маленькие сталактиты/сталагмиты, лужи
- **Medium** (средне): Средние сталактиты, кристаллы
- **Rare** (редко): Большие сталактиты

### Пещера 2
- **Common** (часто): Факелы, свитки, стопки книг
- **Medium** (средне): Полки, рунные камни, подсвечники
- **Rare** (редко): Подставки для книг, древние таблички

## Звуковое сопровождение

### Пещера 1
- `snd_cave1_water_drip` - Капли воды
- `snd_cave1_echo` - Эхо шагов
- `snd_cave1_wind` - Ветер в пещере

### Пещера 2
- `snd_cave2_pages_rustle` - Шелест страниц
- `snd_cave2_torch_crackle` - Треск факелов
- `snd_cave2_distant_whispers` - Далекий шепот

## Производительность

### Оптимизация
- Используйте атласы спрайтов для группировки похожих элементов
- Ограничьте количество анимированных объектов на экране (макс. 20)
- Используйте object pooling для частиц
- Отключайте анимацию объектов вне экрана

### Рекомендуемые лимиты
- Декорации: 30-50 на комнату
- Источники света: 5-10 на комнату
- Частицы: 10-20 активных систем
- Анимированные эффекты: 5-8 одновременно

## Следующие шаги

1. Создать реальные PNG-спрайты на основе заглушек
2. Настроить анимации в GameMaker
3. Создать объекты для декораций
4. Обновить конфигурации комнат rm_cave_maze и rm_cave_archive
5. Протестировать производительность
6. Добавить звуковые эффекты
7. Финальная полировка освещения

## Связанные документы

- `cave_assets_plan.md` - Детальный план создания ассетов
- `cave1_assets_config.json` - Конфигурация пещеры 1
- `cave2_assets_config.json` - Конфигурация пещеры 2
- `audio_dramaturgy_guide.md` - Руководство по звуковой драматургии
