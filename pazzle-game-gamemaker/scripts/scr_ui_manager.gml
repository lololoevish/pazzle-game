// UI менеджер для GameMaker
// Управление интерфейсом пользователя

// Глобальные переменные для UI
globalvar ui_initialized;
if (!variable_instance_exists(global, "ui_initialized")) {
    global.ui_initialized = false;
}

// Инициализация UI
function initialize_ui() {
    if (!global.ui_initialized) {
        // Создаем структуру UI элементов
        if (!variable_instance_exists(global, "ui_elements")) {
            global.ui_elements = {
                hud_visible: true,
                dialog_box: false,
                menu_active: false,
                current_dialog: "",
                dialog_choices: ds_list_create(),  // используем ds_list для лучшей совместимости
                npc_dialogue_active: false,
                npc_dialogue_name: "",
                mini_game_active: false,
                mini_game_type: "",
                input_buffer: "",  // для ввода текста
                show_cursor: true  // показывать ли курсор
            };
        }
        
        global.ui_initialized = true;
    }
}

// Показать HUD
function show_hud() {
    global.ui_elements.hud_visible = true;
}

// Скрыть HUD
function hide_hud() {
    global.ui_elements.hud_visible = false;
}

// Показать диалог
function show_dialog(text, choices = []) {
    global.ui_elements.dialog_box = true;
    global.ui_elements.current_dialog = text;
    
    // Очищаем старые выборы
    if (ds_list_empty(global.ui_elements.dialog_choices) == false) {
        ds_list_clear(global.ui_elements.dialog_choices);
    }
    
    // Добавляем новые выборы
    for (var i = 0; i < array_length_1d(choices); i++) {
        ds_list_add(global.ui_elements.dialog_choices, choices[i]);
    }
}

// Скрыть диалог
function hide_dialog() {
    global.ui_elements.dialog_box = false;
    global.ui_elements.current_dialog = "";
    
    if (ds_list_empty(global.ui_elements.dialog_choices) == false) {
        ds_list_clear(global.ui_elements.dialog_choices);
    }
}

// Показать NPC диалог
function show_npc_dialogue(npc_name, dialogue_text) {
    global.ui_elements.npc_dialogue_active = true;
    global.ui_elements.npc_dialogue_name = npc_name;
    global.ui_elements.current_dialog = dialogue_text;
}

// Скрыть NPC диалог
function hide_npc_dialogue() {
    global.ui_elements.npc_dialogue_active = false;
    global.ui_elements.npc_dialogue_name = "";
    global.ui_elements.current_dialog = "";
    
    if (ds_list_empty(global.ui_elements.dialog_choices) == false) {
        ds_list_clear(global.ui_elements.dialog_choices);
    }
}

// Показать мини-игру
function show_mini_game(game_type) {
    global.ui_elements.mini_game_active = true;
    global.ui_elements.mini_game_type = game_type;
}

// Скрыть мини-игру
function hide_mini_game() {
    global.ui_elements.mini_game_active = false;
    global.ui_elements.mini_game_type = "";
}

// Показать меню
function show_menu(menu_type) {
    global.ui_elements.menu_active = true;
    // Здесь логика отображения конкретного типа меню
}

// Скрыть меню
function hide_menu() {
    global.ui_elements.menu_active = false;
}

