/*
 * Game Manager Object для GameMaker
 * Управляет состоянием игры, переходами между сценами
 */

// Create Event
{
    // Инициализация глобальных переменных
    scr_init_globals();
    
    // Инициализация системы межуровневого перемещения
    if (script_exists(scr_interlevel_platformer)) {
        init_interlevel_system();
    }
    
    // Установка музыки для текущего состояния
    if (script_exists(scr_audio_manager)) {
        play_music_by_state(global.game_state);
    }
}

// Step Event
{
    // Обновление UI
    if (script_exists(scr_ui_manager)) {
        update_ui(delta_time / 1000000);
    }
    
    // Обновление системы межуровневого перемещения
    if (script_exists(scr_interlevel_platformer)) {
        update_interlevel_system();
    }
    
    // Обработка состояний игры
    switch(global.game_state) {
        case "menu":
            // Логика меню
            handle_menu_state();
            break;
        case "town":
            // Логика города
            handle_town_state();
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
            // Логика игры
            handle_playing_state();
            break;
        case "victory":
            // Логика финальной сцены
            handle_victory_state();
            break;
        default:
            global.game_state = "menu";
    }
    
    // Обработка ввода
    handle_input();
}

// Draw Event
{
    if (script_exists(scr_ui_manager)) {
        draw_ui();
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
        if (script_exists(scr_audio_manager)) {
            play_event_sound("ui_cancel");
        }
        switch(global.game_state) {
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
                // Можно добавить меню паузы
                break;
            default:
                // Для других состояний можем вернуть в меню
                break;
        }
    }
}

// Функция обработки завершения головоломки
function on_puzzle_solved(level_num) {
    // Если объект игрока существует, вызываем его метод для завершения уровня с переходом
    with (obj_player) {
        if (function_exists(complete_level_with_transition)) {
            complete_level_with_transition(level_num);
        } else {
            // Старая логика
            if (script_exists(complete_level)) {
                complete_level(level_num);
            }
            
            // Возвращаем в город
            var town_room_index = room_get_name_index("rm_town");
            if (town_room_index != -1) {
                room_goto(town_room_index);
                
                // Перемещаем игрока в центр города
                x = 400;
                y = 400;
            }
        }
    }
    
    // Сохраняем игру
    if (script_exists(scr_save_system)) {
        save_game();
    }
}

// Функция обработки опускания рычага
function on_lever_pulled(level_num) {
    // Отмечаем, что рычаг опущен
    set_level_lever_pulled(level_num, true);
    
    // Сохраняем игру
    if (script_exists(scr_save_system)) {
        save_game();
    }
    
    // Проверяем, не завершена ли экспедиция
    if (global.expedition_complete) {
        // Если экспедиция завершена, можно выполнить дополнительные действия
        global.game_state = "victory";
    }
    
    // Проверяем, есть ли переход к следующему уровню
    if (script_exists(scr_level_transition_platformer)) {
        var current_room = room_get_name(room);
        var transition_data = check_level_completion_for_transition(current_room);
        
        if (transition_data != null) {
            // Инициируем переход к следующему уровню
            initiate_level_transition(transition_data);
        }
    }
}
