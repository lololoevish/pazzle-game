# Технические спецификации интеграции ассетов в GameMaker Studio 2

## Обзор

Данный документ описывает технические требования и шаги для интеграции ассетов (спрайтов, аудио и шрифтов) в проекте GameMaker Studio 2. Основан на плане миграции из Rust-версии игры, с учетом текущего состояния проекта.

## Требования к ассетам

### Спрайты (Sprites)

#### Технические требования:
- Формат: PNG с прозрачностью (RGBA)
- Размеры: 32x32, 64x64, 128x128 пикселей (кратные степени 2)
- Центр вращения (Origin): центр спрайта (xOrigin = ширина/2, yOrigin = высота/2)
- Имя текстурной группы: "Default"
- Режим ограничительной рамки (BBox): Rectangle (режим 0)
- Горизонтальный и вертикальный допуск: 0
- Маска столкновений: по умолчанию (обычно все слои)

#### Категории спрайтов:
1. **Персонажи игрока**:
   - `spr_player`: 4 направления (вверх, вниз, влево, вправо) - 4 кадра
   - Имя: `spr_player_up`, `spr_player_down`, `spr_player_left`, `spr_player_right`

2. **NPC**:
   - `spr_npc`: 3 персонажа (Иара, Роан, Тель) - 3 кадра
   - Имя: `spr_npc_elder`, `spr_npc_mechanic`, `spr_npc_archivist`

3. **Интерактивные элементы**:
   - `spr_lever`: Рычаг прогресса
   - `spr_item`: Собираемые предметы
   - `spr_enemy`: Враждебные элементы

4. **Декорации и элементы уровня**:
   - `spr_platform`: Платформы и препятствия
   - `spr_decoration`: Декоративные элементы (зеркальные осколки, кристаллы, шпили)

5. **UI элементы**:
   - `spr_ui_sprites`: Кнопки, панели, индикаторы
   - `spr_e_key`: Клавиша E для подсказки взаимодействия

## Импорт спрайтов в GameMaker

### Процесс импорта:

1. **Подготовка изображений**:
   - Убедиться, что все изображения находятся в папке `assets/sprites/`
   - Соблюдать требования к формату и размеру

2. **Создание спрайта в GameMaker**:
   ```
   Right-click в папке Sprites → Create Sprite
   ```

3. **Настройка свойств спрайта**:
   - Установить Bounding Box Mode → Rectangle (0)
   - Установить Origin → Center
   - Установить Horizontal и Vertical Tolerance → 0
   - Установить Collision Mask → All

4. **Загрузка изображений**:
   - Перейти на вкладку Images
   - Добавить изображения для каждого кадра
   - Убедиться, что кадры правильно сгруппированы

5. **Настройка анимации** (если применимо):
   - Перейти на вкладку Animation
   - Настроить скорость воспроизведения (обычно 15 FPS)
   - Установить способ воспроизведения (Loop или Once)

### Пример GML для работы со спрайтами:

```gml
// В объекте Create Event
// Загрузка спрайта игрока в зависимости от направления
current_direction = "down";
sprite_index = spr_player_down;

// Переключение спрайта в зависимости от направления
function set_player_direction(direction) {
    switch(direction) {
        case "up":
            sprite_index = spr_player_up;
            break;
        case "down":
            sprite_index = spr_player_down;
            break;
        case "left":
            sprite_index = spr_player_left;
            image_xscale = -1; // отражение по горизонтали
            break;
        case "right":
            sprite_index = spr_player_right;
            image_xscale = 1;
            break;
    }
}

// Отрисовка спрайта с дополнительными параметрами
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, drawcolor, alpha);

// Проверка существования спрайта перед использованием
if (sprite_exists(spr_player)) {
    // безопасное использование спрайта
}
```

## Аудио (Audio)

### Технические требования:
- Форматы: WAV, MP3, OGG
- WAV: 16-bit, 44.1kHz для SFX
- MP3/OGG: для музыкальных треков
- Имя аудио ресурсов: начинается с `snd_` (SFX) или `mus_` (музыка)
- Музыка: с поддержкой цикличного воспроизведения

