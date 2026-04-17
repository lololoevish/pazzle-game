/*
 * VN Text Engine
 * Система печатающегося текста для визуальной новеллы
 */

// Инициализация текстового движка
function vn_text_init() {
    global.vn_text = {
        current_text: "",
        target_text: "",
        char_index: 0,
        speed: 2,  // символов за фрейм
        finished: false,
        skip_enabled: true,
        sound_counter: 0
    };
}

// Начать печать текста
function vn_text_start(text) {
    global.vn_text.target_text = text;
    global.vn_text.current_text = "";
    global.vn_text.char_index = 0;
    global.vn_text.finished = false;
    global.vn_text.sound_counter = 0;
}

// Обновление текста
function vn_text_update() {
    if (global.vn_text.finished) return;
    
    var target_len = string_length(global.vn_text.target_text);
    
    if (global.vn_text.char_index < target_len) {
        global.vn_text.char_index += global.vn_text.speed;
        global.vn_text.char_index = min(global.vn_text.char_index, target_len);
        
        global.vn_text.current_text = string_copy(
            global.vn_text.target_text, 
            1, 
            floor(global.vn_text.char_index)
        );
        
        // Звук печати (каждые 3 символа)
        global.vn_text.sound_counter++;
        if (global.vn_text.sound_counter >= 3) {
            global.vn_text.sound_counter = 0;
            if (script_exists(play_event_sound)) {
                play_event_sound("ui_move");
            }
        }
    } else {
        global.vn_text.finished = true;
    }
}

// Пропустить печать
function vn_text_skip() {
    if (global.vn_text.skip_enabled) {
        global.vn_text.current_text = global.vn_text.target_text;
        global.vn_text.char_index = string_length(global.vn_text.target_text);
        global.vn_text.finished = true;
    }
}

// Проверка завершения
function vn_text_is_finished() {
    return global.vn_text.finished;
}

// Получить текущий текст
function vn_text_get_current() {
    return global.vn_text.current_text;
}

// Установить скорость печати
function vn_text_set_speed(speed) {
    global.vn_text.speed = clamp(speed, 1, 10);
}

// Очистка текстового движка
function vn_text_cleanup() {
    global.vn_text = {
        current_text: "",
        target_text: "",
        char_index: 0,
        speed: 2,
        finished: false,
        skip_enabled: true,
        sound_counter: 0
    };
}
