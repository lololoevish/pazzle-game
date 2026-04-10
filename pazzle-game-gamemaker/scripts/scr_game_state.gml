// Управление состоянием игры
// Соответствует GameState из Rust-версии

function create_new_game_state() {
    var state_data = {
        current_state: "MENU",
        current_level: 1,
        progress: ds_map_create(),
        gold: 0,
        items: ds_list_create(),
        elder_trial_completed: false,
        mechanic_training_completed: false,
        archivist_quiz_completed: false
    };

    // Инициализация сохранения прогресса
    for (var i = 1; i <= 12; i += 1) {  // Расширяем до 12 уровней
        ds_map_add(state_data.progress, "level_" + string(i) + "_completed", false);
        ds_map_add(state_data.progress, "level_" + string(i) + "_lever_pulled", false);
    }

    return state_data;
}

// Функция проверки завершения уровня
function is_level_completed(state, level_num) {
    var key = "level_" + string(level_num) + "_completed";
    if (ds_map_exists(state.progress, key)) {
        return ds_map_find_value(state.progress, key);
    }
    return false;
}

// Функция установки завершения уровня
function set_level_completed(state, level_num) {
    var key = "level_" + string(level_num) + "_completed";
    ds_map_replace(state.progress, key, true);
}

// Функция проверки, опущен ли рычаг
function is_lever_pulled(state, level_num) {
    var key = "level_" + string(level_num) + "_lever_pulled";
    if (ds_map_exists(state.progress, key)) {
        return ds_map_find_value(state.progress, key);
    }
    return false;
}

// Функция установки опускания рычага
function set_lever_pulled(state, level_num) {
    var key = "level_" + string(level_num) + "_lever_pulled";
    ds_map_replace(state.progress, key, true);
}

// Совместимость с новой глобальной моделью прогресса
function complete_level(level_num) {
    if (level_num >= 1 && level_num <= 12) {  // Расширяем до 12 уровней
        if (array_length(global.game_progress.levels) > level_num - 1) {
            global.game_progress.levels[level_num - 1].completed = true;
        } else {
            // Если массив еще мал, расширяем его
            while (array_length(global.game_progress.levels) <= level_num - 1) {
                var new_level_data = {completed: false, lever_pulled: false};
                array_push(global.game_progress.levels, new_level_data);
            }
            global.game_progress.levels[level_num - 1].completed = true;
        }
        if (script_exists(play_event_sound)) {
            play_event_sound("level_complete");
        }
    }
}

function set_level_lever_pulled(level_num, pulled) {
    if (level_num >= 1 && level_num <= 12) {  // Расширяем до 12 уровней
        if (array_length(global.game_progress.levels) > level_num - 1) {
            global.game_progress.levels[level_num - 1].lever_pulled = pulled;
        } else {
            // Если массив еще мал, расширяем его
            while (array_length(global.game_progress.levels) <= level_num - 1) {
                var new_level_data = {completed: false, lever_pulled: false};
                array_push(global.game_progress.levels, new_level_data);
            }
            global.game_progress.levels[level_num - 1].lever_pulled = pulled;
        }
        if (level_num == 12 && pulled) {  // Обновляем номер финального уровня
            global.expedition_complete = true;
        }
        if (pulled && script_exists(play_event_sound)) {
            play_event_sound("lever_pull");
        }
    }
}

function count_completed_levels() {
    var count = 0;
    var total_levels = array_length(global.game_progress.levels);
    for (var i = 0; i < min(total_levels, 12); i++) {  // Проверяем до 12 уровней
        if (global.game_progress.levels[i].completed) {
            count++;
        }
    }
    return count;
}

function count_opened_levels() {
    var count = 0;
    var total_levels = array_length(global.game_progress.levels);
    for (var i = 0; i < min(total_levels, 12); i++) {  // Проверяем до 12 уровней
        if (global.game_progress.levels[i].lever_pulled || i == 0) {
            count++;
        }
    }
    return count;
}

function get_current_objective_level() {
    var total_levels = array_length(global.game_progress.levels);
    for (var i = 0; i < min(total_levels, 12); i++) {
        if (!global.game_progress.levels[i].lever_pulled) {
            return i + 1;
        }
    }
    return min(12, total_levels);  // Возвращаем максимальный уровень
}

// Функция проверки, открыта ли следующая пещера
function is_next_cave_unlocked(state, level_num) {
    if (level_num < 6) {
        // Следующая пещера открывается, когда рычаг в текущей опущен
        return is_lever_pulled(state, level_num);
    }
    return false;
}

// Функция проверки завершения всей экспедиции
function is_expedition_completed(state) {
    // Экспедиция завершена, когда рычаг в 6-й пещере опущен
    return is_lever_pulled(state, 6);
}

// Функция получения статуса уровня (completed, lever_pulled, locked)
function get_level_status(state, level_num) {
    if (level_num < 1 || level_num > 6) return "invalid";
    
    // Первый уровень всегда разблокирован
    if (level_num == 1) {
        if (is_level_completed(state, 1)) {
            return "completed";
        } else if (is_lever_pulled(state, 1)) {
            return "lever_pulled";
        } else {
            return "available";
        }
    }
    
    // Другие уровни разблокируются через рычаг предыдущего уровня
    if (is_next_cave_unlocked(state, level_num - 1)) {
        if (is_level_completed(state, level_num)) {
            return "completed";
        } else if (is_lever_pulled(state, level_num)) {
            return "lever_pulled";
        } else {
            return "available";
        }
    } else {
        return "locked";
    }
}

// Функция получения общего прогресса (сколько уровней открыто/завершено)
function get_overall_progress(state) {
    var opened_levels = 0;
    var completed_levels = 0;
    
    for (var i = 1; i <= 6; i++) {
        if (get_level_status(state, i) != "locked") {
            opened_levels++;
        }
        if (is_level_completed(state, i)) {
            completed_levels++;
        }
    }
    
    return {
        opened: opened_levels,
        completed: completed_levels,
        expedition_complete: is_expedition_completed(state)
    };
}

// Функция сброса прогресса уровня (для тестирования)
function reset_level_progress(state, level_num) {
    var completed_key = "level_" + string(level_num) + "_completed";
    var lever_key = "level_" + string(level_num) + "_lever_pulled";
    
    ds_map_replace(state.progress, completed_key, false);
    ds_map_replace(state.progress, lever_key, false);
}

// Функция инициализации глобальных переменных
function init_global_vars() {
    if (!global.initialized) {
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
    
    // Загрузка сохранения, если есть (всегда выполняем, даже если уже инициализировано)
    if (script_exists(scr_save_system)) {
        load_game();
    }
}