### Категории аудио:
1. **Звуковые эффекты (SFX)**:
   - `snd_ui_confirm`: Подтверждение действия
   - `snd_ui_cancel`: Отмена действия
   - `snd_ui_move`: Навигация
   - `snd_ui_success`: Успех
   - `snd_lever`: Опускание рычага
   - `snd_interaction`: Взаимодействие с элементами

2. **Музыка**:
   - `mus_menu`: Музыка в меню
   - `mus_town`: Музыка в город-хабе
   - `mus_cave`: Музыка в пещерах
   - `mus_victory`: Финальная музыка

### Пример GML для управления аудио:

```gml
// Инициализация системы аудио
function initialize_audio_system() {
    global.sfx_volume = 1.0;
    global.music_volume = 0.7;
    global.audio_muted = false;
    
    // Загрузка аудио ресурсов
    global.audio_resources = {
        sfx: {
            confirm: asset_get_index("snd_ui_confirm"),
            cancel: asset_get_index("snd_ui_cancel"),
            move: asset_get_index("snd_ui_move"),
            success: asset_get_index("snd_ui_success"),
            lever: asset_get_index("snd_lever"),
            interaction: asset_get_index("snd_interaction")
        },
        music: {
            menu: asset_get_index("mus_menu"),
            town: asset_get_index("mus_town"),
            cave: asset_get_index("mus_cave"),
            victory: asset_get_index("mus_victory")
        }
    };
}

// Воспроизведение SFX
function play_sound_effect(sound_name) {
    if (global.audio_muted) return;
    
    var sound_id = global.audio_resources.sfx[sound_name];
    if (sound_id != -1) {  // Проверяем, что ресурс существует
        audio_play_sound(sound_id, global.sfx_volume, false);
    } else {
        show_debug_message("Sound not found: " + string(sound_name));
    }
}

// Воспроизведение музыки
function play_background_music(music_name, loop = true) {
    if (global.audio_muted) return;
    
    // Остановить текущую музыку
    if (global.current_music_channel != -1) {
        audio_stop_sound(global.current_music_channel);
    }
    
    var music_id = global.audio_resources.music[music_name];
    if (music_id != -1) {
        global.current_music_channel = audio_play_sound(music_id, global.music_volume, loop);
    }
}

// Управление громкостью
function set_volume(category, volume) {
    volume = clamp(volume, 0, 1);
    if (category == "sfx") {
        global.sfx_volume = volume;
        // При необходимости можно регулировать громкость проигрываемых каналов
    } else if (category == "music") {
        global.music_volume = volume;
        if (global.current_music_channel != -1) {
            audio_sound_gain(global.current_music_channel, volume, 2.0);
        }
    }
}

// Отключение/включение звука
function toggle_audio_mute() {
    global.audio_muted = !global.audio_muted;
    
    if (global.audio_muted) {
        // Сохраняем текущие громкости
        global.stored_sfx_volume = global.sfx_volume;
        global.stored_music_volume = global.music_volume;
        
        // Устанавливаем в 0
        if (global.current_music_channel != -1) {
            audio_sound_gain(global.current_music_channel, 0, 2.0);
        }
    } else {
        // Восстанавливаем громкости
        set_volume("sfx", global.stored_sfx_volume);
        set_volume("music", global.stored_music_volume);
    }
}
```

## Шрифты (Fonts)

### Технические требования:
- Поддерживаемые форматы: TrueType (TTF), OpenType (OTF)
- Размер по умолчанию: 16-24pt
- Поддержка кириллицы: да (если применимо)
- Имя шрифта: начинается с `fnt_`

### Требуемые шрифты:
1. `fnt_default`: Основной шрифт интерфейса
2. `fnt_title`: Заголовки
3. `fnt_dialogue`: Текст диалогов

### Пример GML для работы с шрифтами:

