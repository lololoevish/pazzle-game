/*
 * VN Master Controller
 * Главный контроллер для инициализации и управления VN-системой
 */

// Инициализация всей VN-системы
function vn_system_init() {
    vn_portrait_init();
    vn_text_init();
    vn_dialogue_init();
    vn_ui_init();
    
    show_debug_message("VN System initialized");
}

// Обновление VN-системы (вызывать в Step event)
function vn_system_update() {
    if (!vn_is_dialogue_active()) return;
    
    // Обновление портретов
    vn_update_portraits();
    
    // Обновление текста
    vn_text_update();
    
    // Обновление UI
    vn_update_ui();
    
    // Обработка ввода для продолжения диалога
    if (!vn_are_choices_visible()) {
        if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
            vn_advance_dialogue();
        }
    }
}

// Отрисовка VN-системы (вызывать в Draw GUI event)
function vn_system_draw() {
    if (!vn_is_dialogue_active()) return;
    
    vn_draw_full_ui();
}

// Очистка VN-системы
function vn_system_cleanup() {
    vn_portrait_cleanup();
    vn_text_cleanup();
    vn_dialogue_cleanup();
    vn_ui_cleanup();
    
    show_debug_message("VN System cleaned up");
}

// Быстрый старт диалога (упрощенная функция)
function vn_quick_start(character_id, tree_id) {
    // Определяем позицию портрета по умолчанию
    var position = "left";
    
    // Загружаем дерево диалогов
    vn_load_dialogue_tree(tree_id);
    
    // Начинаем диалог
    vn_start_dialogue("start", character_id, position);
}
