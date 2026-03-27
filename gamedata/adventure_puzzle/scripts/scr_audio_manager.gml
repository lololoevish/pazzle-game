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
    sfx_channel: 0
};

// Функция проигрывания музыки
function play_music(sound_index) {
    if (sound_exists(sound_index)) {
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
        show_debug_message("WARNING: Music sound '" + string(sound_index) + "' does not exist");
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

// Функция проигрывания звукового эффекта
function play_sound(sound_index) {
    if (sound_exists(sound_index)) {
        // Устанавливаем громкость SFX
        audio_sound_set_gain(sound_index, audio_config.sfx_volume * audio_config.master_volume, 0);
        
        // Проигрываем звук
        audio_play_sound(sound_index, audio_config.sfx_channel, false);
    } else {
        show_debug_message("WARNING: Sound effect '" + string(sound_index) + "' does not exist");
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
    switch (game_state) {
        case "menu":
            play_music(snd_menu_bg);
            break;
        case "town":
            play_music(snd_town_bg);
            break;
        case "playing_level_1":
        case "playing_level_2":
        case "playing_level_3":
        case "playing_level_4":
        case "playing_level_5":
        case "playing_level_6":
            play_music(snd_level_bg);
            break;
        case "victory":
            play_music(snd_victory_bg);
            break;
        default:
            show_debug_message("WARNING: No music defined for state '" + game_state + "'");
            break;
    }
}

// Функция для удобного воспроизведения звуков событий
function play_event_sound(event_type) {
    switch (event_type) {
        case "ui_move":
            play_sound(snd_ui_move);
            break;
        case "ui_confirm":
            play_sound(snd_ui_confirm);
            break;
        case "ui_cancel":
            play_sound(snd_ui_cancel);
            break;
        case "ui_success":
            play_sound(snd_ui_success);
            break;
        case "lever_pull":
            play_sound(snd_lever_pull);
            break;
        case "level_complete":
            play_sound(snd_level_complete);
            break;
        case "reward_obtained":
            play_sound(snd_reward_obtained);
            break;
        case "puzzle_solve":
            play_sound(snd_puzzle_solve);
            break;
        case "player_move":
            play_sound(snd_player_move);
            break;
        case "player_jump":
            play_sound(snd_player_jump);
            break;
        case "item_collect":
            play_sound(snd_item_collect);
            break;
        default:
            show_debug_message("WARNING: No sound defined for event '" + event_type + "'");
            break;
    }
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