```gml
// Проверка существования шрифта
if (font_exists(fnt_default)) {
    draw_set_font(fnt_default);
} else {
    draw_set_font(fn_default);  // резервный шрифт
}

// Установка стиля текста
function setup_text_style(font_style, color, alpha = 1.0) {
    if (font_exists(font_style)) {
        draw_set_font(font_style);
    }
    draw_set_color(color);
    draw_set_alpha(alpha);
}

// Отображение текста с обертыванием
function draw_wrapped_text(str, x, y, max_width) {
    if (font_exists(fnt_default)) {
        draw_set_font(fnt_default);
    }
    draw_text_ext(x, y, str, max_width, 0);
}

// Измерение размера текста
function get_text_dimensions(text, font) {
    if (font_exists(font)) {
        draw_set_font(font);
        var w = string_width(text);
        var h = string_height(text);
        return [w, h];
    }
    return [0, 0];
}
```

## Замена визуальной системы из Rust в GameMaker

### Анализ Rust-реализации:
В Rust-версии использовалась система визуальных ассетов с ThreadLocal storage и перечислением `Facing` для направлений игрока:
```rust
pub enum Facing {
    Down, Up, Left, Right
}
```

Спрайты загружались с помощью `include_bytes!` и устанавливались фильтр ближайшего соседа.

### Реализация в GameMaker:

1. **Замена ThreadLocal storage**:
   GameMaker использует глобальные переменные (`global`) для хранения данных уровня приложения:
   ```gml
   if (!global.assets_initialized) {
       global.asset_manifest = {
           player_sprites: [spr_player_down, spr_player_up, spr_player_left, spr_player_right],
           npc_sprites: [spr_npc_elder, spr_npc_mechanic, spr_npc_archivist],
           // ...
       };
       global.assets_initialized = true;
   }
   ```

2. **Замена перечисления Facing**:
   В GameMaker для направлений можно использовать строковые значения или числовые константы:
   ```gml
   #define DIR_UP      0
   #define DIR_DOWN    1
   #define DIR_LEFT    2
   #define DIR_RIGHT   3
   
   // или использовать строки
   current_facing = "up";
   ```

3. **Управление ассетами**:
   Вместо `load_texture` из Rust, GameMaker автоматически загружает ресурсы во время инициализации проекта:
   ```gml
   // В Create Event главного контроллера игры
   if (!asset_exists(spr_player, asset_sprite)) {
       show_error("Missing asset: spr_player", false);
   }
   ```

4. **Интеграция с игровой логикой**:
   Создание менеджера ассетов, аналогичного Rust-реализации:
   ```gml
   // Функция получения спрайта игрока по направлению
   function get_player_sprite_by_facing(facing_direction) {
       switch(string_lower(facing_direction)) {
           case "up": return spr_player_up;
           case "down": return spr_player_down;
           case "left": return spr_player_left;
           case "right": return spr_player_right;
           default: return spr_player_down;
       }
   }
   
   // Функция получения NPC-спрайта по индексу (аналогично Rust)
   function get_npc_sprite_by_index(index) {
       switch(index) {
           case 0: return spr_npc_elder;   // Иара
           case 1: return spr_npc_mechanic; // Роан
           case 2: return spr_npc_archivist; // Тель
           default: return spr_npc_elder;
       }
   }
   ```

## Практические рекомендации

### Оптимизация ассетов:
1. **Спрайты**: Использовать атласы (Texture Atlases) для группировки маленьких спрайтов
2. **Аудио**: Сжимать аудио файлы до приемлемого качества
3. **Шрифты**: Использовать только необходимые символы для уменьшения размера

### Организация папок:
```
assets/
├── sprites/
│   ├── characters/
│   ├── ui/
│   └── environment/
├── sounds/
│   ├── sfx/
│   └── music/
└── fonts/
```

### Резервные копии и версионирование:
- Использовать систему контроля версий (git) для отслеживания изменений в ассетах
- Хранить исходные файлы (PSD, AI) отдельно от конечных (PNG, WAV)

### Тестирование:
- Проверять корректность отображения ассетов на разных разрешениях экрана
- Проверять загрузку ассетов на целевой платформе (Windows, Web, Mobile)
- Тестировать производительность при использовании большого количества ассетов