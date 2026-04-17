# План улучшения звуковой драматургии

**Дата создания**: 16.04.2026  
**Статус**: В разработке

## Текущее состояние аудио-системы

### Реализовано:
- ✅ Базовая система управления музыкой и SFX
- ✅ Регулировка громкости (master, music, sfx)
- ✅ Эмоциональные музыкальные темы (friendly_encounter, mercy_theme, peaceful_resolution)
- ✅ Звуки событий (UI, игрок, головоломки, NPC)
- ✅ Fail-safe режим при недоступности аудио-системы
- ✅ Совместимость со старым API через play_sfx()

### Проблемы:
- ❌ Все уровни используют одну музыкальную тему (snd_level_bg)
- ❌ Нет различия между ранними (1-2) и поздними (3-12) пещерами
- ❌ Отсутствует динамический баланс громкости для разных контекстов
- ❌ Нет плавных переходов между музыкальными темами
- ❌ Ограниченная вариативность звуков для повторяющихся действий

## План улучшений

### Этап 1: Расширение музыкальных тем для уровней

#### 1.1 Группировка уровней по тематике
- **Ранние пещеры (1-3)**: Исследование, загадочность
  - Уровень 1 (Лабиринт): Ambient, эхо, минимализм
  - Уровень 2 (Поиск слов): Спокойная, размышляющая
  - Уровень 3 (Память): Ритмичная, паттерны

- **Средние пещеры (4-6)**: Нарастание напряжения
  - Уровень 4 (Пары): Игривая, концентрация
  - Уровень 5 (Платформер): Динамичная, энергичная
  - Уровень 6 (Финальное испытание): Напряженная, эпичная

- **Новые пещеры (7-9)**: Мистика и испытания
  - Уровень 7 (Загадки Сфинкса): Древняя, мудрость
  - Уровень 8 (Звуковые Ловушки): Музыкальная, гармоничная
  - Уровень 9 (Прыгающий Путь): Быстрая, прыжковая

- **Поздние пещеры (10-12)**: Кульминация
  - Уровень 10 (Запоминалка): Медитативная, фокус
  - Уровень 11 (Песнь Пещер): Хоральная, резонанс
  - Уровень 12 (Финальный Подвиг): Героическая, триумф

#### 1.2 Новые музыкальные ресурсы
```gml
// Добавить в get_sound_resource():
case "snd_cave_early_1": // Уровни 1-3
case "snd_cave_early_2": 
case "snd_cave_early_3":
case "snd_cave_mid_4":   // Уровни 4-6
case "snd_cave_mid_5":
case "snd_cave_mid_6":
case "snd_cave_new_7":   // Уровни 7-9
case "snd_cave_new_8":
case "snd_cave_new_9":
case "snd_cave_late_10": // Уровни 10-12
case "snd_cave_late_11":
case "snd_cave_finale_12":
```

### Этап 2: Динамический баланс громкости

#### 2.1 Контекстные уровни громкости
```gml
// Новая структура audio_config
audio_config = {
    master_volume: 1.0,
    music_volume: 0.7,
    sfx_volume: 0.9,
    
    // Контекстные модификаторы
    context_modifiers: {
        menu: { music: 0.8, sfx: 1.0 },
        town: { music: 0.7, sfx: 0.9 },
        puzzle_active: { music: 0.5, sfx: 1.0 },
        puzzle_complete: { music: 0.9, sfx: 1.2 },
        dialogue: { music: 0.4, sfx: 0.8 },
        intense_moment: { music: 0.9, sfx: 1.1 }
    }
}
```

#### 2.2 Функция применения контекста
```gml
function apply_audio_context(context_name) {
    if (variable_struct_exists(audio_config.context_modifiers, context_name)) {
        var context = audio_config.context_modifiers[$ context_name];
        
        // Плавное изменение громкости
        var target_music_vol = audio_config.music_volume * context.music;
        var target_sfx_vol = audio_config.sfx_volume * context.sfx;
        
        // Применяем с интерполяцией
        lerp_volume("music", target_music_vol, 0.5);
        lerp_volume("sfx", target_sfx_vol, 0.3);
    }
}
```

### Этап 3: Плавные переходы музыки

#### 3.1 Система кроссфейда
```gml
function crossfade_music(new_music, fade_duration) {
    // Сохраняем текущую музыку
    var old_music = audio_config.current_music;
    var fade_steps = fade_duration * 60; // Конвертируем в фреймы
    
    // Запускаем новую музыку с нулевой громкостью
    audio_sound_set_gain(new_music, 0, 0);
    audio_play_sound(new_music, audio_config.sfx_channel, true);
    
    // Создаем объект для управления переходом
    var fade_controller = {
        old_music: old_music,
        new_music: new_music,
        current_step: 0,
        total_steps: fade_steps,
        target_volume: audio_config.music_volume * audio_config.master_volume
    };
    
    return fade_controller;
}
```

### Этап 4: Вариативность звуковых эффектов

#### 4.1 Пулы звуков для повторяющихся действий
```gml
// Вместо одного звука - массив вариантов
sound_pools = {
    footsteps: ["snd_step_1", "snd_step_2", "snd_step_3", "snd_step_4"],
    jump: ["snd_jump_1", "snd_jump_2"],
    ui_move: ["snd_ui_move_1", "snd_ui_move_2", "snd_ui_move_3"],
    puzzle_success: ["snd_success_1", "snd_success_2", "snd_success_3"]
}

function play_random_from_pool(pool_name) {
    if (variable_struct_exists(sound_pools, pool_name)) {
        var pool = sound_pools[$ pool_name];
        var random_sound = pool[irandom(array_length(pool) - 1)];
        play_event_sound(random_sound);
    }
}
```

### Этап 5: Адаптивная музыка

#### 5.1 Слои музыки в зависимости от прогресса
```gml
function update_music_layers(puzzle_progress) {
    // Базовый слой всегда играет
    // Добавляем слои по мере прогресса
    
    if (puzzle_progress > 0.25) {
        enable_music_layer("percussion");
    }
    if (puzzle_progress > 0.5) {
        enable_music_layer("melody");
    }
    if (puzzle_progress > 0.75) {
        enable_music_layer("harmony");
    }
}
```

## Приоритеты реализации

### Высокий приоритет:
1. Расширение музыкальных тем для уровней 1-12
2. Динамический баланс громкости по контексту
3. Плавные переходы между темами

### Средний приоритет:
4. Вариативность звуковых эффектов
5. Адаптивная музыка по прогрессу

### Низкий приоритет:
6. Пространственный звук (3D audio)
7. Реверберация для пещер
8. Динамические фильтры

## Технические требования

### Форматы аудио:
- Музыка: OGG Vorbis (loop-friendly)
- SFX: WAV (низкая латентность)

### Размеры файлов:
- Музыкальная тема: ~1-2 МБ (2-3 минуты loop)
- Звуковой эффект: ~10-50 КБ

### Производительность:
- Максимум 2 музыкальных трека одновременно (кроссфейд)
- До 8 одновременных SFX
- Предзагрузка музыки для текущего и следующего уровня

## Следующие шаги

1. Создать расширенную версию `scr_audio_manager.gml` с новыми функциями
2. Обновить `get_current_room_music()` для поддержки всех 12 уровней
3. Добавить систему контекстных модификаторов громкости
4. Реализовать кроссфейд между музыкальными темами
5. Обновить документацию по использованию аудио-системы
