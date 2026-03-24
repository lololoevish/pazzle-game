// Game Manager Object для GameMaker
// Управляет состоянием игры, переходами между сценами

// Create Event
{
    // Инициализация глобального состояния игры
    global.game_state = scr_game_state();
    
    // Загрузка сохранений
    if (file_exists("savegame.json")) {
        global.game_state = scr_save_system.load_game();
    } else {
        // Если нет сохранений, начинаем новую игру
        global.game_state = scr_save_system.reset_game();
    }
    
    // Инициализация аудио
    global.audio_manager = scr_audio_manager.initialize_audio();
    
    // Установка начального состояния
    global.current_state = "MENU";
    
    // Установка музыки для начального состояния
    scr_audio_manager.play_music("menu");
}

// Step Event
{
    switch(global.current_state) {
        case "MENU":
            // Логика меню
            break;
        case "TOWN":
            // Логика города
            break;
        case "PLAYING":
            // Логика игры
            break;
        case "VICTORY":
            // Логика финальной сцены
            break;
        default:
            global.current_state = "MENU";
    }
    
    // Обработка ввода
    handle_input();
}

// Draw Event
{
    scr_ui_manager.draw_ui();
}

// Функция обработки ввода
function handle_input() {
    // Обработка переходов между состояниями
    if (keyboard_check_pressed(vk_escape)) {
        scr_audio_manager.play_sfx("cancel");
        switch(global.current_state) {
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
            scr_audio_manager.play_music("menu");
            break;
        case "rm_town":
            room_goto(rm_town);
            scr_audio_manager.play_music("town");
            break;
        case "rm_cave_maze":
            room_goto(rm_cave_maze);
            scr_audio_manager.play_music("cave");
            break;
        case "rm_cave_archive":
            room_goto(rm_cave_archive);
            scr_audio_manager.play_music("cave");
            break;
        case "rm_cave_rhythm":
            room_goto(rm_cave_rhythm);
            scr_audio_manager.play_music("cave");
            break;
        case "rm_cave_pairs":
            room_goto(rm_cave_pairs);
            scr_audio_manager.play_music("cave");
            break;
        case "rm_cave_platformer":
            room_goto(rm_cave_platformer);
            scr_audio_manager.play_music("cave");
            break;
        case "rm_cave_final":
            room_goto(rm_cave_final);
            scr_audio_manager.play_music("cave");
            break;
        case "rm_victory":
            room_goto(rm_victory);
            scr_audio_manager.play_music("victory");
            break;
        default:
            room_goto(rm_menu);
    }
}