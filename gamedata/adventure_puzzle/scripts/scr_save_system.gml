/*
 * Система сохранений
 * Отвечает за сохранение и загрузку игрового прогресса
 */

// Имя файла сохранения
var SAVE_FILE_NAME = "adventure_puzzle_save";

// Функция сохранения игры
function save_game() {
    var save_struct = {
        game_state: global.game_state,
        game_progress: {},
        expedition_complete: global.expedition_complete
    };
    
    // Копируем структуру прогресса
    save_struct.game_progress.levels = [];
    for (var i = 0; i < array_length(global.game_progress.levels); i++) {
        var level_data = {};
        level_data.completed = global.game_progress.levels[i].completed;
        level_data.lever_pulled = global.game_progress.levels[i].lever_pulled;
        array_push(save_struct.game_progress.levels, level_data);
    }
    
    save_struct.game_progress.gold = global.game_progress.gold;
    save_struct.game_progress.mechanic_training_completed = global.game_progress.mechanic_training_completed;
    save_struct.game_progress.archivist_quiz_completed = global.game_progress.archivist_quiz_completed;
    save_struct.game_progress.elder_trial_completed = global.game_progress.elder_trial_completed;
    
    // Сохраняем список предметов
    save_struct.game_progress.items = [];
    var items_count = ds_list_size(global.game_progress.items);
    for (var i = 0; i < items_count; i++) {
        array_push(save_struct.game_progress.items, ds_list_find_value(global.game_progress.items, i));
    }
    
    // Сохраняем структуру в файл
    var file = ini_open(SAVE_FILE_NAME + ".ini");
    ini_write_string("save", "data", json_stringify(save_struct));
    ini_close();
    
    // Также можно сохранить через обычный файл
    var file = file_text_open_write(SAVE_FILE_NAME + ".sav");
    if (file != -1) {
        file_text_write_string(file, json_stringify(save_struct));
        file_text_close(file);
    }
}

// Функция загрузки игры
function load_game() {
    var loaded_data = undefined;
    
    // Пробуем загрузить из файла
    var file = file_text_open_read(SAVE_FILE_NAME + ".sav");
    if (file != -1) {
        var content = file_text_read_all(file);
        file_text_close(file);
        
        if (content != "") {
            loaded_data = json_parse(content);
        }
    }
    
    // Если не удалось загрузить из .sav, пробуем из .ini
    if (loaded_data == undefined) {
        var file = ini_open(SAVE_FILE_NAME + ".ini");
        if (ini_section_exists(file, "save")) {
            var content = ini_read_string("save", "data", "");
            if (content != "") {
                loaded_data = json_parse(content);
            }
        }
        ini_close();
    }
    
    if (loaded_data != undefined) {
        // Восстанавливаем состояние игры
        global.game_state = loaded_data.game_state;
        global.expedition_complete = loaded_data.expedition_complete;
        
        // Восстанавливаем прогресс уровней
        var levels_data = loaded_data.game_progress.levels;
        for (var i = 0; i < array_length(levels_data); i++) {
            global.game_progress.levels[i].completed = levels_data[i].completed;
            global.game_progress.levels[i].lever_pulled = levels_data[i].lever_pulled;
        }
        
        global.game_progress.gold = loaded_data.game_progress.gold;
        global.game_progress.mechanic_training_completed = loaded_data.game_progress.mechanic_training_completed;
        global.game_progress.archivist_quiz_completed = loaded_data.game_progress.archivist_quiz_completed;
        global.game_progress.elder_trial_completed = loaded_data.game_progress.elder_trial_completed;
        
        // Восстанавливаем список предметов
        ds_list_clear(global.game_progress.items);
        var items_data = loaded_data.game_progress.items;
        for (var i = 0; i < array_length(items_data); i++) {
            ds_list_add(global.game_progress.items, items_data[i]);
        }
        
        return true;
    } else {
        // Если не удалось загрузить, инициализируем начальные значения
        initialize_default_progress();
        return false;
    }
}

// Функция инициализации начального прогресса
function initialize_default_progress() {
    for (var i = 0; i < 6; i++) {
        global.game_progress.levels[i].completed = false;
        global.game_progress.levels[i].lever_pulled = false;
    }
    
    global.game_progress.gold = 100;
    global.game_progress.mechanic_training_completed = false;
    global.game_progress.archivist_quiz_completed = false;
    global.game_progress.elder_trial_completed = false;
    
    // Очищаем список предметов
    ds_list_clear(global.game_progress.items);
}

// Функция сброса игры
function reset_game() {
    // Удаляем файл сохранения
    file_delete(SAVE_FILE_NAME + ".sav");
    file_delete(SAVE_FILE_NAME + ".ini");
    
    // Инициализируем начальные значения
    initialize_default_progress();
    global.game_state = "menu";
    global.expedition_complete = false;
    
    // Восстанавливаем начальные параметры
    obj_game_manager.init_global_vars();
}

// Функция проверки наличия сохранения
function has_save() {
    return file_exists(SAVE_FILE_NAME + ".sav") || file_exists(SAVE_FILE_NAME + ".ini");
}

// Функция получения информации о сохранении
function get_save_info() {
    var info = {
        exists: false,
        game_state: "",
        gold: 0,
        levels_completed: 0,
        levels_opened: 0,
        items_count: 0,
        expedition_progress: 0
    };
    
    var file = file_text_open_read(SAVE_FILE_NAME + ".sav");
    if (file != -1) {
        var content = file_text_read_all(file);
        file_text_close(file);
        
        if (content != "") {
            var loaded_data = json_parse(content);
            info.exists = true;
            info.game_state = loaded_data.game_state;
            info.gold = loaded_data.game_progress.gold;
            
            // Подсчитываем количество завершенных уровней
            for (var i = 0; i < array_length(loaded_data.game_progress.levels); i++) {
                if (loaded_data.game_progress.levels[i].completed) {
                    info.levels_completed++;
                }
                if (loaded_data.game_progress.levels[i].lever_pulled) {
                    info.levels_opened++;
                }
            }
            
            info.items_count = array_length(loaded_data.game_progress.items);
            info.expedition_progress = info.levels_opened;
        }
    }
    
    return info;
}

// Функция конвертации Rust-сохранения (если потребуется в будущем)
function convert_rust_save(rust_data) {
    // Эта функция будет реализована позже для миграции данных из Rust-версии
    // Пока что просто возвращаем структуру, соответствующую нашей системе
    var converted = {
        game_state: "town",  // После загрузки скорее всего будем в городе
        game_progress: {
            levels: [],
            gold: rust_data.gold,
            items: array_copy(rust_data.items),
            mechanic_training_completed: rust_data.mechanic_training_completed,
            archivist_quiz_completed: rust_data.archivist_quiz_completed,
            elder_trial_completed: rust_data.elder_trial_completed
        },
        expedition_complete: rust_data.is_expedition_complete
    };
    
    // Преобразуем уровни
    for (var i = 0; i < 6; i++) {
        var level_info = {
            completed: false,
            lever_pulled: false
        };
        
        if (i < array_length(rust_data.levels)) {
            level_info.completed = rust_data.levels[i].completed;
            level_info.lever_pulled = rust_data.levels[i].lever_pulled;
        }
        
        array_push(converted.game_progress.levels, level_info);
    }
    
    return converted;
}