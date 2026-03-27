/*
 * Основной игровой контроллер
 * Отвечает за управление состояниями игры
 */

// Инициализация игровых состояний
var game_states = {
    MENU: "menu",
    TOWN: "town", 
    PLAYING_LEVEL_1: "playing_level_1",
    PLAYING_LEVEL_2: "playing_level_2",
    PLAYING_LEVEL_3: "playing_level_3",
    PLAYING_LEVEL_4: "playing_level_4",
    PLAYING_LEVEL_5: "playing_level_5",
    PLAYING_LEVEL_6: "playing_level_6",
    VICTORY: "victory"
};

// Инициализация структуры прогресса
var initial_progress = {
    levels: [
        {completed: false, lever_pulled: false},  // Level 1
        {completed: false, lever_pulled: false},  // Level 2
        {completed: false, lever_pulled: false},  // Level 3
        {completed: false, lever_pulled: false},  // Level 4
        {completed: false, lever_pulled: false},  // Level 5
        {completed: false, lever_pulled: false}   // Level 6
    ],
    gold: 100,
    items: [],
    mechanic_training_completed: false,
    archivist_quiz_completed: false,
    elder_trial_completed: false
};

// Функция установки состояния игры
function set_game_state(new_state) {
    if (game_states[new_state] != undefined) {
        global.game_state = new_state;
        // Здесь можно добавить дополнительную логику при смене состояния
        handle_state_change(new_state);
    } else {
        show_debug_message("ERROR: Invalid game state - " + new_state);
    }
}

// Функция обработки смены состояния
function handle_state_change(new_state) {
    switch (new_state) {
        case game_states.MENU:
            scr_audio_manager.play_music(snd_menu_bg);
            break;
        case game_states.TOWN:
            scr_audio_manager.play_music(snd_town_bg);
            break;
        case game_states.PLAYING_LEVEL_1:
        case game_states.PLAYING_LEVEL_2:
        case game_states.PLAYING_LEVEL_3:
        case game_states.PLAYING_LEVEL_4:
        case game_states.PLAYING_LEVEL_5:
        case game_states.PLAYING_LEVEL_6:
            scr_audio_manager.play_music(snd_level_bg);
            break;
        case game_states.VICTORY:
            scr_audio_manager.play_music(snd_victory_bg);
            break;
    }
}

// Функция завершения уровня
function complete_level(level_num) {
    if (level_num >= 1 && level_num <= 6) {
        global.game_progress.levels[level_num - 1].completed = true;
        
        // Отправляем сигнал о завершении уровня для аудио и UI
        scr_audio_manager.play_sound(snd_level_complete);
        
        // Вызываем событие для UI обновления
        scr_ui_manager.show_notification("Уровень " + string(level_num) + " завершен!");
    }
}

// Функция активации рычага
function set_lever_pulled(level_num, pulled) {
    if (level_num >= 1 && level_num <= 6) {
        // Рычаг можно активировать только если уровень завершен
        if (global.game_progress.levels[level_num - 1].completed || !pulled) {
            global.game_progress.levels[level_num - 1].lever_pulled = pulled;
            
            if (pulled) {
                scr_audio_manager.play_sound(snd_lever_pull);
                
                // Проверяем, не завершена ли экспедиция
                if (level_num == 6 && pulled) {
                    global.expedition_complete = true;
                }
            }
        }
    }
}

// Функция проверки разблокировки уровня
function is_level_unlocked(level_num) {
    if (level_num == 1) {
        return true;  // Первый уровень всегда разблокирован
    }
    
    if (level_num > 1 && level_num <= 6) {
        return global.game_progress.levels[level_num - 2].lever_pulled;
    }
    
    return false;
}

// Функция получения прогресса уровня
function get_level_progress(level_num) {
    if (level_num >= 1 && level_num <= 6) {
        return global.game_progress.levels[level_num - 1];
    }
    return undefined;
}

// Функция применения обновления прогресса
function apply_progress_update(update_type, params) {
    switch (update_type) {
        case "mechanic_completed":
            if (!global.game_progress.mechanic_training_completed) {
                global.game_progress.mechanic_training_completed = true;
                global.game_progress.gold += 35;
                
                // Проверяем, есть ли уже такой предмет
                var item_exists = false;
                for (var i = 0; i < ds_list_size(global.game_progress.items); i++) {
                    if (ds_list_find_value(global.game_progress.items, i) == "Ключ механика") {
                        item_exists = true;
                        break;
                    }
                }
                
                if (!item_exists) {
                    ds_list_add(global.game_progress.items, "Ключ механика");
                }
                
                scr_audio_manager.play_sound(snd_reward_obtained);
                scr_ui_manager.show_notification("Получен Ключ механика и 35 золота!");
            }
            break;
        case "archivist_completed":
            if (!global.game_progress.archivist_quiz_completed) {
                global.game_progress.archivist_quiz_completed = true;
                global.game_progress.gold += 25;
                
                var item_exists = false;
                for (var i = 0; i < ds_list_size(global.game_progress.items); i++) {
                    if (ds_list_find_value(global.game_progress.items, i) == "Печать архивариуса") {
                        item_exists = true;
                        break;
                    }
                }
                
                if (!item_exists) {
                    ds_list_add(global.game_progress.items, "Печать архивариуса");
                }
                
                scr_audio_manager.play_sound(snd_reward_obtained);
                scr_ui_manager.show_notification("Получена Печать архивариуса и 25 золота!");
            }
            break;
        case "elder_completed":
            if (!global.game_progress.elder_trial_completed) {
                global.game_progress.elder_trial_completed = true;
                global.game_progress.gold += 30;
                
                var item_exists = false;
                for (var i = 0; i < ds_list_size(global.game_progress.items); i++) {
                    if (ds_list_find_value(global.game_progress.items, i) == "Талисман старосты") {
                        item_exists = true;
                        break;
                    }
                }
                
                if (!item_exists) {
                    ds_list_add(global.game_progress.items, "Талисман старосты");
                }
                
                scr_audio_manager.play_sound(snd_reward_obtained);
                scr_ui_manager.show_notification("Получен Талисман старосты и 30 золота!");
            }
            break;
    }
}

// Функция инициализации глобальных переменных
function init_global_vars() {
    if (!global.initialized) {
        global.game_state = game_states.MENU;
        global.game_progress = initial_progress;
        global.expedition_complete = false;
        global.initialized = true;
        
        // Инициализация списков
        global.game_progress.items = ds_list_create();
        
        // Загрузка сохранения, если есть
        scr_save_system.load_game();
    }
}

// Функция подсчета завершенных уровней
function count_completed_levels() {
    var count = 0;
    for (var i = 0; i < 6; i++) {
        if (global.game_progress.levels[i].completed) {
            count++;
        }
    }
    return count;
}

// Функция подсчета открытых уровней
function count_opened_levels() {
    var count = 0;
    for (var i = 0; i < 6; i++) {
        if (global.game_progress.levels[i].lever_pulled) {
            count++;
        }
    }
    return count;
}

// Функция получения текущей цели экспедиции
function get_current_objective_level() {
    for (var i = 0; i < 6; i++) {
        if (is_level_unlocked(i + 1) && !global.game_progress.levels[i].lever_pulled) {
            return i + 1;
        }
    }
    
    return 6; // Если все уровни открыты, цель - финальный уровень
}

// Функция проверки завершения экспедиции
function is_expedition_complete() {
    return global.expedition_complete || global.game_progress.levels[5].lever_pulled;  // Если финальный рычаг активирован
}