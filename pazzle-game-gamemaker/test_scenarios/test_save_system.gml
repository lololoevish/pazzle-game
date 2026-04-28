// Сценарии тестирования для scr_save_system

var TEST_SAVE_LEVEL_COUNT = 12;

// Тест 1: Сохранение и загрузка игры через глобальные переменные
function test_save_and_load() {
    // Инициализируем глобальные переменные
    if (!variable_global_exists("initialized")) {
        init_global_vars();
    }
    
    // Изменяем глобальное состояние для проверки сохранения
    global.game_state = "town";
    global.game_progress.gold = 150;
    
    // Отмечаем несколько уровней как завершенные
    complete_level(1);
    complete_level(2);
    
    // Опускаем рычаги
    set_level_lever_pulled(1, true);
    
    // Устанавливаем награды NPC
    global.game_progress.elder_trial_completed = true;
    
    // Сохраняем игру
    save_game();
    
    // Сбрасываем глобальные переменные
    global.game_progress.gold = 0;
    global.game_progress.levels[0].completed = false;
    global.game_progress.elder_trial_completed = false;
    
    // Загружаем игру
    var load_success = load_game();
    
    // Проверяем соответствие данных
    assert_true(load_success, "Тест 1.1: Загрузка должна быть успешной");
    assert_equal(global.game_state, "town", "Тест 1.2: Состояние должно сохраняться");
    assert_equal(global.game_progress.gold, 150, "Тест 1.3: Золото должно сохраняться");
    assert_true(global.game_progress.levels[0].completed, "Тест 1.4: Завершение уровня 1 должно сохраняться");
    assert_true(global.game_progress.levels[1].completed, "Тест 1.5: Завершение уровня 2 должно сохраняться");
    assert_true(global.game_progress.levels[0].lever_pulled, "Тест 1.6: Рычаг уровня 1 должен сохраняться");
    assert_true(global.game_progress.elder_trial_completed, "Тест 1.7: Награда за испытание старосты должна сохраняться");
    
    show_debug_message("Тест 1 пройден: Сохранение и загрузка игры");
}

// Тест 2: Сброс игры
function test_reset_game() {
    // Инициализируем и изменяем глобальное состояние
    if (!variable_global_exists("initialized")) {
        init_global_vars();
    }
    
    global.game_progress.gold = 200;
    complete_level(3);
    save_game();
    
    // Сбрасываем игру
    reset_game();
    
    // Проверяем, что это новое состояние
    assert_equal(global.game_state, "menu", "Тест 2.1: Состояние новой игры должно быть menu");
    assert_equal(global.game_progress.gold, 100, "Тест 2.2: Золото новой игры должно быть 100 (начальное значение)");
    assert_false(global.game_progress.levels[0].completed, "Тест 2.3: Уровень 1 не должен быть завершен в новой игре");
    assert_false(global.game_progress.levels[0].lever_pulled, "Тест 2.4: Рычаг уровня 1 не должен быть опущен в новой игре");
    assert_false(global.game_progress.elder_trial_completed, "Тест 2.5: Награды NPC не должны быть активны в новой игре");
    assert_false(global.expedition_complete, "Тест 2.6: Экспедиция не должна быть завершена в новой игре");

    var i;
    for (i = 0; i < TEST_SAVE_LEVEL_COUNT; i++) {
        assert_false(global.game_progress.levels[i].completed, "Тест 2.7: Уровень " + string(i + 1) + " не должен быть завершен после reset");
        assert_false(global.game_progress.levels[i].lever_pulled, "Тест 2.8: Рычаг уровня " + string(i + 1) + " не должен быть опущен после reset");
    }
    
    show_debug_message("Тест 2 пройден: Сброс игры");
}

// Тест 3: Загрузка несуществующего сохранения
function test_load_nonexistent_save() {
    // Удаляем файлы сохранения если они существуют
    if (file_exists("adventure_puzzle_save.sav")) {
        file_delete("adventure_puzzle_save.sav");
    }
    if (file_exists("adventure_puzzle_save.ini")) {
        file_delete("adventure_puzzle_save.ini");
    }
    
    // Инициализируем глобальные переменные
    if (!variable_global_exists("initialized")) {
        init_global_vars();
    }
    
    // Загружаем игру - должна инициализироваться начальными значениями
    var load_success = load_game();
    
    // Проверяем, что загрузка вернула false (нет сохранения)
    assert_false(load_success, "Тест 3.1: При отсутствии сохранения load_game должна вернуть false");
    assert_equal(global.game_state, "menu", "Тест 3.2: Состояние должно быть menu");
    assert_equal(global.game_progress.gold, 100, "Тест 3.3: Золото должно быть 100 (начальное значение)");
    
    show_debug_message("Тест 3 пройден: Загрузка несуществующего сохранения");
}

