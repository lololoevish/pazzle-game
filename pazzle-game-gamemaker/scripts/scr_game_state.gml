// Управление состоянием игры
// Соответствует GameState из Rust-версии

var state_data = {
    current_state: "MENU",
    current_level: 1,
    progress: ds_map_create(),
    gold: 0,
    items: [],
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