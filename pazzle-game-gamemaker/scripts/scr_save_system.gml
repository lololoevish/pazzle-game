// Система сохранений GameMaker
// Сохраняет и загружает прогресс в формате JSON

// Функция сохранения
function save_game(game_state) {
    // Преобразуем ds_map и ds_list в формат, подходящий для JSON
    var json_safe_state = convert_state_for_json(game_state);
    var json_string = json_encode(json_safe_state);
    
    // Сохраняем в JSON файл как в Rust-версии
    var file = file_text_open_write("savegame.json");
    if (file != -1) {
        file_text_write_string(file, json_string);
        file_text_close(file);
    }
    
    // Также сохраняем в INI для резервного копирования
    ini_open("savegame.ini");
    ini_write_string("game_data", "state", json_string);
    ini_close();
    
    show_debug_message("Игра сохранена");
}

// Функция загрузки
function load_game() {
    var loaded_state;
    
    if (file_exists("savegame.json")) {
        var file = file_text_open_read("savegame.json");
        if (file != -1) {
            var json_string = file_text_read_string(file);
            file_text_close(file);
            
            // Проверяем, что строка не пустая
            if (string_length(json_string) > 0) {
                var json_data = json_decode(json_string);
                
                // Преобразуем данные обратно в формат с ds_map и ds_list
                loaded_state = convert_json_to_state(json_data);
            }
        }
    }
    
    // Если загрузка из JSON не удалась, пробуем из INI
    if (loaded_state == undefined) {
        if (ini_file_exists("savegame.ini")) {
            ini_open("savegame.ini");
            var json_string = ini_read_string("game_data", "state", "{}");
            ini_close();
            
            if (string_length(json_string) > 0) {
                var json_data = json_decode(json_string);
                loaded_state = convert_json_to_state(json_data);
            }
        }
    }
    
    // Если ничего не удалось загрузить, создаем новую игру
    if (loaded_state == undefined) {
        loaded_state = scr_game_state.create_new_game_state();
    }
    
    return loaded_state;
}

// Инициализация новой игры
function reset_game() {
    var new_state = scr_game_state.create_new_game_state();
    
    // Сохраняем новую игру в файл
    save_game(new_state);
    
    return new_state;
}

// Вспомогательная функция преобразования состояния для JSON
function convert_state_for_json(game_state) {
    var json_state = {};
    json_state.current_state = game_state.current_state;
    json_state.current_level = game_state.current_level;
    json_state.gold = game_state.gold;
    json_state.elder_trial_completed = game_state.elder_trial_completed;
    json_state.mechanic_training_completed = game_state.mechanic_training_completed;
    json_state.archivist_quiz_completed = game_state.archivist_quiz_completed;
    
    // Преобразуем ds_map прогресса в JSON-совместимый формат
    json_state.progress = {};
    if (ds_map_exists(game_state.progress, "size")) {
        var keys = ds_map_keys(game_state.progress);
        var i;
        for (i = 0; i < ds_map_size(game_state.progress); i++) {
            var key = ds_map_get_key(game_state.progress, i);
            var value = ds_map_get_value(game_state.progress, key);
            json_state.progress[key] = value;
        }
    }
    
    // Преобразуем ds_list предметов
    json_state.items = [];
    if (ds_list_empty(game_state.items) == false) {
        for (var i = 0; i < ds_list_size(game_state.items); i++) {
            array_push(json_state.items, ds_list_find_value(game_state.items, i));
        }
    }
    
    return json_state;
}

// Вспомогательная функция преобразования JSON в состояние
function convert_json_to_state(json_data) {
    var game_state = scr_game_state.create_new_game_state();
    
    if (json_data.current_state != undefined) game_state.current_state = json_data.current_state;
    if (json_data.current_level != undefined) game_state.current_level = json_data.current_level;
    if (json_data.gold != undefined) game_state.gold = json_data.gold;
    if (json_data.elder_trial_completed != undefined) game_state.elder_trial_completed = json_data.elder_trial_completed;
    if (json_data.mechanic_training_completed != undefined) game_state.mechanic_training_completed = json_data.mechanic_training_completed;
    if (json_data.archivist_quiz_completed != undefined) game_state.archivist_quiz_completed = json_data.archivist_quiz_completed;
    
    // Восстанавливаем прогресс
    if (json_data.progress != undefined) {
        var progress_map = json_data.progress;
        var key;
        for (key in progress_map) {
            ds_map_replace(game_state.progress, key, progress_map[key]);
        }
    }
    
    // Восстанавливаем предметы
    if (json_data.items != undefined) {
        for (var i = 0; i < array_length_1d(json_data.items); i++) {
            ds_list_add(game_state.items, json_data.items[i]);
        }
    }
    
    return game_state;
}

// Функция проверки существования сохранения
function has_saved_game() {
    return file_exists("savegame.json") || ini_file_exists("savegame.ini");
}

// Функция удаления сохранения
function delete_save() {
    if (file_exists("savegame.json")) {
        file_delete("savegame.json");
    }
    if (ini_file_exists("savegame.ini")) {
        file_delete("savegame.ini");
    }
}