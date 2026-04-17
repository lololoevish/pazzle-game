# Техническая спецификация миграции ассетов из Rust в GameMaker Studio 2

## Обзор

Этот документ описывает технические требования и спецификации для миграции всех визуальных ассетов, аудио и систем ресурсов из Rust-версии игры в GameMaker Studio 2. Документ включает детализированные инструкции по импорту, организации и программной интеграции ассетов.

## 1. Инвентаризация визуальных ассетов

### Спрайты (Sprites)

#### Игрок
- `spr_player_down` - Спрайт игрока, движущийся вниз (64x64)
- `spr_player_up` - Спрайт игрока, движущийся вверх (64x64)
- `spr_player_left` - Спрайт игрока, движущийся влево (64x64)
- `spr_player_right` - Спрайт игрока, движущийся вправо (64x64)

#### NPC
- `spr_npc_roan` - Спрайт механика Роана (64x64)
- `spr_npc_tellah` - Спрайт архивариуса Теля (64x64)
- `spr_npc_yore` - Спрайт старосты Йора (64x64)

#### Объекты
- `spr_lever` - Спрайт рычага (64x64)
- `spr_platform` - Спрайт платформы (64x64)
- `spr_item` - Спрайт предмета/награды (64x64)
- `spr_enemy` - Спрайт врага (64x64)

#### Декорации уровней
- `spr_clockwork_emblem` - Эмблема часовщика (64x64)
- `spr_mirror_shard` - Осколок зеркала (64x64)
- `spr_crystal_cluster` - Кластер кристаллов (64x64)
- `spr_core_spire` - Шпиль ядра (64x64)

### Свойства ассетов
- **Формат**: PNG с прозрачным фоном (RGBA 32-bit)
- **Размеры**: 64x64 пикселей
- **Стиль**: Пиксельная графика в стиле Deltarune с детализированными глазами и контурами
- **Палитра**: Темная фэнтези-тема с контрастными цветами

### Система анимации
- Направленные спрайты (4 варианта для игрока)
- Анимации обрабатываются программно (качание, пульсация, масштабирование)
- Нет отдельных кадров анимации - используются процедурные эффекты

## 2. Спецификации аудио-системы

### Аудио файлы
#### Звуковые эффекты:
- `snd_ui_move` - Навигация (0.45 относительная громкость)
- `snd_ui_confirm` - Подтверждение (0.55 относительная громкость)
- `snd_ui_cancel` - Отмена/ошибка (0.50 относительная громкость)
- `snd_ui_success` - Успех (0.58 относительная громкость)
- `snd_lever` - Активация рычага (0.62 относительная громкость)
- `snd_puzzle_select` - Выбор элемента головоломки (0.40 относительная громкость)
- `snd_puzzle_error` - Ошибка в головоломке (0.45 относительная громкость)
- `snd_puzzle_success` - Успешное решение (0.50 относительная громкость)
- `snd_puzzle_item` - Сбор предмета (0.35 относительная громкость)
- `snd_puzzle_fall` - Звук падения (0.40 относительная громкость)

#### Музыкальные треки:
- `mus_menu` - Меню (26% громкость)
- `mus_town` - Город (26% громкость)
- `mus_cave` - Пещеры (26% громкость)
- `mus_victory` - Победа (26% громкость)

### Архитектура аудио-менеджера

#### Объект менеджера (`obj_audio_manager`)
```gml
// В событии Create
audio_manager_init();
```

