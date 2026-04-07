/*
 * Инициализация глобальных переменных
 * Вызывается один раз при запуске игры для настройки всех глобальных переменных
 */

// Проверяем, была ли уже выполнена инициализация
if (!global_exists("initialized")) {
    // Инициализация аудио-ресурсов
    global.snd_menu_bg = -1;
    global.snd_town_bg = -1;
    global.snd_level_bg = -1;
    global.snd_victory_bg = -1;
    global.snd_ui_move = -1;
    global.snd_ui_confirm = -1;
    global.snd_ui_cancel = -1;
    global.snd_ui_success = -1;
    global.snd_lever_pull = -1;
    global.snd_level_complete = -1;
    global.snd_reward_obtained = -1;
    global.snd_puzzle_solve = -1;
    global.snd_player_move = -1;
    global.snd_player_jump = -1;
    global.snd_item_collect = -1;

    // Инициализация спрайтов
    global.spr_player_idle = -1;
    global.spr_player_walk = -1;

    // Инициализация шрифтов
    global.fnt_default = font_get_default();

    // Инициализация основных игровых состояний
    global.game_state = "menu";

    // Инициализация прогресса игры
    global.game_progress = {
        levels: [
            {completed: false, lever_pulled: false},
            {completed: false, lever_pulled: false},
            {completed: false, lever_pulled: false},
            {completed: false, lever_pulled: false},
            {completed: false, lever_pulled: false},
            {completed: false, lever_pulled: false}
        ],
        gold: 100,
        items: [], // Используем массив вместо ds_list для простоты
        mechanic_training_completed: false,
        archivist_quiz_completed: false,
        elder_trial_completed: false
    };

    // Статус экспедиции
    global.expedition_complete = false;
    
    // Флаг инициализации
    global.initialized = true;
}

// Загрузка сохранения, если есть
if (script_exists(scr_save_system)) {
    load_game();
}
