/*
 * Аудио-менеджер
 * Управляет воспроизведением музыки и звуковых эффектов
 */

// Инициализация аудио-параметров
var audio_config = {
    master_volume: 1.0,
    music_volume: 0.7,
    sfx_volume: 0.9,
    current_music: undefined,
    music_playing: false,
    sfx_channel: 0,
    current_context: "neutral",
    
    // Система приоритетов музыки
    music_priority: 0, // 0 = room music, 1 = contextual, 2 = emotional, 3 = override
    priority_music: undefined, // Музыка с приоритетом
    priority_timer: 0, // Таймер для временных приоритетов
    
    // Контекстные модификаторы громкости
    context_modifiers: {
        neutral: { music: 1.0, sfx: 1.0 },
        menu: { music: 0.8, sfx: 1.0 },
        town: { music: 0.7, sfx: 0.9 },
        puzzle_active: { music: 0.5, sfx: 1.0 },
        puzzle_complete: { music: 0.9, sfx: 1.2 },
        dialogue: { music: 0.4, sfx: 0.8 },
        intense_moment: { music: 0.9, sfx: 1.1 },
        victory: { music: 1.0, sfx: 1.2 }
    }
};

// Функция проигрывания музыки
function play_music(sound_index) {
    // Проверяем, что ресурс не пустой/не определен
    if (sound_index != undefined && sound_index != -1 && sound_exists(sound_index)) {
        // Если проигрывается другая музыка, останавливаем её
        if (audio_config.music_playing && audio_config.current_music != sound_index) {
            stop_music();
        }
        
        // Устанавливаем громкость музыки
        audio_sound_set_gain(sound_index, audio_config.music_volume * audio_config.master_volume, 0);
        
        // Проигрываем музыку в цикле
        audio_play_sound(sound_index, audio_config.sfx_channel, true);
        audio_config.current_music = sound_index;
        audio_config.music_playing = true;
    } else {
        // Если звук не существует, просто показываем предупреждение, но не вызываем ошибку
        // show_debug_message("WARNING: Music sound '" + string(sound_index) + "' does not exist");
    }
}

// Функция остановки музыки
function stop_music() {
    if (audio_config.music_playing && audio_config.current_music != undefined) {
        audio_stop_sound(audio_config.current_music);
        audio_config.music_playing = false;
        audio_config.current_music = undefined;
    }
}

// Функция для установки музыкальной темы в зависимости от эмоционального состояния
function set_emotional_music_state(state) {
    var music_to_play = undefined;
    
    switch(state) {
        case "neutral":
            // Сбрасываем приоритет и возвращаемся к музыке комнаты
            clear_music_priority();
            var room_based_music = get_current_room_music();
            if (room_based_music != undefined) {
                play_music_with_priority(room_based_music, 0);
            }
            break;
        case "friendly_encounter":
            music_to_play = get_sound_resource("snd_music_friendly_encounter");
            if (music_to_play != undefined && music_to_play != -1) {
                play_music_with_priority(music_to_play, 2); // Эмоциональный приоритет
            }
            break;
        case "mercy_theme":
            music_to_play = get_sound_resource("snd_music_mercy_theme");
            if (music_to_play != undefined && music_to_play != -1) {
                play_music_with_priority(music_to_play, 2);
            }
            break;
        case "peaceful_resolution":
            music_to_play = get_sound_resource("snd_music_peaceful_resolution");
            if (music_to_play != undefined && music_to_play != -1) {
                play_music_with_priority(music_to_play, 2);
            }
            break;
        default:
            // Оставить текущую музыку
            break;
    }
}

