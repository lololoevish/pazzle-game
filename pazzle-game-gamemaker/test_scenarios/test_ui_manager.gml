// Сценарии тестирования для scr_ui_manager

// Тест 1: Инициализация UI-менеджера
function test_initialize_ui_manager() {
    // Инициализируем ui-менеджер (это происходит автоматически при первом обращении к функциям)
    
    // Убедимся, что глобальные переменные инициализированы
    assert_equal(variable_instance_exists(global, "ui_elements"), 1, 
                 "Тест 1.1: Должны существовать глобальные UI элементы");
    
    // Проверяем начальные значения
    assert_equal(global.ui_elements.hud_visible, true, "Тест 1.2: HUD должен быть видимым по умолчанию");
    assert_equal(global.ui_elements.dialog_box, false, "Тест 1.3: Диалоговое окно не должно быть активным по умолчанию");
    assert_equal(global.ui_elements.menu_active, false, "Тест 1.4: Меню не должно быть активным по умолчанию");
    assert_equal(global.ui_elements.npc_dialogue_active, false, "Тест 1.5: Диалог с NPC не должен быть активным по умолчанию");
    assert_equal(global.ui_elements.mini_game_active, false, "Тест 1.6: Мини-игра не должна быть активной по умолчанию");
    
    show_debug_message("Тест 1 пройден: Инициализация UI-менеджера");
}

// Тест 2: Управление видимостью HUD
function test_hud_visibility() {
    // Скрываем HUD
    scr_ui_manager.hide_hud();
    assert_equal(global.ui_elements.hud_visible, false, "Тест 2.1: HUD должен быть скрыт после hide_hud()");
    
    // Показываем HUD
    scr_ui_manager.show_hud();
    assert_equal(global.ui_elements.hud_visible, true, "Тест 2.2: HUD должен быть видим после show_hud()");
    
    show_debug_message("Тест 2 пройден: Управление видимостью HUD");
}

// Тест 3: Работа с диалоговыми окнами
function test_dialog_windows() {
    // Проверяем начальное состояние
    assert_equal(global.ui_elements.dialog_box, false, "Тест 3.1: Диалог не должен быть активен изначально");
    assert_equal(string_length(global.ui_elements.current_dialog), 0, "Тест 3.2: Текст диалога должен быть пустым изначально");
    
    // Показываем диалог
    scr_ui_manager.show_dialog("Привет, игрок!", ["Продолжить", "Отмена"]);
    
    // Проверяем, что диалог активирован
    assert_equal(global.ui_elements.dialog_box, true, "Тест 3.3: Диалог должен стать активным после show_dialog()");
    assert_equal(global.ui_elements.current_dialog, "Привет, игрок!", "Тест 3.4: Текст диалога должен быть установлен");
    assert_equal(array_length_1d(global.ui_elements.dialog_choices), 2, "Тест 3.5: Должно быть 2 варианта выбора");
    assert_equal(global.ui_elements.dialog_choices[0], "Продолжить", "Тест 3.6: Первый вариант должен быть 'Продолжить'");
    assert_equal(global.ui_elements.dialog_choices[1], "Отмена", "Тест 3.7: Второй вариант должен быть 'Отмена'");
    
    // Скрываем диалог
    scr_ui_manager.hide_dialog();
    
    // Проверяем, что диалог деактивирован
    assert_equal(global.ui_elements.dialog_box, false, "Тест 3.8: Диалог должен быть неактивным после hide_dialog()");
    assert_equal(string_length(global.ui_elements.current_dialog), 0, "Тест 3.9: Текст диалога должен быть очищен");
    assert_equal(array_length_1d(global.ui_elements.dialog_choices), 0, "Тест 3.10: Варианты выбора должны быть очищены");
    
    show_debug_message("Тест 3 пройден: Работа с диалоговыми окнами");
}

// Тест 4: Работа с диалогами NPC
function test_npc_dialogs() {
    // Проверяем начальное состояние
    assert_equal(global.ui_elements.npc_dialogue_active, false, "Тест 4.1: Диалог с NPC не должен быть активен изначально");
    
    // Показываем диалог NPC
    scr_ui_manager.show_npc_dialogue("Староста Иара", "Добро пожаловать в деревню!");
    
    // Проверяем, что диалог активирован
    assert_equal(global.ui_elements.npc_dialogue_active, true, "Тест 4.2: Диалог с NPC должен стать активным");
    assert_equal(global.ui_elements.npc_dialogue_name, "Староста Иара", "Тест 4.3: Должно быть установлено имя NPC");
    assert_equal(global.ui_elements.current_dialog, "Добро пожаловать в деревню!", "Тест 4.4: Текст диалога должен быть установлен");
    
    // Скрываем диалог NPC
    scr_ui_manager.hide_npc_dialogue();
    
    // Проверяем, что диалог деактивирован
    assert_equal(global.ui_elements.npc_dialogue_active, false, "Тест 4.5: Диалог с NPC должен быть неактивным после hide_npc_dialogue()");
    assert_equal(string_length(global.ui_elements.npc_dialogue_name), 0, "Тест 4.6: Имя NPC должно быть очищено");
    assert_equal(string_length(global.ui_elements.current_dialog), 0, "Тест 4.7: Текст диалога должен быть очищен");
    
    show_debug_message("Тест 4 пройден: Работа с диалогами NPC");
}

