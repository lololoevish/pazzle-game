// Менеджер головоломок для GameMaker

// Функция инициализации менеджера
function init_puzzle_manager() {
    // Словарь для хранения экземпляров головоломок
    puzzles = ds_map_create();
    
    // Регистрируем доступные типы головоломок
    register_puzzle_type("maze", "scr_maze_puzzle");
    register_puzzle_type("word_search", "scr_word_search_puzzle");
    register_puzzle_type("rhythm", "scr_rhythm_puzzle");
    register_puzzle_type("pairs", "scr_memory_match_puzzle");
    register_puzzle_type("platformer", "scr_platformer_puzzle");
    register_puzzle_type("final", "scr_final_challenge_puzzle");
}

// Функция регистрации типа головоломки
function register_puzzle_type(type, script_name) {
    ds_map_add(puzzles, type, script_name);
}

// Функция создания головоломки
function create_puzzle(type) {
    if (ds_map_exists(puzzles, type)) {
        var script_name = ds_map_find_value(puzzles, type);
        
        // Создаем экземпляр головоломки
        var puzzle_instance = script_execute(script_name, "init");
        
        return puzzle_instance;
    } else {
        show_debug_message("Unknown puzzle type: " + type);
        return undefined;
    }
}

// Функция обновления головоломки
function update_puzzle(type) {
    if (ds_map_exists(puzzles, type)) {
        var script_name = ds_map_find_value(puzzles, type);
        script_execute(script_name, "update");
    }
}

// Функция отрисовки головоломки
function draw_puzzle(type, gui_view = false) {
    if (ds_map_exists(puzzles, type)) {
        var script_name = ds_map_find_value(puzzles, type);
        script_execute(script_name, "draw", gui_view);
    }
}

// Функция проверки завершения головоломки
function is_puzzle_solved(type) {
    if (ds_map_exists(puzzles, type)) {
        var script_name = ds_map_find_value(puzzles, type);
        return script_execute(script_name, "is_solved");
    }
    return false;
}

// Функция сброса головоломки
function reset_puzzle(type) {
    if (ds_map_exists(puzzles, type)) {
        var script_name = ds_map_find_value(puzzles, type);
        return script_execute(script_name, "reset");
    }
}

// Функция уничтожения менеджера
function destroy_puzzle_manager() {
    if (ds_map_exists(puzzles, "clear")) {
        ds_map_clear(puzzles);
    }
    ds_map_destroy(puzzles);
}