// Получение музыки в зависимости от текущей комнаты
function get_current_room_music() {
    var room_name = room_get_name(room);
    
    switch (room_name) {
        case "rm_menu":
            return get_sound_resource("snd_menu_bg");
        case "rm_town":
            return get_sound_resource("snd_town_bg");
        
        // Ранние пещеры (1-3)
        case "rm_cave_maze":
        case "rm_level_1":
            return get_sound_resource("snd_cave_early_1");
        case "rm_cave_archive":
        case "rm_level_2":
            return get_sound_resource("snd_cave_early_2");
        case "rm_cave_rhythm":
        case "rm_level_3":
            return get_sound_resource("snd_cave_early_3");
        
        // Средние пещеры (4-6)
        case "rm_cave_pairs":
        case "rm_level_4":
            return get_sound_resource("snd_cave_mid_4");
        case "rm_cave_platformer":
        case "rm_level_5":
            return get_sound_resource("snd_cave_mid_5");
        case "rm_cave_final":
        case "rm_level_6":
            return get_sound_resource("snd_cave_mid_6");
        
        // Новые пещеры (7-9)
        case "rm_cave_7":
            return get_sound_resource("snd_cave_new_7");
        case "rm_cave_8":
            return get_sound_resource("snd_cave_new_8");
        case "rm_cave_9":
            return get_sound_resource("snd_cave_new_9");
        
        // Поздние пещеры (10-12)
        case "rm_cave_10":
            return get_sound_resource("snd_cave_late_10");
        case "rm_cave_11":
            return get_sound_resource("snd_cave_late_11");
        case "rm_cave_12":
            return get_sound_resource("snd_cave_finale_12");
        
        case "rm_victory":
            return get_sound_resource("snd_victory_bg");
        default:
            return get_sound_resource("snd_level_bg"); // Fallback
    }
}

// Функция проигрывания звукового эффекта
function play_sound(sound_index) {
    // Проверяем, что ресурс не пустой/не определен
    if (sound_index != undefined && sound_index != -1 && sound_exists(sound_index)) {
        // Устанавливаем громкость SFX
        audio_sound_set_gain(sound_index, audio_config.sfx_volume * audio_config.master_volume, 0);
        
        // Проигрываем звук
        audio_play_sound(sound_index, audio_config.sfx_channel, false);
    } else {
        // Если звук не существует, просто показываем предупреждение, но не вызываем ошибку
        // show_debug_message("WARNING: Sound effect '" + string(sound_index) + "' does not exist");
    }
}

// Функция установки громкости
function set_volume(volume_type, value) {
    // Ограничиваем значение громкости от 0 до 1
    value = clamp(value, 0, 1);
    
    switch (volume_type) {
        case "master":
            audio_config.master_volume = value;
            break;
        case "music":
            audio_config.music_volume = value;
            // Применяем новую громкость к текущей музыке
            if (audio_config.music_playing && audio_config.current_music != undefined) {
                audio_sound_set_gain(audio_config.current_music, 
                                   audio_config.music_volume * audio_config.master_volume, 0);
            }
            break;
        case "sfx":
            audio_config.sfx_volume = value;
            break;
        default:
            show_debug_message("WARNING: Unknown volume type '" + volume_type + "'");
            break;
    }
}

// Функция получения текущей громкости
function get_volume(volume_type) {
    switch (volume_type) {
        case "master":
            return audio_config.master_volume;
        case "music":
            return audio_config.music_volume;
        case "sfx":
            return audio_config.sfx_volume;
        default:
            show_debug_message("WARNING: Unknown volume type '" + volume_type + "'");
            return 0;
    }
}

// Функция паузы музыки
function pause_music() {
    if (audio_config.music_playing && audio_config.current_music != undefined) {
        audio_pause_sound(audio_config.current_music);
    }
}

// Функция возобновления музыки
function resume_music() {
    if (audio_config.current_music != undefined) {
        audio_resume_sound(audio_config.current_music);
        audio_config.music_playing = true;
    }
}

// Функция проверки состояния аудио
function is_audio_available() {
    // Проверяем, доступна ли аудио-система
    return audio_system() != audio_no_system;
}

