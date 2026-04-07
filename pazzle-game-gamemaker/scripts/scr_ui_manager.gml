/*
 * UI-менеджер
 * Управляет интерфейсом пользователя
 */

// Инициализация UI параметров
var ui_config = {
    ui_scale: 1.0,
    ui_alpha: 1.0,
    font_default: (global.fnt_default != undefined) ? global.fnt_default : font_get_default(),
    font_size_normal: 16,
    font_size_large: 24,
    font_size_small: 12,
    color_text: c_white,
    color_highlight: c_yellow,
    color_error: c_red,
    color_success: c_lime,
    ui_elements: []
};

// Структура для хранения UI элементов
var ui_elements = {
    notifications: [],      // Уведомления
    dialogs: [],           // Диалоги
    menus: [],             // Меню
    overlays: []           // Оверлеи
};

// Функция показа уведомления
function show_notification(text, duration, color) {
    if (color == undefined) color = ui_config.color_text;
    if (duration == undefined) duration = 2;  // 2 секунды по умолчанию
    
    var notification = {
        text: text,
        duration: duration,
        color: color,
        timer: 0,
        active: true
    };
    
    // Добавляем в начало массива, чтобы новые уведомления были поверх
    array_insert(ui_elements.notifications, 0, notification);
    
    // Ограничиваем количество активных уведомлений
    if (array_length(ui_elements.notifications) > 5) {
        array_delete(ui_elements.notifications, 5, array_length(ui_elements.notifications) - 5);
    }
}

// Функция обновления уведомлений
function update_notifications(dt) {
    for (var i = array_length(ui_elements.notifications) - 1; i >= 0; i--) {
        var note = ui_elements.notifications[i];
        note.timer += dt;
        
        if (note.timer >= note.duration) {
            array_delete(ui_elements.notifications, i, 1);
        }
    }
}

// Функция отрисовки уведомлений
function draw_notifications() {
    var base_y = 20;
    for (var i = 0; i < min(array_length(ui_elements.notifications), 5); i++) {
        var note = ui_elements.notifications[i];
        var alpha = 1.0;
        
        // Плавное исчезновение в конце
        var remaining = note.duration - note.timer;
        if (remaining < 0.5) {
            alpha = remaining / 0.5;
        }
        
        draw_set_alpha(alpha);
        draw_set_color(note.color);
        draw_set_font(ui_config.font_default);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        
        var x = window_get_width() / 2;
        var y = base_y + i * 30;
        
        // Печатаем текст с эффектом затенения
        draw_set_color(c_black);
        draw_text(x+1, y+1, note.text);
        draw_set_color(note.color);
        draw_text(x, y, note.text);
        
        draw_set_alpha(1.0);
    }
}

// Функция показа диалога
function show_dialog(text, options, callback) {
    var dialog = {
        text: text,
        options: options,
        callback: callback,
        selected_option: 0,
        active: true,
        timer: 0
    };
    
    array_push(ui_elements.dialogs, dialog);
}

// Функция обработки ввода в диалоге
function handle_dialog_input() {
    if (array_length(ui_elements.dialogs) > 0) {
        var dialog = ui_elements.dialogs[array_length(ui_elements.dialogs) - 1];
        
        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord('W'))) {
            dialog.selected_option = max(0, dialog.selected_option - 1);
            if (script_exists(scr_audio_manager) && scr_audio_manager.play_event_sound != undefined) {
                scr_audio_manager.play_event_sound("ui_move");
            }
        }
        
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord('S'))) {
            dialog.selected_option = min(array_length(dialog.options) - 1, dialog.selected_option + 1);
            if (script_exists(scr_audio_manager) && scr_audio_manager.play_event_sound != undefined) {
                scr_audio_manager.play_event_sound("ui_move");
            }
        }
        
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord('E')) || mouse_check_button_pressed(mb_left)) {
            if (dialog.callback != undefined) {
                dialog.callback(dialog.selected_option);
            }
            array_delete(ui_elements.dialogs, array_length(ui_elements.dialogs) - 1, 1);
            if (script_exists(scr_audio_manager) && scr_audio_manager.play_event_sound != undefined) {
                scr_audio_manager.play_event_sound("ui_confirm");
            }
        }
        
        if (keyboard_check_pressed(vk_escape)) {
            array_delete(ui_elements.dialogs, array_length(ui_elements.dialogs) - 1, 1);
            if (script_exists(scr_audio_manager) && scr_audio_manager.play_event_sound != undefined) {
                scr_audio_manager.play_event_sound("ui_cancel");
            }
        }
    }
}

