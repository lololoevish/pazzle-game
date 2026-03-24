// Game Manager Object для GameMaker
// Управляет состоянем игры, переходами между сценами

// Create Event
{
    // Инициализация глобального состояния игры
    if (!variable_instance_exists(global, "game_state")) {
        // Загрузка сохранений
        if (file_exists("savegame.json")) {
            global.game_state = scr_save_system.load_game();
        } else {
            // Если нет сохранений, начинаем новую игру
            global.game_state = scr_save_system.reset_game();
        }
    }
    
    // Инициализация аудио
    scr_audio_manager.initialize_audio();
    
    // Установка начального состояния если оно не установлено
    if (!variable_instance_exists(global, "current_state")) {
        global.current_state = global.game_state.current_state;
    }
    
    // Установка музыки для текущего состояния
    update_music_by_state();
}

// Step Event
{
    // Обновление UI
    scr_ui_manager.update_ui();
    
    // Обработка состояний игры
    switch(global.game_state.current_state) {
        case "MENU":
            // Логика меню
            handle_menu_state();
            break;
        case "TOWN":
            // Логика города
            handle_town_state();
            break;
        case "PLAYING":
            // Логика игры
            handle_playing_state();
            break;
        case "VICTORY":
            // Логика финальной сцены
            handle_victory_state();
            break;
        default:
            global.game_state.current_state = "MENU";
    }
    
    // Обработка ввода
    handle_input();
}

// Draw Event
{
    scr_ui_manager.draw_ui();
}

// Функция обновления музыки по состоянию
function update_music_by_state() {
    switch(global.game_state.current_state) {
        case "MENU":
            scr_audio_manager.play_music("menu");
            break;
        case "TOWN":
            scr_audio_manager.play_music("town");
            break;
        case "PLAYING":
            scr_audio_manager.play_music("cave");
            break;
        case "VICTORY":
            scr_audio_manager.play_music("victory");
            break;
    }
}

// Функция обработки состояния меню
function handle_menu_state() {
    // Логика обработки главного меню
}

// Функция обработки состояния города
function handle_town_state() {
    // Логика обработки города-хаба
}

// Функция обработки игрового состояния
function handle_playing_state() {
    // Логика обработки текущего уровня
}

// Функция обработки финального состояния
function handle_victory_state() {
    // Логика обработки финальной сцены
}

// Функция обработки ввода
function handle_input() {
    // Обработка переходов между состояниями
    if (keyboard_check_pressed(vk_escape)) {
        scr_audio_manager.play_sfx("cancel");
        switch(global.game_state.current_state) {
            case "PLAYING":
                // Можно добавить меню паузы
                break;
            default:
                // Для других состояний можем вернуть в меню
                break;
        }
    }
}

// Функция перехода между комнатами
function change_room(room_name) {
    switch(room_name) {
        case "rm_menu":
            room_goto(rm_menu);
            global.game_state.current_state = "MENU";
            break;
        case "rm_town":
            room_goto(rm_town);
            global.game_state.current_state = "TOWN";
            break;
        case "rm_cave_maze":
            room_goto(rm_cave_maze);
            global.game_state.current_state = "PLAYING";
            global.game_state.current_level = 1;
            break;
        case "rm_cave_archive":
            room_goto(rm_cave_archive);
            global.game_state.current_state = "PLAYING";
            global.game_state.current_level = 2;
            break;
        case "rm_cave_rhythm":
            room_goto(rm_cave_rhythm);
            global.game_state.current_state = "PLAYING";
            global.game_state.current_level = 3;
            break;
        case "rm_cave_pairs":
            room_goto(rm_cave_pairs);
            global.game_state.current_state = "PLAYING";
            global.game_state.current_level = 4;
            break;
        case "rm_cave_platformer":
            room_goto(rm_cave_platformer);
            global.game_state.current_state = "PLAYING";
            global.game_state.current_level = 5;
            break;
        case "rm_cave_final":
            room_goto(rm_cave_final);
            global.game_state.current_state = "PLAYING";
            global.game_state.current_level = 6;
            break;
        case "rm_victory":
            room_goto(rm_victory);
            global.game_state.current_state = "VICTORY";
            break;
        default:
            room_goto(rm_menu);
            global.game_state.current_state = "MENU";
    }
    
    // Обновляем музыку в соответствии с новым состоянием
    update_music_by_state();
}

// Функция обработки завершения головоломки
function on_puzzle_solved() {
    // Отмечаем уровень как завершенный
    scr_game_state.set_level_completed(global.game_state, global.game_state.current_level);
    
    // Сохраняем игру
    scr_save_system.save_game(global.game_state);
}

// Функция обработки опускания рычага
function on_lever_pulled(level_num) {
    // Отмечаем, что рычаг опущен
    scr_game_state.set_lever_pulled(global.game_state, level_num);
    
    // Сохраняем игру
    scr_save_system.save_game(global.game_state);
    
    // Проверяем, не завершена ли экспедиция
    if (scr_game_state.is_expedition_completed(global.game_state)) {
        // Если экспедиция завершена, переходим к финальной сцене
        change_room("rm_victory");
    }
}