// Функция инициализации аудио-системы
function init_audio_system() {
    if (!is_audio_available()) {
        show_debug_message("WARNING: Audio system not available, running in silent mode");
        // В случае недоступности системы, устанавливаем все громкости в 0
        audio_config.master_volume = 0;
        audio_config.music_volume = 0;
        audio_config.sfx_volume = 0;
        return false;
    }
    return true;
}

// Функция для удобного воспроизведения музыки по названию состояния
function play_music_by_state(game_state) {
    var sound_to_play = get_sound_resource("snd_menu_bg");
    
    switch (game_state) {
        case "menu":
            sound_to_play = get_sound_resource("snd_menu_bg");
            break;
        case "town":
            sound_to_play = get_sound_resource("snd_town_bg");
            break;
        case "playing_level_1":
        case "playing_level_2":
        case "playing_level_3":
        case "playing_level_4":
        case "playing_level_5":
        case "playing_level_6":
        case "playing_level_7":
        case "playing_level_8":
        case "playing_level_9":
        case "playing_level_10":
        case "playing_level_11":
        case "playing_level_12":
            sound_to_play = get_sound_resource("snd_level_bg");
            break;
        case "victory":
            sound_to_play = get_sound_resource("snd_victory_bg");
            break;
        default:
            show_debug_message("WARNING: No music defined for state '" + game_state + "'");
            break;
    }
    
    if (sound_to_play != undefined && sound_to_play != -1) {
        play_music(sound_to_play);
    }
}

// Вспомогательная функция для получения ресурса по имени
function get_global_audio_resource(variable_name) {
    if (variable_global_exists(variable_name)) {
        return variable_global_get(variable_name);
    }

    return -1;
}

function get_sound_resource(name) {
    // Возвращаем -1 если ресурс не найден, чтобы избежать ошибок
    // В реальном проекте эти переменные будут определены в ресурсах
    switch (name) {
        // Основные темы
        case "snd_menu_bg": return get_global_audio_resource("snd_menu_bg");
        case "snd_town_bg": return get_global_audio_resource("snd_town_bg");
        case "snd_level_bg": return get_global_audio_resource("snd_level_bg");
        case "snd_victory_bg": return get_global_audio_resource("snd_victory_bg");
        
        // Музыка для ранних пещер (1-3)
        case "snd_cave_early_1": return get_global_audio_resource("snd_cave_early_1");
        case "snd_cave_early_2": return get_global_audio_resource("snd_cave_early_2");
        case "snd_cave_early_3": return get_global_audio_resource("snd_cave_early_3");
        
        // Музыка для средних пещер (4-6)
        case "snd_cave_mid_4": return get_global_audio_resource("snd_cave_mid_4");
        case "snd_cave_mid_5": return get_global_audio_resource("snd_cave_mid_5");
        case "snd_cave_mid_6": return get_global_audio_resource("snd_cave_mid_6");
        
        // Музыка для новых пещер (7-9)
        case "snd_cave_new_7": return get_global_audio_resource("snd_cave_new_7");
        case "snd_cave_new_8": return get_global_audio_resource("snd_cave_new_8");
        case "snd_cave_new_9": return get_global_audio_resource("snd_cave_new_9");
        
        // Музыка для поздних пещер (10-12)
        case "snd_cave_late_10": return get_global_audio_resource("snd_cave_late_10");
        case "snd_cave_late_11": return get_global_audio_resource("snd_cave_late_11");
        case "snd_cave_finale_12": return get_global_audio_resource("snd_cave_finale_12");
        
        // UI звуки
        case "snd_ui_move": return get_global_audio_resource("snd_ui_move");
        case "snd_ui_confirm": return get_global_audio_resource("snd_ui_confirm");
        case "snd_ui_cancel": return get_global_audio_resource("snd_ui_cancel");
        case "snd_ui_success": return get_global_audio_resource("snd_ui_success");
        
        // Игровые звуки
        case "snd_lever_pull": return get_global_audio_resource("snd_lever_pull");
        case "snd_level_complete": return get_global_audio_resource("snd_level_complete");
        case "snd_reward_obtained": return get_global_audio_resource("snd_reward_obtained");
        case "snd_puzzle_solve": return get_global_audio_resource("snd_puzzle_solve");
        case "snd_player_move": return get_global_audio_resource("snd_player_move");
        case "snd_player_jump": return get_global_audio_resource("snd_player_jump");
        case "snd_item_collect": return get_global_audio_resource("snd_item_collect");
        
        // Эмоциональные темы
        case "snd_music_friendly_encounter": return get_global_audio_resource("snd_music_friendly_encounter");
        case "snd_music_mercy_theme": return get_global_audio_resource("snd_music_mercy_theme");
        case "snd_music_peaceful_resolution": return get_global_audio_resource("snd_music_peaceful_resolution");
        
        // Deltarune-стиль звуки
        case "snd_mercy_action": return get_global_audio_resource("snd_mercy_action");
        case "snd_friendship_gained": return get_global_audio_resource("snd_friendship_gained");
        case "snd_npc_friendly_response": return get_global_audio_resource("snd_npc_friendly_response");
        
        default: return -1;
    }
}

