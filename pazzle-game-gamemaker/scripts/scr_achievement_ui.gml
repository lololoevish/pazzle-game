/*
 * Achievement UI Manager
 * Управляет отображением достижений
 */

// Глобальные переменные для UI достижений
global.achievement_ui = {
    visible: false,
    selected_category: "all",
    selected_index: 0,
    scroll_offset: 0,
    notification_queue: []
};

// Отрисовка экрана достижений
function draw_achievements_screen() {
    if (!global.achievement_ui.visible) return;
    
    var screen_w = window_get_width();
    var screen_h = window_get_height();
    
    // Затемнение фона
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(0, 0, screen_w, screen_h, false);
    draw_set_alpha(1.0);
    
    // Панель достижений
    var panel_x = screen_w * 0.1;
    var panel_y = screen_h * 0.1;
    var panel_w = screen_w * 0.8;
    var panel_h = screen_h * 0.8;
    
    draw_panel(panel_x, panel_y, panel_w, panel_h, c_dkgray, 0.95);
    
    // Заголовок
    draw_set_font(global.fnt_default);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text_shadow(panel_x + panel_w / 2, panel_y + 20, "ДОСТИЖЕНИЯ", c_white, c_black);
    
    // Прогресс
    var progress = get_achievement_progress();
    var progress_text = string(progress.unlocked) + " / " + string(progress.total) + 
                       " (" + string(floor(progress.percentage)) + "%)";
    draw_set_halign(fa_center);
    draw_text_shadow(panel_x + panel_w / 2, panel_y + 50, progress_text, c_yellow, c_black);
    
    // Категории
    draw_achievement_categories(panel_x + 20, panel_y + 90, panel_w - 40);
    
    // Список достижений
    draw_achievement_list(panel_x + 20, panel_y + 140, panel_w - 40, panel_h - 180);
    
    // Подсказка
    draw_set_halign(fa_center);
    draw_set_color(c_ltgray);
    draw_text(panel_x + panel_w / 2, panel_y + panel_h - 30, "ESC - Закрыть");
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Отрисовка категорий
function draw_achievement_categories(x, y, width) {
    var categories = [
        {id: "all", name: "Все"},
        {id: "progress", name: "Прогресс"},
        {id: "mastery", name: "Мастерство"},
        {id: "exploration", name: "Исследование"},
        {id: "collection", name: "Коллекции"},
        {id: "secret", name: "Секретные"}
    ];
    
    var button_width = width / array_length(categories);
    
    for (var i = 0; i < array_length(categories); i++) {
        var cat = categories[i];
        var btn_x = x + i * button_width;
        var is_selected = (global.achievement_ui.selected_category == cat.id);
        
        var btn_color = is_selected ? c_yellow : c_gray;
        draw_button(btn_x, y, button_width - 5, 30, cat.name, is_selected);
    }
}

// Отрисовка списка достижений
function draw_achievement_list(x, y, width, height) {
    var achievements = [];
    
    // Фильтруем по категории
    if (global.achievement_ui.selected_category == "all") {
        achievements = global.achievements.list;
    } else {
        achievements = get_achievements_by_category(global.achievement_ui.selected_category);
    }
    
    var item_height = 80;
    var visible_items = floor(height / item_height);
    var start_index = global.achievement_ui.scroll_offset;
    var end_index = min(start_index + visible_items, array_length(achievements));
    
    for (var i = start_index; i < end_index; i++) {
        var achievement = achievements[i];
        var item_y = y + (i - start_index) * item_height;
        
        draw_achievement_item(x, item_y, width, item_height - 5, achievement, i == global.achievement_ui.selected_index);
    }
    
    // Скроллбар
    if (array_length(achievements) > visible_items) {
        draw_scrollbar(x + width + 5, y, 10, height, start_index, array_length(achievements), visible_items);
    }
}

// Отрисовка одного достижения
function draw_achievement_item(x, y, width, height, achievement, is_selected) {
    // Фон
    var bg_color = is_selected ? c_dkgray : c_black;
    var alpha = achievement.unlocked ? 1.0 : 0.5;
    
    draw_set_alpha(alpha);
    draw_panel(x, y, width, height, bg_color, 0.9);
    draw_set_alpha(1.0);
    
    // Иконка (заглушка)
    var icon_size = height - 10;
    var icon_color = achievement.unlocked ? c_yellow : c_gray;
    draw_set_color(icon_color);
    draw_rectangle(x + 5, y + 5, x + 5 + icon_size, y + 5 + icon_size, false);
    
    // Текст
    var text_x = x + icon_size + 15;
    var text_y = y + 10;
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // Название
    var name_text = achievement.hidden && !achievement.unlocked ? "???" : achievement.name;
    draw_set_color(achievement.unlocked ? c_white : c_gray);
    draw_text(text_x, text_y, name_text);
    
    // Описание
    var desc_text = achievement.hidden && !achievement.unlocked ? "Секретное достижение" : achievement.description;
    draw_set_color(c_ltgray);
    draw_text_ext(text_x, text_y + 20, desc_text, 16, width - icon_size - 30);
    
    // Награда
    if (achievement.unlocked || !achievement.hidden) {
        var reward_text = "";
        if (achievement.reward_gold > 0) {
            reward_text = "Награда: " + string(achievement.reward_gold) + " золота";
        }
        if (array_length(achievement.reward_items) > 0) {
            if (reward_text != "") reward_text += ", ";
            reward_text += "Предмет";
        }
        
        if (reward_text != "") {
            draw_set_color(c_yellow);
            draw_text(text_x, text_y + 45, reward_text);
        }
    }
    
    // Статус
    if (achievement.unlocked) {
        draw_set_color(c_lime);
        draw_text(x + width - 100, text_y, "✓ Получено");
        
        if (achievement.unlock_date != undefined) {
            draw_set_color(c_ltgray);
            draw_set_halign(fa_right);
            draw_text(x + width - 10, text_y + 20, date_datetime_string(achievement.unlock_date));
        }
    }
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
}

// Отрисовка скроллбара
function draw_scrollbar(x, y, width, height, current, total, visible) {
    // Фон
    draw_set_color(c_dkgray);
    draw_rectangle(x, y, x + width, y + height, false);
    
    // Ползунок
    var bar_height = (visible / total) * height;
    var bar_y = y + (current / total) * height;
    
    draw_set_color(c_gray);
    draw_rectangle(x, bar_y, x + width, bar_y + bar_height, false);
}

// Открытие экрана достижений
function open_achievements_screen() {
    global.achievement_ui.visible = true;
    global.achievement_ui.selected_category = "all";
    global.achievement_ui.selected_index = 0;
    global.achievement_ui.scroll_offset = 0;
}

// Закрытие экрана достижений
function close_achievements_screen() {
    global.achievement_ui.visible = false;
}

// Обработка ввода для экрана достижений
function handle_achievements_input() {
    if (!global.achievement_ui.visible) return;
    
    // Закрытие
    if (keyboard_check_pressed(vk_escape)) {
        close_achievements_screen();
        return;
    }
    
    // Навигация по категориям
    if (keyboard_check_pressed(vk_left)) {
        change_achievement_category(-1);
    }
    if (keyboard_check_pressed(vk_right)) {
        change_achievement_category(1);
    }
    
    // Навигация по списку
    if (keyboard_check_pressed(vk_up)) {
        global.achievement_ui.selected_index = max(0, global.achievement_ui.selected_index - 1);
        update_scroll_offset();
    }
    if (keyboard_check_pressed(vk_down)) {
        var max_index = get_filtered_achievements_count() - 1;
        global.achievement_ui.selected_index = min(max_index, global.achievement_ui.selected_index + 1);
        update_scroll_offset();
    }
}

// Смена категории
function change_achievement_category(direction) {
    var categories = ["all", "progress", "mastery", "exploration", "collection", "secret"];
    var current_index = array_get_index(categories, global.achievement_ui.selected_category);
    
    current_index += direction;
    if (current_index < 0) current_index = array_length(categories) - 1;
    if (current_index >= array_length(categories)) current_index = 0;
    
    global.achievement_ui.selected_category = categories[current_index];
    global.achievement_ui.selected_index = 0;
    global.achievement_ui.scroll_offset = 0;
}

// Получение количества отфильтрованных достижений
function get_filtered_achievements_count() {
    if (global.achievement_ui.selected_category == "all") {
        return array_length(global.achievements.list);
    }
    return array_length(get_achievements_by_category(global.achievement_ui.selected_category));
}

// Обновление смещения скролла
function update_scroll_offset() {
    var visible_items = 6; // Примерное количество видимых элементов
    
    if (global.achievement_ui.selected_index < global.achievement_ui.scroll_offset) {
        global.achievement_ui.scroll_offset = global.achievement_ui.selected_index;
    }
    
    if (global.achievement_ui.selected_index >= global.achievement_ui.scroll_offset + visible_items) {
        global.achievement_ui.scroll_offset = global.achievement_ui.selected_index - visible_items + 1;
    }
}

// Отрисовка всплывающего уведомления о достижении
function draw_achievement_notifications() {
    var notification_y = 100;
    
    for (var i = 0; i < array_length(global.achievement_ui.notification_queue); i++) {
        var notif = global.achievement_ui.notification_queue[i];
        
        // Обновляем таймер
        notif.timer += 1 / 60; // Предполагаем 60 FPS
        
        if (notif.timer >= notif.duration) {
            array_delete(global.achievement_ui.notification_queue, i, 1);
            i--;
            continue;
        }
        
        // Анимация появления/исчезновения
        var alpha = 1.0;
        if (notif.timer < 0.5) {
            alpha = notif.timer / 0.5;
        } else if (notif.timer > notif.duration - 0.5) {
            alpha = (notif.duration - notif.timer) / 0.5;
        }
        
        draw_set_alpha(alpha);
        draw_achievement_notification_popup(window_get_width() - 320, notification_y, 300, notif.achievement);
        draw_set_alpha(1.0);
        
        notification_y += 120;
    }
}

// Отрисовка всплывающего уведомления
function draw_achievement_notification_popup(x, y, width, achievement) {
    var height = 100;
    
    // Фон
    draw_panel(x, y, width, height, c_dkgray, 0.95);
    
    // Рамка
    draw_set_color(c_yellow);
    draw_rectangle(x, y, x + width, y + height, true);
    
    // Заголовок
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_yellow);
    draw_text(x + width / 2, y + 5, "ДОСТИЖЕНИЕ ПОЛУЧЕНО!");
    
    // Название
    draw_set_color(c_white);
    draw_text(x + width / 2, y + 25, achievement.name);
    
    // Награда
    if (achievement.reward_gold > 0) {
        draw_set_color(c_yellow);
        draw_text(x + width / 2, y + 50, "+" + string(achievement.reward_gold) + " золота");
    }
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
}

// Добавление уведомления в очередь
function queue_achievement_notification(achievement) {
    array_push(global.achievement_ui.notification_queue, {
        achievement: achievement,
        timer: 0,
        duration: 5
    });
}