#### Инициализация аудио-менеджера
```gml
function audio_manager_init() {
    if (global.audio_manager_initialized) return;
    
    // Загрузка аудио ресурсов
    global.audio_resources = {
        sfx: {
            ui_move: snd_ui_move,
            ui_confirm: snd_ui_confirm, 
            ui_cancel: snd_ui_cancel,
            ui_success: snd_ui_success,
            lever: snd_lever,
            puzzle_select: snd_puzzle_select,
            puzzle_error: snd_puzzle_error,
            puzzle_success: snd_puzzle_success,
            puzzle_item: snd_puzzle_item,
            puzzle_fall: snd_puzzle_fall
        },
        music: {
            menu: mus_menu,
            town: mus_town, 
            cave: mus_cave,
            victory: mus_victory
        }
    };
    
    // Настройки аудио
    global.sfx_volume = 1.0;
    global.music_volume = 0.26; // 26% как в Rust
    global.audio_muted = false;
    global.current_music_track = -1;
    
    global.audio_manager_initialized = true;
}
```

#### Управление музыкой
```gml
// Проигрывание музыкального трека по имени
function audio_play_music_track(track_name) {
    if (global.audio_muted) return;
    
    // Остановка текущей музыки
    if (global.current_music_track != -1) {
        audio_stop_sound(global.current_music_track);
        global.current_music_track = -1;
    }
    
    var music_sound = global.audio_resources.music[track_name];
    if (music_sound != undefined) {
        global.current_music_track = audio_play_sound(music_sound, global.music_volume, true);
    }
}

// Синхронизация музыки с состоянием игры
function audio_sync_music_with_state(game_state) {
    switch (game_state) {
        case "menu": 
            audio_play_music_track("menu");
            break;
        case "town":
            audio_play_music_track("town"); 
            break;
        case "playing":
            audio_play_music_track("cave");
            break;
        case "victory":
            audio_play_music_track("victory");
            break;
        default:
            audio_stop_current_music();
            break;
    }
}
```

#### Управление звуковыми эффектами
```gml
// Проигрывание однократного звукового эффекта
function audio_play_sfx(sfx_name) {
    if (global.audio_muted) return;
    
    var sound_id = global.audio_resources.sfx[sfx_name];
    if (sound_id != undefined) {
        var volume = audio_get_sfx_volume(sfx_name);
        audio_play_sound(sound_id, volume, false);
    }
}

// Получение соответствующей громкости для конкретного SFX
function audio_get_sfx_volume(sfx_name) {
    switch (sfx_name) {
        case "ui_move":        return global.sfx_volume * 0.45;
        case "ui_confirm":     return global.sfx_volume * 0.55;
        case "ui_cancel":      return global.sfx_volume * 0.50;
        case "ui_success":     return global.sfx_volume * 0.58;
        case "lever":          return global.sfx_volume * 0.62;
        case "puzzle_select":  return global.sfx_volume * 0.40;
        case "puzzle_error":   return global.sfx_volume * 0.45;
        case "puzzle_success": return global.sfx_volume * 0.50;
        case "puzzle_item":    return global.sfx_volume * 0.35;
        case "puzzle_fall":    return global.sfx_volume * 0.40;
        default:               return global.sfx_volume;
    }
}
```

## 3. Структура проекта GameMaker

### Рекомендуемая структура папок ассетов
```
assets/
├── sprites/
│   ├── player/
│   │   ├── spr_player_down.yy
│   │   ├── spr_player_up.yy
│   │   ├── spr_player_left.yy
│   │   └── spr_player_right.yy
│   ├── npcs/
│   │   ├── spr_npc_roan.yy
│   │   ├── spr_npc_tellah.yy
│   │   └── spr_npc_yore.yy
│   ├── objects/
│   │   ├── spr_lever.yy
│   │   ├── spr_item.yy
│   │   └── spr_platform.yy
│   └── ui/
│       ├── spr_ui_elements.yy
│       └── spr_backgrounds.yy
├── sounds/
│   ├── sfx/
│   │   ├── snd_ui_move.ogg
│   │   ├── snd_ui_confirm.ogg
│   │   └── [...other SFX...]
│   └── music/
│       ├── mus_menu.ogg
│       ├── mus_town.ogg
│       └── [...other music...]
└── fonts/
    ├── fnt_main.yy
    └── fnt_ui.yy
```