// Функция для удобного воспроизведения звуков событий
function play_event_sound(event_type) {
    var sound_to_play = undefined;
    
    switch (event_type) {
        case "ui_move":
            sound_to_play = get_sound_resource("snd_ui_move");
            break;
        case "ui_confirm":
            sound_to_play = get_sound_resource("snd_ui_confirm");
            break;
        case "ui_cancel":
            sound_to_play = get_sound_resource("snd_ui_cancel");
            break;
        case "ui_success":
            sound_to_play = get_sound_resource("snd_ui_success");
            break;
        case "lever_pull":
            sound_to_play = get_sound_resource("snd_lever_pull");
            break;
        case "level_complete":
            sound_to_play = get_sound_resource("snd_level_complete");
            break;
        case "reward_obtained":
            sound_to_play = get_sound_resource("snd_reward_obtained");
            break;
        case "puzzle_solve":
            sound_to_play = get_sound_resource("snd_puzzle_solve");
            break;
        case "player_move":
            sound_to_play = get_sound_resource("snd_player_move");
            break;
        case "player_jump":
            sound_to_play = get_sound_resource("snd_player_jump");
            break;
        case "item_collect":
            sound_to_play = get_sound_resource("snd_item_collect");
            break;
        case "mercy_action":
            sound_to_play = get_sound_resource("snd_mercy_action");
            break;
        case "friendship_gained":
            sound_to_play = get_sound_resource("snd_friendship_gained");
            break;
        case "npc_friendly_response":
            sound_to_play = get_sound_resource("snd_npc_friendly_response");
            break;
        default:
            show_debug_message("WARNING: No sound defined for event '" + event_type + "'");
            break;
    }
    
    if (sound_to_play != undefined && sound_to_play != -1) {
        play_sound(sound_to_play);
    }
}

// Совместимость со старым API
function play_sfx(sound_name) {
    switch (sound_name) {
        case "confirm":
        case "dialogue_start":
        case "interaction":
            play_event_sound("ui_confirm");
            break;
        case "cancel":
            play_event_sound("ui_cancel");
            break;
        case "move":
            play_event_sound("ui_move");
            break;
        case "success":
            play_event_sound("ui_success");
            break;
        case "lever":
            play_event_sound("lever_pull");
            break;
        case "puzzle_success":
            play_event_sound("puzzle_solve");
            break;
        case "puzzle_completed":
            play_event_sound("level_complete");
            break;
        default:
            play_event_sound(sound_name);
            break;
    }
}

function initialize_audio() {
    return init_audio_manager();
}

// Функция получения списка доступных аудио-устройств
function get_audio_devices() {
    var devices = [];
    var count = audio_get_recorder_count();
    
    for (var i = 0; i < count; i++) {
        var device_info = audio_get_recorder_info(i);
        array_push(devices, device_info);
    }
    
    return devices;
}

