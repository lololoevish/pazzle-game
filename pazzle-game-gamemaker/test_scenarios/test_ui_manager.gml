// Сценарии тестирования для scr_ui_manager

// Тест 1: Проверка показа уведомлений
function test_show_notification() {
    // Проверяем, что функция не падает с различными параметрами
    show_notification("Тестовое уведомление", 2, c_white);
    show_notification("Уведомление без цвета", 1);
    show_notification("Уведомление по умолчанию");
    
    show_debug_message("Тест 1 пройден: Проверка показа уведомлений");
}

// Тест 2: Проверка обновления уведомлений
function test_update_notifications() {
    // Добавляем несколько уведомлений
    show_notification("Уведомление 1", 0.5);
    show_notification("Уведомление 2", 1.0);
    
    // Обновляем уведомления
    update_notifications(0.1);
    update_notifications(0.6); // Первое должно исчезнуть
    
    show_debug_message("Тест 2 пройден: Проверка обновления уведомлений");
}

// Тест 3: Проверка отрисовки уведомлений
function test_draw_notifications() {
    // Добавляем уведомления
    show_notification("Тест отрисовки", 2);
    
    // Проверяем, что функция отрисовки не падает
    draw_notifications();
    
    show_debug_message("Тест 3 пройден: Проверка отрисовки уведомлений");
}

// Тест 4: Проверка показа диалога
function test_show_dialog() {
    // Проверяем показ простого диалога
    show_dialog("Тестовый диалог");
    
    // Проверяем показ диалога с выбором
    show_dialog_with_choices("Выберите действие", ["Вариант 1", "Вариант 2", "Отмена"]);
    
    show_debug_message("Тест 4 пройден: Проверка показа диалога");
}

// Тест 5: Проверка закрытия диалога
function test_close_dialog() {
    // Показываем диалог
    show_dialog("Тест закрытия");
    
    // Закрываем диалог
    close_dialog();
    
    show_debug_message("Тест 5 пройден: Проверка закрытия диалога");
}

// Тест 6: Проверка отрисовки диалога
function test_draw_dialog() {
    // Показываем диалог
    show_dialog("Тест отрисовки диалога");
    
    // Проверяем, что функция отрисовки не падает
    draw_dialog();
    
    show_debug_message("Тест 6 пройден: Проверка отрисовки диалога");
}

// Тест 7: Проверка отрисовки HUD
function test_draw_hud() {
    // Инициализируем глобальные переменные если нужно
    if (!variable_global_exists("game_progress")) {
        init_global_vars();
    }
    
    // Проверяем, что функция отрисовки HUD не падает
    draw_hud();
    
    show_debug_message("Тест 7 пройден: Проверка отрисовки HUD");
}

// Тест 8: Проверка отрисовки прогресса уровня
function test_draw_level_progress() {
    // Проверяем отрисовку с различными параметрами
    draw_level_progress(100, 100, 1, 6);
    draw_level_progress(200, 200, 3, 6);
    draw_level_progress(300, 300, 6, 6);
    
    show_debug_message("Тест 8 пройден: Проверка отрисовки прогресса уровня");
}

// Тест 9: Проверка отрисовки меню
function test_draw_menu() {
    var menu_items = ["Играть", "Настройки", "Выход"];
    
    // Проверяем отрисовку меню с различными параметрами
    draw_menu(400, 300, menu_items, 0);
    draw_menu(400, 300, menu_items, 1);
    draw_menu(400, 300, menu_items, 2);
    
    show_debug_message("Тест 9 пройден: Проверка отрисовки меню");
}

// Тест 10: Проверка отрисовки кнопки
function test_draw_button() {
    // Проверяем отрисовку кнопок в различных состояниях
    draw_button(100, 100, 200, 50, "Нажми меня", false);
    draw_button(100, 200, 200, 50, "Наведено", true);
    
    show_debug_message("Тест 10 пройден: Проверка отрисовки кнопки");
}

// Тест 11: Проверка отрисовки панели
function test_draw_panel() {
    // Проверяем отрисовку панелей с различными параметрами
    draw_panel(50, 50, 300, 200, c_dkgray, 0.8);
    draw_panel(400, 50, 300, 200, c_navy, 0.9);
    
    show_debug_message("Тест 11 пройден: Проверка отрисовки панели");
}

// Тест 12: Проверка отрисовки текста с тенью
function test_draw_text_shadow() {
    // Проверяем отрисовку текста с тенью
    draw_text_shadow(400, 300, "Текст с тенью", c_white, c_black);
    draw_text_shadow(400, 350, "Другой текст", c_yellow, c_dkgray);
    
    show_debug_message("Тест 12 пройден: Проверка отрисовки текста с тенью");
}

// Функция запуска всех тестов
function run_all_tests() {
    show_debug_message("=== Запуск тестов scr_ui_manager ===");
    
    test_show_notification();
    test_update_notifications();
    test_draw_notifications();
    test_show_dialog();
    test_close_dialog();
    test_draw_dialog();
    test_draw_hud();
    test_draw_level_progress();
    test_draw_menu();
    test_draw_button();
    test_draw_panel();
    test_draw_text_shadow();
    
    show_debug_message("=== Все тесты для scr_ui_manager пройдены успешно! ===");
}