// Тест 5: Работа с мини-играми
function test_mini_games() {
    // Проверяем начальное состояние
    assert_equal(global.ui_elements.mini_game_active, false, "Тест 5.1: Мини-игра не должна быть активна изначально");
    assert_equal(string_length(global.ui_elements.mini_game_type), 0, "Тест 5.2: Тип мини-игры должен быть пустым изначально");
    
    // Показываем мини-игру
    scr_ui_manager.show_mini_game("elder_trial");
    
    // Проверяем, что мини-игра активирована
    assert_equal(global.ui_elements.mini_game_active, true, "Тест 5.3: Мини-игра должна стать активной после show_mini_game()");
    assert_equal(global.ui_elements.mini_game_type, "elder_trial", "Тест 5.4: Тип мини-игры должен быть установлен");
    
    // Скрываем мини-игру
    scr_ui_manager.hide_mini_game();
    
    // Проверяем, что мини-игра деактивирована
    assert_equal(global.ui_elements.mini_game_active, false, "Тест 5.5: Мини-игра должна быть неактивной после hide_mini_game()");
    assert_equal(string_length(global.ui_elements.mini_game_type), 0, "Тест 5.6: Тип мини-игры должен быть очищен");
    
    show_debug_message("Тест 5 пройден: Работа с мини-играми");
}

// Тест 6: Завершение мини-игры и обновление прогресса
function test_complete_mini_game() {
    // Инициализируем состояние игры для тестирования
    if (!variable_instance_exists(global, "game_state")) {
        global.game_state = scr_game_state.create_new_game_state();
    }
    
    // Сохраняем начальные значения
    var initial_gold = global.game_state.gold;
    var initial_elder_status = global.game_state.elder_trial_completed;
    
    // Завершаем испытание старосты
    scr_ui_manager.complete_mini_game("elder_trial");
    
    // Проверяем, что награда начислена
    assert_equal(global.game_state.gold, initial_gold + 50, "Тест 6.1: Должно быть начислено 50 золота за испытание старосты");
    assert_true(global.game_state.elder_trial_completed, "Тест 6.2: Статус испытания старосты должен быть обновлен");
    
    // Сбрасываем значения для следующего теста
    global.game_state = scr_game_state.create_new_game_state();
    
    // Тестируем калибровку механика
    scr_ui_manager.complete_mini_game("mechanic_calibration");
    
    // Проверяем награду за калибровку
    assert_equal(global.game_state.gold, 30, "Тест 6.3: Должно быть начислено 30 золота за калибровку механика");
    assert_true(global.game_state.mechanic_training_completed, "Тест 6.4: Статус калибровки механика должен быть обновлен");
    assert_true(ds_list_size(global.game_state.items) > 0, "Тест 6.5: Должен быть добавлен предмет за калибровку");
    
    // Сбрасываем значения для следующего теста
    global.game_state = scr_game_state.create_new_game_state();
    
    // Тестируем викторину архивариуса
    scr_ui_manager.complete_mini_game("archivist_quiz");
    
    // Проверяем награду за викторину
    assert_equal(global.game_state.gold, 40, "Тест 6.6: Должно быть начислено 40 золота за викторину архивариуса");
    assert_true(global.game_state.archivist_quiz_completed, "Тест 6.7: Статус викторины архивариуса должен быть обновлен");
    assert_true(ds_list_size(global.game_state.items) > 0, "Тест 6.8: Должен быть добавлен предмет за викторину");
    
    show_debug_message("Тест 6 пройден: Завершение мини-игры и обновление прогресса");
}

// Вспомогательные функции для тестирования
function assert_true(value, message) {
    if (!value) {
        show_debug_message("ОШИБКА: " + message);
        debug_abort();
    }
}

function assert_false(value, message) {
    if (value) {
        show_debug_message("ОШИБКА: " + message);
        debug_abort();
    }
}

function assert_equal(actual, expected, message) {
    if (actual != expected) {
        show_debug_message("ОШИБКА: " + message + " (ожидалось: " + string(expected) + ", получено: " + string(actual) + ")");
        debug_abort();
    }
}

function assert_not_equal(actual, expected, message) {
    if (actual == expected) {
        show_debug_message("ОШИБКА: " + message);
        debug_abort();
    }
}

// Функция запуска всех тестов
function run_all_tests() {
    test_initialize_ui_manager();
    test_hud_visibility();
    test_dialog_windows();
    test_npc_dialogs();
    test_mini_games();
    test_complete_mini_game();
    
    show_debug_message("Все тесты для scr_ui_manager пройдены успешно!");
}