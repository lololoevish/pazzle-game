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
    show_dialog("Тестовый диалог", ["Ок"], undefined);
    
    // Проверяем показ диалога с несколькими опциями через актуальный API
    show_dialog("Выберите действие", ["Вариант 1", "Вариант 2", "Отмена"], undefined);
    
    show_debug_message("Тест 4 пройден: Проверка показа диалога");
}

// Тест 5: Проверка закрытия диалога
function test_close_dialog() {
    // Показываем диалог
    show_dialog("Тест закрытия", ["Закрыть"], undefined);
    
    // Закрываем диалог
    hide_dialog();
    
    show_debug_message("Тест 5 пройден: Проверка закрытия диалога");
}

// Тест 6: Проверка отрисовки диалога
function test_draw_dialog() {
    // Показываем диалог
    show_dialog("Тест отрисовки диалога", ["Продолжить"], undefined);
    
    // Проверяем, что функция отрисовки не падает
    draw_dialog();
    
    show_debug_message("Тест 6 пройден: Проверка отрисовки диалога");
}

// Тест 7: Проверка отрисовки основного UI
function test_draw_ui() {
    // Инициализируем глобальные переменные если нужно
    if (!variable_global_exists("game_progress")) {
        init_global_vars();
    }
    
    show_message("Тест UI", 1);
    draw_ui();
    
    show_debug_message("Тест 7 пройден: Проверка отрисовки основного UI");
}

// Тест 8: Проверка отрисовки прогресса экспедиции
function test_draw_expedition_progress() {
    if (!variable_global_exists("game_progress")) {
        init_global_vars();
    }

    draw_expedition_progress(100, 100, 240, 24);
    
    show_debug_message("Тест 8 пройден: Проверка отрисовки прогресса экспедиции");
}

// Тест 9: Проверка диалога и сообщений NPC
function test_npc_ui_helpers() {
    show_npc_dialogue("Роан", "Проверка NPC-диалога");
    draw_ui();
    hide_npc_dialogue();
    
    show_debug_message("Тест 9 пройден: Проверка NPC UI helper-функций");
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
    test_draw_ui();
    test_draw_expedition_progress();
    test_npc_ui_helpers();
    
    show_debug_message("=== Все тесты для scr_ui_manager пройдены успешно! ===");
}
