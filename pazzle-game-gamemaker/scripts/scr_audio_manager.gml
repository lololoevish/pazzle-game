// Аудио менеджер для GameMaker
// Управляет музыкой и звуковыми эффектами

// Глобальные переменные для аудио
globalvar audio_manager_initialized;
if (!variable_instance_exists(global, "audio_manager_initialized")) {
    global.audio_manager_initialized = false;
}

// Инициализация аудио менеджера
function initialize_audio() {
    if (!global.audio_manager_initialized) {
        // Инициализация аудио ресурсов
        // В реальном проекте это будут ссылки на реальные аудио файлы
        // Для заглушки используем индекс -1 (не найдено) и будем обрабатывать это в play_функциях
        
        // Создаем структуру для аудио
        if (!variable_instance_exists(global, "audio_resources")) {
            global.audio_resources = {
                sfx: {
                    confirm: -1,      // В реальном проекте будет asset_get_index("snd_ui_confirm")
                    cancel: -1,       // asset_get_index("snd_ui_cancel")
                    move: -1,         // asset_get_index("snd_ui_move")
                    success: -1,      // asset_get_index("snd_ui_success")
                    lever: -1,        // asset_get_index("snd_lever")
                    interaction: -1,  // asset_get_index("snd_interaction")
                    puzzle_success: -1,    // asset_get_index("snd_puzzle_success")
                    puzzle_completed: -1   // asset_get_index("snd_puzzle_completed")
                },
                music: {
                    menu: -1,      // asset_get_index("mus_menu")
                    town: -1,      // asset_get_index("mus_town")
                    cave: -1,      // asset_get_index("mus_cave")
                    victory: -1    // asset_get_index("mus_victory")
                }
            };
        }
        
        // Настройки аудио
        if (!variable_instance_exists(global, "sfx_volume")) global.sfx_volume = 1.0;
        if (!variable_instance_exists(global, "music_volume")) global.music_volume = 1.0;
        if (!variable_instance_exists(global, "audio_muted")) global.audio_muted = false;
        if (!variable_instance_exists(global, "bgm_channel")) global.bgm_channel = -1;
        
        global.audio_manager_initialized = true;
    }
}

// Проигрывание SFX
function play_sfx(sound_name) {
    if (global.audio_muted) return; // Если звук отключен, ничего не проигрываем
    
    // Временная функция для воспроизведения звуков
    // В реальном проекте будет использовать asset_get_index и audio_play_sound
    
    var sound_asset = -1;
    
    // Сопоставляем названия звуков с ресурсами
    if (global.audio_resources != undefined) {
        if (global.audio_resources.sfx[sound_name] != undefined) {
            sound_asset = global.audio_resources.sfx[sound_name];
        }
    }
    
    // Если звук не определен, используем обобщенную логику
    if (sound_asset == -1) {
        // Вместо реального воспроизведения выводим debug для тестирования
        show_debug_message("SFX played: " + string(sound_name));
        return;
    }
    
    // В реальном проекте было бы:
    // if (asset_get_type(sound_asset) == asset_sound) {
    //     audio_play_sound(sound_asset, global.sfx_volume, false);
    // }
}

// Проигрывание музыки
function play_music(music_name, looping = true) {
    if (global.audio_muted) return; // Если звук отключен, ничего не проигрываем
    
    // Остановить текущую музыку
    if (global.bgm_channel != -1) {
        audio_stop_sound(global.bgm_channel);
        global.bgm_channel = -1;
    }
    
    var music_asset = -1;
    
    // Сопоставляем названия музыки с ресурсами
    if (global.audio_resources != undefined) {
        if (global.audio_resources.music[music_name] != undefined) {
            music_asset = global.audio_resources.music[music_name];
        }
    }
    
    // Если музыка не определена, используем обобщенную логику
    if (music_asset == -1) {
        // Вместо реального воспроизведения выводим debug для тестирования
        show_debug_message("Music played: " + string(music_name) + ", looping: " + string(looping));
        return;
    }
    
    // В реальном проекте было бы:
    // if (asset_get_type(music_asset) == asset_sound) {
    //     global.bgm_channel = audio_play_sound(music_asset, global.music_volume, looping);
    // }
}

// Остановка музыки
function stop_music() {
    if (global.bgm_channel != -1) {
        audio_stop_sound(global.bgm_channel);
        global.bgm_channel = -1;
    }
}

// Установка громкости
function set_volume(sfx_vol = -1, music_vol = -1) {
    if (sfx_vol != -1) global.sfx_volume = clamp(sfx_vol, 0, 1);
    if (music_vol != -1) global.music_volume = clamp(music_vol, 0, 1);
}

// Отключение/включение звука
function toggle_mute() {
    global.audio_muted = !global.audio_muted;
}

// Вспомогательная функция для ограничения значений
function clamp(val, min, max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
}