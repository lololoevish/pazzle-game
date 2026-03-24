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
    for (var i = 1; i <= 6; i += 1) {
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