### Структура скриптов
```
scripts/
├── asset_management/
│   ├── scr_sprite_loader.gml
│   ├── scr_animation_system.gml
│   ├── scr_resource_manager.gml
│   ├── scr_draw_utils.gml
│   ├── scr_asset_demo.gml
│   └── scr_asset_manager_master.gml
├── audio/
│   └── scr_audio_manager.gml
└── gameplay/
    └── scr_visual_assets.yy  // Аналог Rust visual_assets.rs
```

## 4. Скрипты управления ассетами

### 1. `scr_sprite_loader.gml` - Загрузчик спрайтов
```gml
// Управление загрузкой и кешированием спрайтов

// Загрузка и кеширование спрайта игрока
function load_player_sprites() {
    var player_sprites = {
        down: spr_player_down,
        up: spr_player_up,
        left: spr_player_left,
        right: spr_player_right
    };
    
    if (global.player_sprites == undefined) {
        global.player_sprites = player_sprites;
    }
    
    return player_sprites;
}

// Загрузка и кеширование спрайтов NPC по индексу
function load_npc_sprites_by_index(index) {
    var npc_sprites = [
        spr_npc_roan,
        spr_npc_tellah,
        spr_npc_yore
    ];
    
    if (index >= 0 && index < array_length(npc_sprites)) {
        return npc_sprites[index];
    }
    
    return undefined;
}
```

### 2. `scr_animation_system.gml` - Система анимации
```gml
// Система анимации, соответствующая Rust версии

// Базовая анимация - пульсация
function animate_pulse(time, min_scale, max_scale) {
    return min_scale + (max_scale - min_scale) * abs(sin(time));
}

// Анимация покачивания
function animate_bobbing(time, min_offset, max_offset) {
    return min_offset + (max_offset - min_offset) * sin(time) * 0.5;
}

// Анимация шага (шагающая анимация)
function animate_step_animation(current_time, frame_duration, num_frames) {
    var frame = floor(current_time / frame_duration) % num_frames;
    return frame;
}

// Временная система анимации
function get_animation_time() {
    return global.animation_time;
}
```

### 3. `scr_draw_utils.gml` - Утилиты отрисовки
```gml
// Утилиты для отрисовки спрайтов с эффектами

// Отрисовка спрайта с масштабированием и тонированием
function draw_sprite_scaled(sprite_id, x, y, width, height, color, alpha) {
    var original_w = sprite_get_width(sprite_id);
    var original_h = sprite_get_height(sprite_id);
    
    var scale_x = width / original_w;
    var scale_y = height / original_h;
    
    draw_sprite_ext(sprite_id, 0, x, y, scale_x, scale_y, 0, color, alpha);
}

// Отрисовка анимированного спрайта (пульсирующего)
function draw_animated_sprite(sprite_id, x, y, base_width, base_height, time_offset) {
    var pulse = animate_pulse(get_animation_time() + time_offset, 0.9, 1.1);
    var width = base_width * pulse;
    var height = base_height * pulse;
    
    draw_sprite_scaled(sprite_id, x, y, width, height, c_white, 1.0);
}

// Отрисовка спрайта с эффектом покачивания
function draw_bobbing_sprite(sprite_id, x, y, base_width, base_height, time_offset) {
    var bob = animate_bobbing(get_animation_time() + time_offset, 0, 3);
    var adjusted_y = y + bob;
    
    draw_sprite_scaled(sprite_id, x, adjusted_y, base_width, base_height, c_white, 1.0);
}
```

### 4. `scr_resource_manager.gml` - Менеджер ресурсов
```gml
// Управление жизненным циклом ресурсов

// Инициализация системы ресурсов
function resource_manager_init() {
    if (global.resource_manager_initialized) return;
    
    global.assets_loaded = false;
    global.asset_loading_queue = ds_list_create();
    global.sprite_cache = ds_map_create();
    global.animation_times = {};
    
    global.resource_manager_initialized = true;
}

// Обновление времени анимации
function update_animation_time() {
    global.animation_time = (global.animation_time + delta_time);
}

// Очистка ресурсов
function resource_manager_cleanup() {
    if (global.sprite_cache != undefined) {
        ds_map_destroy(global.sprite_cache);
    }
    if (global.asset_loading_queue != undefined) {
        ds_list_destroy(global.asset_loading_queue);
    }
}
```

