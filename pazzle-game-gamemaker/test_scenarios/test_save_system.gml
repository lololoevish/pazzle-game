// Сценарии тестирования для scr_save_system

// Тест 1: Сохранение и загрузка игры
function test_save_and_load() {
    // Создаем игровое состояние с данными
    var original_state = scr_game_state.create_new_game_state();
    
    // Изменяем состояние, чтобы проверить сохранение
    original_state.current_state = "PLAYING";
    original_state.current_level = 3;
    original_state.gold = 150;
    
    // Отмечаем несколько уровней как завершенные
    scr_game_state.set_level_completed(original_state, 1);
    scr_game_state.set_level_completed(original_state, 2);
    
    // Опускаем рычаги
    scr_game_state.set_lever_pulled(original_state, 1);
    
    // Устанавливаем награды NPC
    original_state.elder_trial_completed = true;
    
    // Сохраняем игру
    scr_save_system.save_game(original_state);
    
    // Загружаем игру
    var loaded_state = scr_save_system.load_game();
    
    // Проверяем соответствие данных
    assert_equal(loaded_state.current_state, "PLAYING", "Тест 1.1: Состояние должно сохраняться");
    assert_equal(loaded_state.current_level, 3, "Тест 1.2: Уровень должен сохраняться");
    assert_equal(loaded_state.gold, 150, "Тест 1.3: Золото должно сохраняться");
    assert_true(scr_game_state.is_level_completed(loaded_state, 1), "Тест 1.4: Завершение уровня 1 должно сохраняться");
    assert_true(scr_game_state.is_level_completed(loaded_state, 2), "Тест 1.5: Завершение уровня 2 должно сохраняться");
    assert_true(scr_game_state.is_lever_pulled(loaded_state, 1), "Тест 1.6: Рычаг уровня 1 должен сохраняться");
    assert_true(loaded_state.elder_trial_completed, "Тест 1.7: Награда за испытание старосты должна сохраняться");
    
    show_debug_message("Тест 1 пройден: Сохранение и загрузка игры");
}

// Тест 2: Сброс игры
function test_reset_game() {
    // Сохраняем игру с некоторыми изменениями
    var modified_state = scr_game_state.create_new_game_state();
    modified_state.current_level = 4;
    modified_state.gold = 200;
    scr_game_state.set_level_completed(modified_state, 3);
    scr_save_system.save_game(modified_state);
    
    // Создаем новую игру
    var reset_state = scr_save_system.reset_game();
    
    // Проверяем, что это новое состояние
    assert_equal(reset_state.current_state, "MENU", "Тест 2.1: Состояние новой игры должно быть MENU");
    assert_equal(reset_state.current_level, 1, "Тест 2.2: Уровень новой игры должен быть 1");
    assert_equal(reset_state.gold, 0, "Тест 2.3: Золото новой игры должно быть 0");
    assert_false(scr_game_state.is_level_completed(reset_state, 1), "Тест 2.4: Уровень 1 не должен быть завершен в новой игре");
    assert_false(scr_game_state.is_lever_pulled(reset_state, 1), "Тест 2.5: Рычаг уровня 1 не должен быть опущен в новой игре");
    assert_false(reset_state.elder_trial_completed, "Тест 2.6: Награды NPC не должны быть активны в новой игре");
    
    show_debug_message("Тест 2 пройден: Сброс игры");
}

// Тест 3: Загрузка несуществующего сохранения
function test_load_nonexistent_save() {
    // Удаляем файл сохранения если он существует
    if (file_exists("savegame.json")) {
        file_delete("savegame.json");
    }
    
    // Загружаем игру - должна создаться новая
    var state = scr_save_system.load_game();
    
    // Проверяем, что это новое состояние
    assert_equal(state.current_state, "MENU", "Тест 3.1: При отсутствии сохранения должна создаваться новая игра");
    assert_equal(state.current_level, 1, "Тест 3.2: Новый уровень должен быть 1");
    assert_equal(state.gold, 0, "Тест 3.3: Новое золото должно быть 0");
    
    show_debug_message("Тест 3 пройден: Загрузка несуществующего сохранения");
}

// Тест 4: Проверка корректности формата сохранения
function test_save_format_correctness() {
    // Создаем состояние с различными типами данных
    var state = scr_game_state.create_new_game_state();
    
    // Устанавливаем различные значения
    state.gold = 999;
    state.elder_trial_completed = true;
    state.mechanic_training_completed = false;
    scr_game_state.set_lever_pulled(state, 5);
    scr_game_state.set_level_completed(state, 4);
    
    // Сохраняем
    scr_save_system.save_game(state);
    
    // Загружаем
    var loaded_state = scr_save_system.load_game();
    
    // Проверяем, что все значения сохранены правильно
    assert_equal(loaded_state.gold, 999, "Тест 4.1: Большое значение золота должно сохраняться");
    assert_true(loaded_state.elder_trial_completed, "Тест 4.2: true-значения должны сохраняться");
    assert_false(loaded_state.mechanic_training_completed, "Тест 4.3: false-значения должны сохраняться");
    assert_true(scr_game_state.is_lever_pulled(loaded_state, 5), "Тест 4.4: опускание рычага должно сохраняться");
    assert_true(scr_game_state.is_level_completed(loaded_state, 4), "Тест 4.5: завершение уровня должно сохраняться");
    
    show_debug_message("Тест 4 пройден: Проверка корректности формата сохранения");
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

// Функция запуска всех тестов
function run_all_tests() {
    test_save_and_load();
    test_reset_game();
    test_load_nonexistent_save();
    test_save_format_correctness();
    
    show_debug_message("Все тесты для scr_save_system пройдены успешно!");
}