// Отрисовка UI
function draw_ui() {
    // Инициализация UI если нужно
    initialize_ui();
    
    if (global.ui_elements.hud_visible) {
        // Отображение информации о прогрессе, золоте и т.д.
        draw_set_color(c_white);
        if (font_exists(fnt_default)) {
            draw_set_font(fnt_default);
        }
        
        // Отображение текущего состояния
        draw_text(10, 10, "Состояние: " + string(global.game_state.current_state));
        
        // Отображение информации о прогрессе в зависимости от состояния
        if (variable_instance_exists(global, "game_state")) {
            if (global.game_state.current_state == "TOWN") {
                // В городе отображаем золото и прогресс
                draw_text(10, 30, "Золото: " + string(global.game_state.gold));
                
                // Отображаем количество открытых уровней
                var unlocked_levels = 0;
                var i;
                for (i = 1; i <= 6; i ++) {
                    if (scr_game_state.is_lever_pulled(global.game_state, i)) {
                        unlocked_levels += 1;
                    }
                }
                draw_text(10, 50, "Открытые пещеры: " + string(unlocked_levels) + "/6");
            } else if (global.game_state.current_state == "PLAYING") {
                draw_text(10, 30, "Уровень: " + string(global.game_state.current_level));
                draw_text(10, 50, "Золото: " + string(global.game_state.gold));
            }
        }
    }
    
    // Отображение NPC диалога
    if (global.ui_elements.npc_dialogue_active && string_length(global.ui_elements.current_dialog) > 0) {
        // Рисуем диалоговое окно
        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_rectangle(25, display_get_gui_height() - 180, display_get_gui_width() - 25, display_get_gui_height() - 25, false);
        
        // Заголовок с именем NPC
        draw_set_color(c_yellow);
        draw_set_valign(fa_top);
        draw_text(40, display_get_gui_height() - 170, global.ui_elements.npc_dialogue_name);
        
        // Текст диалога
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_text_ext(40, display_get_gui_height() - 145, global.ui_elements.current_dialog, display_get_gui_width() - 80, 80);
        
        // Показываем подсказку о продолжении
        draw_set_color(c_gray);
        draw_text(display_get_gui_width() - 120, display_get_gui_height() - 40, "Нажмите E для продолжения");
    }
    
    // Отображение стандартного диалога
    else if (global.ui_elements.dialog_box) {
        // Рисуем диалоговое окно
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(50, display_get_gui_height() - 150, display_get_gui_width() - 50, display_get_gui_height() - 50, false);
        draw_set_color(c_white);
        draw_set_alpha(1.0);
        draw_text(70, display_get_gui_height() - 130, global.ui_elements.current_dialog);
        
        // Если есть выбор - отображаем варианты
        if (ds_list_empty(global.ui_elements.dialog_choices) == false) {
            for (var i = 0; i < ds_list_size(global.ui_elements.dialog_choices); i++) {
                var choice_text = ds_list_find_value(global.ui_elements.dialog_choices, i);
                draw_text(70, display_get_gui_height() - 110 + i * 20, string(i+1) + ". " + string(choice_text));
            }
        }
    }
    
    // Отображение мини-игры (если активна)
    if (global.ui_elements.mini_game_active) {
        draw_mini_game_interface();
    }
}

// Отрисовка интерфейса мини-игры
function draw_mini_game_interface() {
    // Интерфейс для конкретной мини-игры
    draw_set_color(c_blue);
    draw_set_alpha(0.8);
    draw_rectangle(100, 100, display_get_gui_width() - 100, display_get_gui_height() - 100, false);
    
    draw_set_color(c_white);
    draw_text(120, 120, "Мини-игра: " + string(global.ui_elements.mini_game_type));
    
    // Завершающая инструкция
    draw_text(120, 140, "Нажмите пробел для завершения");
}

// Функция обновления UI
function update_ui() {
    // Инициализация UI если нужно
    initialize_ui();
    
    // Обработка ввода для UI элементов
    if (keyboard_check_pressed(ord('E')) && global.ui_elements.npc_dialogue_active) {
        hide_npc_dialogue();
    }
    
    if (keyboard_check_pressed(vk_space) && global.ui_elements.mini_game_active) {
        // Завершаем мини-игру и возвращаемся в хаб
        complete_mini_game(global.ui_elements.mini_game_type);
        hide_mini_game();
    }
}

// Функция завершения мини-игры
function complete_mini_game(game_type) {
    if (!variable_instance_exists(global, "game_state")) {
        // Если глобальное состояние игры не существует, создаем его
        global.game_state = scr_game_state.create_new_game_state();
    }
    
    // Обновляем состояние игры в зависимости от типа мини-игры
    switch(game_type) {
        case "elder_trial":
            global.game_state.elder_trial_completed = true;
            // Добавляем награду
            global.game_state.gold += 50;
            break;
        case "mechanic_calibration":
            global.game_state.mechanic_training_completed = true;
            // Добавляем награду
            global.game_state.gold += 30;
            ds_list_add(global.game_state.items, "инструменты механика");
            break;
        case "archivist_quiz":
            global.game_state.archivist_quiz_completed = true;
            // Добавляем награду
            global.game_state.gold += 40;
            ds_list_add(global.game_state.items, "книга древностей");
            break;
    }
    
    // Сохраняем игру
    scr_save_system.save_game(global.game_state);
}

// Функция для отображения всплывающих сообщений
function show_popup_message(message, duration = 60) {  // 60 тиков = 1 секунда при 60 FPS
    // В реальном проекте здесь будет реализация всплывающего сообщения
    show_debug_message("Popup: " + message);
}

// Функция получения текущего состояния UI
function get_ui_state() {
    return {
        hud_visible: global.ui_elements.hud_visible,
        dialog_active: global.ui_elements.dialog_box || global.ui_elements.npc_dialogue_active,
        current_dialog: global.ui_elements.current_dialog,
        mini_game_active: global.ui_elements.mini_game_active
    };
}