// Тест 4: Проверка корректности формата сохранения
function test_save_format_correctness() {
    // Инициализируем глобальные переменные
    if (!variable_global_exists("initialized")) {
        init_global_vars();
    }
    
    // Устанавливаем различные значения
    global.game_progress.gold = 999;
    global.game_progress.elder_trial_completed = true;
    global.game_progress.mechanic_training_completed = false;
    set_level_lever_pulled(5, true);
    complete_level(4);
    
    // Сохраняем
    save_game();
    
    // Сбрасываем значения
    global.game_progress.gold = 0;
    global.game_progress.elder_trial_completed = false;
    global.game_progress.levels[4].lever_pulled = false;
    global.game_progress.levels[3].completed = false;
    
    // Загружаем
    var load_success = load_game();
    
    // Проверяем, что все значения сохранены правильно
    assert_true(load_success, "Тест 4.1: Загрузка должна быть успешной");
    assert_equal(global.game_progress.gold, 999, "Тест 4.2: Большое значение золота должно сохраняться");
    assert_true(global.game_progress.elder_trial_completed, "Тест 4.3: true-значения должны сохраняться");
    assert_false(global.game_progress.mechanic_training_completed, "Тест 4.4: false-значения должны сохраняться");
    assert_true(global.game_progress.levels[4].lever_pulled, "Тест 4.5: опускание рычага должно сохраняться");
    assert_true(global.game_progress.levels[3].completed, "Тест 4.6: завершение уровня должно сохраняться");
    
    show_debug_message("Тест 4 пройден: Проверка корректности формата сохранения");
}

// Тест 5: Проверка функции has_save
function test_has_save() {
    // Удаляем файлы сохранения
    if (file_exists("adventure_puzzle_save.sav")) {
        file_delete("adventure_puzzle_save.sav");
    }
    if (file_exists("adventure_puzzle_save.ini")) {
        file_delete("adventure_puzzle_save.ini");
    }
    
    // Проверяем, что сохранения нет
    assert_false(has_save(), "Тест 5.1: has_save должна вернуть false при отсутствии файлов");
    
    // Инициализируем и сохраняем
    if (!variable_global_exists("initialized")) {
        init_global_vars();
    }
    save_game();
    
    // Проверяем, что сохранение есть
    assert_true(has_save(), "Тест 5.2: has_save должна вернуть true после сохранения");
    
    show_debug_message("Тест 5 пройден: Проверка функции has_save");
}

// Тест 6: Расширение старого сохранения до 12 уровней
function test_legacy_save_expansion() {
    if (!variable_global_exists("initialized")) {
        init_global_vars();
    }

    var legacy_save = {
        game_state: "town",
        game_progress: {
            levels: [
                {completed: true, lever_pulled: true},
                {completed: false, lever_pulled: false}
            ],
            gold: 77,
            items: ["legacy_item"],
            mechanic_training_completed: false,
            archivist_quiz_completed: true,
            elder_trial_completed: false
        },
        expedition_complete: false
    };

    var file = file_text_open_write("adventure_puzzle_save.sav");
    file_text_write_string(file, json_stringify(legacy_save));
    file_text_close(file);

    var load_success = load_game();

    assert_true(load_success, "Тест 6.1: legacy-сохранение должно загружаться");
    assert_equal(array_length(global.game_progress.levels), TEST_SAVE_LEVEL_COUNT, "Тест 6.2: массив уровней должен быть расширен до 12");
    assert_true(global.game_progress.levels[0].completed, "Тест 6.3: данные ранних уровней должны сохраниться");
    assert_false(global.game_progress.levels[11].completed, "Тест 6.4: отсутствующие поздние уровни должны инициализироваться как false");
    assert_equal(global.game_progress.gold, 77, "Тест 6.5: остальной прогресс должен восстанавливаться");

    show_debug_message("Тест 6 пройден: Проверка расширения legacy-сохранения");
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
    show_debug_message("=== Запуск тестов scr_save_system ===");
    
    test_save_and_load();
    test_reset_game();
    test_load_nonexistent_save();
    test_save_format_correctness();
    test_has_save();
    test_legacy_save_expansion();
    
    show_debug_message("=== Все тесты для scr_save_system пройдены успешно! ===");
}
