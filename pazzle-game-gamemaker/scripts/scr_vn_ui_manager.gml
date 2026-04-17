/*
 * VN UI Manager
 * Управление интерфейсом визуальной новеллы
 */

// Инициализация VN UI
function vn_ui_init() {
    global.vn_ui = {
        dialogue_box: {x: 50, y: 400, width: 700, height: 150},
        name_box: {x: 50, y: 370, width: 150, height: 30},
        choice_box: {x: 100, y: 250, width: 600, height: 200},
        continue_arrow: {x: 730, y: 530, visible: false},
        choice_selected: 0,
        background_alpha: 0.3
    };
}

// Отрисовка диалогового окна
function vn_draw_dialogue_box() {
    var box = global.vn_ui.dialogue_box;
    
    // Фон диалогового окна
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(box.x, box.y, box.x + box.width, box.y + box.height, false);
    
    // Рамка
    draw_set_color(c_white);
    draw_set_alpha(1.0);
    draw_rectangle(box.x, box.y, box.x + box.width, box.y + box.height, true);
    draw_rectangle(box.x + 2, box.y + 2, box.x + box.width - 2, box.y + box.height - 2, true);
}

// Отрисовка окна с именем
function vn_draw_name_box(character_name) {
    var box = global.vn_ui.name_box;
    
    // Фон
    draw_set_color(c_black);
    draw_set_alpha(0.9);
    draw_rectangle(box.x, box.y, box.x + box.width, box.y + box.height, false);
    
    // Рамка
    draw_set_color(c_white);
    draw_set_alpha(1.0);
    draw_rectangle(box.x, box.y, box.x + box.width, box.y + box.height, true);
    
    // Имя персонажа
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(box.x + box.width / 2, box.y + box.height / 2, character_name);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Отрисовка текста диалога
function vn_draw_dialogue_text() {
    var box = global.vn_ui.dialogue_box;
    var text = vn_text_get_current();
    
    // Настройка текста
    draw_set_color(c_white);
    draw_set_alpha(1.0);
    
    // Отрисовка с переносом строк
    var text_x = box.x + 20;
    var text_y = box.y + 20;
    var text_width = box.width - 40;
    
    draw_text_ext(text_x, text_y, text, 20, text_width);
}

// Отрисовка стрелки "продолжить"
function vn_draw_continue_arrow() {
    if (!vn_text_is_finished()) return;
    
    var arrow = global.vn_ui.continue_arrow;
    
    // Анимация стрелки (bounce)
    var offset_y = sin(current_time / 200) * 5;
    
    draw_set_color(c_yellow);
    draw_set_alpha(0.8 + sin(current_time / 300) * 0.2);
    
    // Простая стрелка из текста
    draw_text(arrow.x, arrow.y + offset_y, "▼");
    
    draw_set_alpha(1.0);
}

// Отрисовка выборов
function vn_draw_choices() {
    if (!vn_are_choices_visible()) return;
    
    var choices = vn_get_current_choices();
    var box = global.vn_ui.choice_box;
    var selected = global.vn_ui.choice_selected;
    
    // Фон для выборов
    draw_set_color(c_black);
    draw_set_alpha(0.85);
    draw_rectangle(box.x, box.y, box.x + box.width, box.y + box.height, false);
    
    // Рамка
    draw_set_color(c_white);
    draw_set_alpha(1.0);
    draw_rectangle(box.x, box.y, box.x + box.width, box.y + box.height, true);
    
    // Отрисовка каждого выбора
    var choice_height = 40;
    var start_y = box.y + 20;
    
    for (var i = 0; i < array_length(choices); i++) {
        var choice_y = start_y + i * choice_height;
        var is_selected = (i == selected);
        
        // Подсветка выбранного
        if (is_selected) {
            draw_set_color(c_yellow);
            draw_set_alpha(0.3);
            draw_rectangle(box.x + 10, choice_y - 5, box.x + box.width - 10, choice_y + 25, false);
            draw_set_alpha(1.0);
        }
        
        // Курсор
        if (is_selected) {
            draw_set_color(c_yellow);
            draw_text(box.x + 20, choice_y, "►");
        }
        
        // Текст выбора
        draw_set_color(is_selected ? c_yellow : c_white);
        draw_text(box.x + 50, choice_y, choices[i].text);
    }
}

// Обновление выбора (навигация)
function vn_update_choice_selection() {
    if (!vn_are_choices_visible()) return;
    
    var choices = vn_get_current_choices();
    var choice_count = array_length(choices);
    
    if (choice_count == 0) return;
    
    // Навигация вверх
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord('W'))) {
        global.vn_ui.choice_selected--;
        if (global.vn_ui.choice_selected < 0) {
            global.vn_ui.choice_selected = choice_count - 1;
        }
        if (script_exists(play_event_sound)) {
            play_event_sound("ui_move");
        }
    }
    
    // Навигация вниз
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord('S'))) {
        global.vn_ui.choice_selected++;
        if (global.vn_ui.choice_selected >= choice_count) {
            global.vn_ui.choice_selected = 0;
        }
        if (script_exists(play_event_sound)) {
            play_event_sound("ui_move");
        }
    }
    
    // Подтверждение выбора
    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) {
        vn_select_choice(global.vn_ui.choice_selected);
        global.vn_ui.choice_selected = 0; // Сброс для следующего раза
    }
}

// Отрисовка затемнения фона
function vn_draw_background_overlay() {
    draw_set_color(c_black);
    draw_set_alpha(global.vn_ui.background_alpha);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1.0);
}

// Получить имя персонажа для отображения
function vn_get_character_display_name(character_id) {
    switch (character_id) {
        case "mechanic":
            return "Роан";
        case "archivist":
            return "Тель";
        case "elder":
            return "Иар";
        default:
            return "???";
    }
}

// Полная отрисовка VN UI
function vn_draw_full_ui() {
    if (!vn_is_dialogue_active()) return;
    
    // Затемнение фона
    vn_draw_background_overlay();
    
    // Портреты
    vn_draw_portraits();
    
    // Диалоговое окно
    vn_draw_dialogue_box();
    
    // Имя персонажа
    var character_name = vn_get_character_display_name(global.vn_dialogue.character_id);
    vn_draw_name_box(character_name);
    
    // Текст
    vn_draw_dialogue_text();
    
    // Стрелка продолжения
    if (!vn_are_choices_visible()) {
        vn_draw_continue_arrow();
    }
    
    // Выборы
    vn_draw_choices();
}

// Обновление VN UI
function vn_update_ui() {
    if (!vn_is_dialogue_active()) return;
    
    // Обновление выбора
    vn_update_choice_selection();
}

// Очистка VN UI
function vn_ui_cleanup() {
    global.vn_ui = {
        dialogue_box: {x: 50, y: 400, width: 700, height: 150},
        name_box: {x: 50, y: 370, width: 150, height: 30},
        choice_box: {x: 100, y: 250, width: 600, height: 200},
        continue_arrow: {x: 730, y: 530, visible: false},
        choice_selected: 0,
        background_alpha: 0.3
    };
}