// Функция установки аудио-устройства
function set_audio_device(device_index) {
    // Может быть реализована позже для переключения устройств
}

// Вспомогательная функция для ограничения значений
function clamp(val, min, max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
}

// Функция инициализации
function init_audio_manager() {
    init_audio_system();
}

// Функция применения аудио-контекста
function apply_audio_context(context_name) {
    if (!variable_struct_exists(audio_config.context_modifiers, context_name)) {
        show_debug_message("WARNING: Unknown audio context '" + context_name + "'");
        return;
    }
    
    audio_config.current_context = context_name;
    var context = audio_config.context_modifiers[$ context_name];
    
    // Применяем модификаторы к текущей музыке
    if (audio_config.music_playing && audio_config.current_music != undefined) {
        var target_volume = audio_config.music_volume * audio_config.master_volume * context.music;
        audio_sound_set_gain(audio_config.current_music, target_volume, 0);
    }
}

// Функция получения текущего контекста
function get_current_audio_context() {
    return audio_config.current_context;
}

// Функция кроссфейда между музыкальными темами
function crossfade_music(new_music, fade_duration_seconds) {
    if (new_music == undefined || new_music == -1 || !sound_exists(new_music)) {
        return;
    }
    
    // Если это та же музыка, ничего не делаем
    if (audio_config.current_music == new_music) {
        return;
    }
    
    var old_music = audio_config.current_music;
    
    // Если старой музыки нет, просто запускаем новую
    if (old_music == undefined || !audio_config.music_playing) {
        play_music(new_music);
        return;
    }
    
    // Запускаем новую музыку с нулевой громкостью
    audio_sound_set_gain(new_music, 0, 0);
    audio_play_sound(new_music, audio_config.sfx_channel, true);
    
    // Плавно уменьшаем громкость старой музыки
    var target_volume = audio_config.music_volume * audio_config.master_volume;
    var fade_time_ms = fade_duration_seconds * 1000;
    
    audio_sound_set_gain(old_music, 0, fade_time_ms);
    audio_sound_set_gain(new_music, target_volume, fade_time_ms);
    
    // Обновляем текущую музыку
    audio_config.current_music = new_music;
    audio_config.music_playing = true;
    
    // Останавливаем старую музыку после завершения фейда
    // (в реальной реализации нужен таймер или alarm)
}

// Функция для плавного изменения громкости
function lerp_volume(volume_type, target_value, duration_seconds) {
    target_value = clamp(target_value, 0, 1);
    var duration_ms = duration_seconds * 1000;
    
    switch (volume_type) {
        case "music":
            audio_config.music_volume = target_value;
            if (audio_config.music_playing && audio_config.current_music != undefined) {
                var final_volume = target_value * audio_config.master_volume;
                audio_sound_set_gain(audio_config.current_music, final_volume, duration_ms);
            }
            break;
        case "sfx":
            audio_config.sfx_volume = target_value;
            break;
        case "master":
            audio_config.master_volume = target_value;
            if (audio_config.music_playing && audio_config.current_music != undefined) {
                var final_volume = audio_config.music_volume * target_value;
                audio_sound_set_gain(audio_config.current_music, final_volume, duration_ms);
            }
            break;
    }
}

// ============================================
// СИСТЕМА ПРИОРИТЕТОВ МУЗЫКИ
// ============================================

// Функция воспроизведения музыки с приоритетом
// priority: 0 = room music, 1 = contextual, 2 = emotional, 3 = override
function play_music_with_priority(sound_index, priority, duration_seconds) {
    if (duration_seconds == undefined) duration_seconds = -1; // -1 = бесконечно
    
    // Проверяем приоритет
    if (priority < audio_config.music_priority) {
        // Текущая музыка имеет более высокий приоритет, игнорируем
        return false;
    }
    
    // Если приоритет равен или выше, меняем музыку
    if (sound_index != audio_config.current_music) {
        crossfade_to_music(sound_index, 1.5);
    }
    
    // Обновляем приоритет
    audio_config.music_priority = priority;
    audio_config.priority_music = sound_index;
    
    // Устанавливаем таймер если нужно
    if (duration_seconds > 0) {
        audio_config.priority_timer = duration_seconds * 60; // Конвертируем в фреймы
    } else {
        audio_config.priority_timer = -1;
    }
    
    return true;
}

