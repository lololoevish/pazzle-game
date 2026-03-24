// Система сохранений GameMaker
// Сохраняет и загружает прогресс в формате JSON

// Функция сохранения
function save_game(game_state) {
    var json_string = json_encode(game_state);
    ini_open("savegame.ini");
    ini_write_string("game_data", "state", json_string);
    ini_close();
    // Также сохраняем в JSON файл как в Rust-версии
    file_text_write_string("savegame.json", json_string);
}

// Функция загрузки
function load_game() {
    var loaded_state;
    if (file_exists("savegame.json")) {
        var file = file_text_open_read("savegame.json");
        var json_string = file_text_read_string(file);
        file_text_close(file);
        loaded_state = json_decode(json_string);
    } else if (ini_file_exists("savegame.ini")) {
        ini_open("savegame.ini");
        var json_string = ini_read_string("game_data", "state", "{}");
        ini_close();
        loaded_state = json_decode(json_string);
    } else {
        // Если нет сохранений, создаем новое
        loaded_state = scr_game_state();
    }
    return loaded_state;
}

// Инициализация новой игры
function reset_game() {
    return scr_game_state();
}