// Функция отрисовки диалога
function draw_dialog() {
    if (array_length(ui_elements.dialogs) > 0) {
        var dialog = ui_elements.dialogs[array_length(ui_elements.dialogs) - 1];
        
        // Рисуем оверлей
        draw_set_alpha(0.7);
        draw_set_color(c_black);
        draw_rectangle(0, 0, window_get_width(), window_get_height());
        draw_set_alpha(1.0);
        
        // Рисуем панель диалога
        var panel_width = min(window_get_width() * 0.8, 600);
        var panel_height = 200 + array_length(dialog.options) * 30;
        var panel_x = (window_get_width() - panel_width) / 2;
        var panel_y = (window_get_height() - panel_height) / 2;
        
        draw_set_color(c_navy);
        draw_rectangle(panel_x, panel_y, panel_x + panel_width, panel_y + panel_height);
        draw_set_color(c_lightgray);
        draw_rectangle_border(panel_x, panel_y, panel_x + panel_width, panel_y + panel_height, 4);
        
        // Рисуем текст
        draw_set_color(ui_config.color_text);
        draw_set_font(ui_config.font_default);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        draw_text_ext(dialog.text, panel_x + 20, panel_y + 20, panel_width - 40, 24);
        
        // Рисуем опции
        for (var i = 0; i < array_length(dialog.options); i++) {
            var option_y = panel_y + 100 + i * 30;
            if (i == dialog.selected_option) {
                draw_set_color(ui_config.color_highlight);
                draw_rectangle(panel_x + 15, option_y - 5, panel_x + panel_width - 15, option_y + 25);
            } else {
                draw_set_color(ui_config.color_text);
            }
            
            draw_text(panel_x + 20, option_y, "> " + dialog.options[i]);
        }
        
        draw_set_color(ui_config.color_text);
        draw_text(panel_x + 20, panel_y + panel_height - 30, "ENTER - выбрать, ESC - отмена");
    }
}

// Функция отображения сообщения
function show_message(text, duration) {
    if (duration == undefined) duration = 3;
    
    var msg = {
        text: text,
        duration: duration,
        timer: 0,
        active: true
    };
    
    // Очищаем предыдущее сообщение
    ui_elements.message = msg;
}

// Функция отрисовки основного сообщения
function draw_message() {
    if (ui_elements.message != undefined && ui_elements.message.active) {
        var msg = ui_elements.message;
        var alpha = 1.0;
        
        // Плавное появление и исчезновение
        if (msg.timer < 0.5) {
            alpha = msg.timer / 0.5;
        } else if (msg.duration - msg.timer < 0.5) {
            alpha = (msg.duration - msg.timer) / 0.5;
        }
        
        draw_set_alpha(alpha);
        draw_set_color(ui_config.color_text);
        draw_set_font(ui_config.font_default);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        var x = window_get_width() / 2;
        var y = window_get_height() - 50;
        
        // Фон сообщения
        draw_set_color(c_black);
        draw_rectangle(x - 150, y - 20, x + 150, y + 20);
        draw_set_color(ui_config.color_text);
        
        draw_text(x, y, msg.text);
        draw_set_alpha(1.0);
    }
}

// Функция обновления основного сообщения
function update_message(dt) {
    if (ui_elements.message != undefined) {
        ui_elements.message.timer += dt;
        if (ui_elements.message.timer >= ui_elements.message.duration) {
            ui_elements.message.active = false;
        }
    }
}

// Функция отображения прогресса экспедиции
function draw_expedition_progress(x, y, width, height) {
    var progress = scr_game_controller.get_current_objective_level();
    var opened = scr_game_controller.count_opened_levels();
    var completed = scr_game_controller.count_completed_levels();
    
    draw_set_color(c_gray);
    draw_rectangle(x, y, x + width, y + height);
    
    draw_set_color(c_blue);
    draw_rectangle(x, y, x + (opened / 6) * width, y + height);
    
    draw_set_color(c_white);
    draw_set_font(ui_config.font_default);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var text = string(completed) + "/6 уровней пройдено, цель: уровень " + string(progress);
    draw_text(x + width/2, y + height/2, text);
}

// Функция отображения инвентаря
function show_inventory() {
    // Показываем окно инвентаря с золотом и предметами
    var progress = global.game_progress;
    var inventory_text = "Золото: " + string(progress.gold) + "\nПредметы:\n";
    
    for (var i = 0; i < array_length(progress.items); i++) {
        inventory_text += "- " + string(progress.items[i]) + "\n";
    }
    
    show_dialog(inventory_text, ["Закрыть"], function(selected) {});
}

// Функция отображения прогресса NPC заданий
function draw_npc_progress(x, y) {
    var progress = global.game_progress;
    var npc_status = "NPC задания:\n";
    
    npc_status += "Механик: ";
    npc_status += progress.mechanic_training_completed ? "Завершено" : "Не завершено";
    npc_status += "\n";
    
    npc_status += "Архивариус: ";
    npc_status += progress.archivist_quiz_completed ? "Завершено" : "Не завершено";
    npc_status += "\n";
    
    npc_status += "Староста: ";
    npc_status += progress.elder_trial_completed ? "Завершено" : "Не завершено";
    
    draw_set_color(c_white);
    draw_set_font(ui_config.font_default);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(x, y, npc_status);
}

// Функция отрисовки UI
function draw_ui() {
    // Отрисовываем все UI элементы сверху вниз
    
    // Основное сообщение
    draw_message();
    
    // Уведомления
    draw_notifications();
    
    // Диалог
    draw_dialog();
    
    // Восстанавливаем цвет
    draw_set_color(c_white);
}

// Функция обновления UI
function update_ui(dt) {
    update_notifications(dt);
    update_message(dt);
}

// Функция проверки коллизии с UI элементом
function ui_element_collision(x, y, element) {
    return (x >= element.x && x <= element.x + element.width &&
            y >= element.y && y <= element.y + element.height);
}

// Функция инициализации UI
function init_ui() {
    // Проверяем, определен ли глобальный шрифт
    if (global.fnt_default != undefined) {
        ui_config.font_default = global.fnt_default;
    } else {
        ui_config.font_default = font_get_default();
    }
    ui_elements.message = undefined;
}