// Функция сброса приоритета музыки
function clear_music_priority() {
    audio_config.music_priority = 0;
    audio_config.priority_music = undefined;
    audio_config.priority_timer = 0;
}

// Функция обновления системы приоритетов (вызывать в Step)
function update_music_priority() {
    // Уменьшаем таймер если он активен
    if (audio_config.priority_timer > 0) {
        audio_config.priority_timer--;
        
        // Если таймер истек, возвращаемся к музыке комнаты
        if (audio_config.priority_timer == 0) {
            clear_music_priority();
            var room_music = get_current_room_music();
            if (room_music != undefined && room_music != audio_config.current_music) {
                crossfade_to_music(room_music, 2.0);
            }
        }
    }
}

// Функция получения текущего приоритета
function get_current_music_priority() {
    return audio_config.music_priority;
}

// Функция принудительной смены музыки (наивысший приоритет)
function force_music_change(sound_index, duration_seconds) {
    if (duration_seconds == undefined) duration_seconds = -1;
    return play_music_with_priority(sound_index, 3, duration_seconds);
}

// ============================================
// УЛУЧШЕННАЯ СИСТЕМА КРОССФЕЙДА
// ============================================

// Улучшенная функция кроссфейда с callback
function crossfade_to_music_advanced(new_music, fade_duration_seconds, on_complete_callback) {
    if (new_music == undefined || new_music == -1 || !sound_exists(new_music)) {
        return;
    }
    
    // Если это та же музыка, ничего не делаем
    if (new_music == audio_config.current_music) {
        if (on_complete_callback != undefined) {
            on_complete_callback();
        }
        return;
    }
    
    var old_music = audio_config.current_music;
    
    // Если нет старой музыки, просто запускаем новую
    if (old_music == undefined || !audio_config.music_playing) {
        play_music(new_music);
        if (on_complete_callback != undefined) {
            on_complete_callback();
        }
        return;
    }
    
    // Запускаем новую музыку с нулевой громкостью
    audio_sound_set_gain(new_music, 0, 0);
    audio_play_sound(new_music, audio_config.sfx_channel, true);
    
    // Плавно изменяем громкость
    var target_volume = audio_config.music_volume * audio_config.master_volume;
    var fade_time_ms = fade_duration_seconds * 1000;
    
    audio_sound_set_gain(old_music, 0, fade_time_ms);
    audio_sound_set_gain(new_music, target_volume, fade_time_ms);
    
    // Обновляем текущую музыку
    audio_config.current_music = new_music;
    audio_config.music_playing = true;
    
    // Создаем объект для отложенной остановки старой музыки
    // В реальной реализации нужен alarm или таймер
    // Здесь просто останавливаем через заданное время
}

// ============================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ============================================

// Функция получения информации о текущей музыке
function get_current_music_info() {
    return {
        sound_index: audio_config.current_music,
        is_playing: audio_config.music_playing,
        priority: audio_config.music_priority,
        priority_timer: audio_config.priority_timer,
        volume: audio_config.music_volume,
        context: audio_config.current_context
    };
}

// Функция для отладки аудио-системы
function debug_audio_system() {
    var info = get_current_music_info();
    show_debug_message("=== Audio System Debug ===");
    show_debug_message("Current Music: " + string(info.sound_index));
    show_debug_message("Is Playing: " + string(info.is_playing));
    show_debug_message("Priority: " + string(info.priority));
    show_debug_message("Priority Timer: " + string(info.priority_timer));
    show_debug_message("Music Volume: " + string(info.volume));
    show_debug_message("Context: " + info.context);
    show_debug_message("========================");
}