## 5. Спецификации интеграции

### Визуальные эффекты
- Имитировать процедурные анимации Rust версии:
  - Пульсация предметов (например, наград)
  - Покачивание NPC
  - Анимация шага для движущихся объектов
  - Временные эффекты с использованием `animation_time`

### Цветовые палитры
- Сохранить цветовые схемы уровней:
  - Уровень 1 - Синие тона (#78CCFF)
  - Уровень 2 - Желтые/янтарные тона (#FFD67C)
  - Уровень 3 - Фиолетовые тона (#C29CFF)
  - Уровень 4 - Розовые тона (#FF92C0)
  - Уровень 5 - Зеленые/циановые тона (#7EF0C6)
  - Уровень 6 - Красные тона (#FF7676)

### Оптимизация
- Использовать кеширование спрайтов для повторного использования
- Реализовать систему управления памятью для ассетов
- Оптимизировать количество вызовов отрисовки

## 6. Требования к ассетам

### Спрайты
- Сохранить прозрачный фон (RGBA 32-bit PNG)
- Размеры оптимизировать под GameMaker (степени 2: 32, 64, 128 и т.д.)
- Установить центр в качестве точки отсчета для анимаций
- Убедиться, что все спрайты имеют одинаковые размеры для соответствия Rust версии

### Аудио
- Конвертировать WAV в OGG (лучшее сжатие без потерь качества)
- Установить битрейт 128 kbps для SFX, 192 kbps для музыки
- Обеспечить нормализацию громкости для согласованности
- Использовать потоковое воспроизведение для музыки, в память для SFX

### Шрифты
- Импортировать TTF/OTF файлы для консистентности
- Обеспечить поддержку кириллицы (так как в игре есть русский текст)
- Создать несколько размеров шрифтов по необходимости

## 7. План интеграции

### Этап 1: Импорт базовых ассетов
1. Импортировать все спрайты в соответствующие папки
2. Настроить спрайты с корректными точками отсчета
3. Импортировать и конвертировать аудио файлы
4. Создать шрифты для интерфейса

### Этап 2: Реализация систем ресурсов
1. Создать и протестировать скрипты управления ассетами
2. Реализовать систему кеширования спрайтов
3. Настроить аудио-менеджер с соответствием Rust версии
4. Протестировать воспроизведение аудио

### Этап 3: Интеграция с игровыми системами
1. Заменить вызовы Rust visual_assets системой GameMaker
2. Настроить анимации для спрайтов
3. Интегрировать аудио в игровые состояния
4. Проверить соответствие визуальных эффектов Rust версии

### Этап 4: Оптимизация и тестирование
1. Оптимизировать производительность системы ресурсов
2. Провести тестирование на различных платформах
3. Проверить использование памяти и производительность
4. Обеспечить соответствие требованиям по размеру и производительности

## 8. Контрольные точки качества

### До интеграции
- [ ] Все исходные ассеты проверены и сохранены в резервной копии
- [ ] Подтверждена совместимость форматов для GameMaker
- [ ] Стандартизированы соглашения по именованию
- [ ] Применены оптимизации разрешений и размеров

### После интеграции
- [ ] Все спрайты отображаются корректно с правильными точками отсчета
- [ ] Временные параметры анимации соответствуют Rust версии
- [ ] Аудио воспроизводится с соответствующим качеством и громкостью
- [ ] Использование памяти остается в допустимых пределах
- [ ] Производительность стабильна на целевых платформах
- [ ] Ассеты отображаются корректно при различных разрешениях

Данный план обеспечивает систематический подход к интеграции ассетов из Rust-версии в GameMaker Studio 2, сохранив качество, производительность и консистентность с оригинальной реализацией.