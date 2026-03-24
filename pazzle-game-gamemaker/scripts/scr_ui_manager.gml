// UI менеджер для GameMaker
// Управление интерфейсом пользователя

var ui_elements = {
    hud_visible: true,
    dialog_box: false,
    menu_active: false,
    current_dialog: "",
    dialog_choices: []
};

// Показать HUD
function show_hud() {
    ui_elements.hud_visible = true;
}

// Скрыть HUD
function hide_hud() {
    ui_elements.hud_visible = false;
}

// Показать диалог
function show_dialog(text, choices = []) {
    ui_elements.dialog_box = true;
    ui_elements.current_dialog = text;
    ui_elements.dialog_choices = choices;
}

// Скрыть диалог
function hide_dialog() {
    ui_elements.dialog_box = false;
    ui_elements.current_dialog = "";
    ui_elements.dialog_choices = [];
}

// Показать меню
function show_menu(menu_type) {
    ui_elements.menu_active = true;
    // Здесь логика отображения конкретного типа меню
}

// Скрыть меню
function hide_menu() {
    ui_elements.menu_active = false;
}

// Отрисовка UI
function draw_ui() {
    if (ui_elements.hud_visible) {
        // Отображение информации о прогрессе, золоте и т.д.
        draw_set_color(c_white);
        draw_set_font(fnt_default);
        // Пример: отображение текущего уровня
        draw_text(10, 10, "Уровень: " + string(global.game_state.current_level));
        // Пример: отображение золота
        draw_text(10, 30, "Золото: " + string(global.game_state.gold));
    }
    
    if (ui_elements.dialog_box) {
        // Рисуем диалоговое окно
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(50, display_get_gui_height() - 150, display_get_gui_width() - 50, display_get_gui_height() - 50, false);
        draw_set_color(c_white);
        draw_set_alpha(1.0);
        draw_text(70, display_get_gui_height() - 130, ui_elements.current_dialog);
        
        // Если есть выбор - отображаем варианты
        if (array_length(ui_elements.dialog_choices) > 0) {
            for (var i = 0; i < array_length(ui_elements.dialog_choices); i++;) {
                draw_text(70, display_get_gui_height() - 110 + i * 20, string(i+1) + ". " + ui_elements.dialog_choices[i]);
            }
        }
    }
}

return ui_elements;