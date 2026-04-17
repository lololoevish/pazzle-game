// Сценарии тестирования для scr_game_state

// Тест 1: Создание нового состояния игры
function test_create_new_game_state() {
    var state = create_new_game_state();
    
    // Проверяем начальные значения
    assert_equal(state.current_state, "MENU", "Тест 1.1: Начальное состояние должно быть MENU");
    assert_equal(state.current_level, 1, "Тест 1.2: Начальный уровень должен быть 1");
    
    // Проверяем прогресс уровней (расширено до 12)
    var i;
    for (i = 1; i <= 12; i++) {
        var completed_key = "level_" + string(i) + "_completed";
        var lever_key = "level_" + string(i) + "_lever_pulled";
        var unlocked_key = "level_" + string(i) + "_unlocked";
        
        assert_false(ds_map_find_value(state.progress, completed_key), 
                     "Тест 1.3: Уровень " + string(i) + " не должен быть завершен при старте");
        assert_false(ds_map_find_value(state.progress, lever_key), 
                     "Тест 1.4: Рычаг уровня " + string(i) + " не должен быть опущен при старте");
        
        // Только первый уровень разблокирован изначально
        if (i == 1) {
            assert_true(ds_map_find_value(state.progress, unlocked_key), 
                       "Тест 1.5: Уровень 1 должен быть разблокирован при старте");
        } else {
            assert_false(ds_map_find_value(state.progress, unlocked_key), 
                        "Тест 1.6: Уровень " + string(i) + " не должен быть разблокирован при старте");
        }
    }
    
    // Проверяем награды NPC
    assert_false(state.elder_trial_completed, "Тест 1.7: Испытание старосты не должно быть завершено при старте");
    assert_false(state.mechanic_training_completed, "Тест 1.8: Калибровка механика не должна быть завершена при старте");
    assert_false(state.archivist_quiz_completed, "Тест 1.9: Викторина архивариуса не должна быть завершена при старте");
    
    // Проверяем начальное количество золота
    assert_equal(state.gold, 0, "Тест 1.10: Начальное количество золота должно быть 0");
    
    // Проверяем новое поле interlevel_transition_enabled
    assert_true(state.interlevel_transition_enabled, "Тест 1.11: Переходы между уровнями должны быть включены при старте");
    
    show_debug_message("Тест 1 пройден: Создание нового состояния игры");
}

// Тест 2: Установка и проверка завершения уровня
function test_level_completion() {
    var state = create_new_game_state();
    
    // Проверяем, что уровень не завершен изначально
    assert_false(is_level_completed(state, 1), 
                 "Тест 2.1: Уровень 1 не должен быть завершен до установки");
    
    // Устанавливаем завершение уровня
    set_level_completed(state, 1);
    
    // Проверяем, что уровень теперь завершен
    assert_true(is_level_completed(state, 1), 
                "Тест 2.2: Уровень 1 должен быть завершен после установки");
    
    // Проверяем, что другие уровни не затронуты
    assert_false(is_level_completed(state, 2), 
                 "Тест 2.3: Уровень 2 не должен быть завершен после установки уровня 1");
    
    // Проверяем уровень 12
    assert_false(is_level_completed(state, 12), 
                 "Тест 2.4: Уровень 12 не должен быть завершен после установки уровня 1");
    
    show_debug_message("Тест 2 пройден: Установка и проверка завершения уровня");
}

// Тест 3: Установка и проверка опускания рычага
function test_lever_pulling() {
    var state = create_new_game_state();
    
    // Проверяем, что рычаг не опущен изначально
    assert_false(is_lever_pulled(state, 1), 
                 "Тест 3.1: Рычаг уровня 1 не должен быть опущен до установки");
    
    // Устанавливаем опускание рычага
    set_lever_pulled(state, 1);
    
    // Проверяем, что рычаг теперь опущен
    assert_true(is_lever_pulled(state, 1), 
                "Тест 3.2: Рычаг уровня 1 должен быть опущен после установки");
    
    // Проверяем, что другие уровни не затронуты
    assert_false(is_lever_pulled(state, 2), 
                 "Тест 3.3: Рычаг уровня 2 не должен быть опущен после установки уровня 1");
    
    assert_false(is_lever_pulled(state, 12), 
                 "Тест 3.4: Рычаг уровня 12 не должен быть опущен после установки уровня 1");
    
    show_debug_message("Тест 3 пройден: Установка и проверка опускания рычага");
}

// Тест 4: Проверка разблокировки следующей пещеры
function test_next_cave_unlocked() {
    var state = create_new_game_state();
    
    // Проверяем, что следующая пещера не разблокирована без опущенного рычага
    assert_false(is_next_cave_unlocked(state, 1), 
                 "Тест 4.1: Следующая пещера не должна быть разблокирована без опущенного рычага");
    
    // Опускаем рычаг первого уровня
    set_lever_pulled(state, 1);
    
    // Проверяем, что теперь вторая пещера разблокирована
    assert_true(is_next_cave_unlocked(state, 1), 
                "Тест 4.2: Вторая пещера должна быть разблокирована после опускания рычага первого уровня");
    
    // Проверяем, что это не влияет на другие уровни
    assert_false(is_next_cave_unlocked(state, 2), 
                 "Тест 4.3: Третья пещера не должна быть разблокирована после опускания рычага первого уровня");
    
    show_debug_message("Тест 4 пройден: Проверка разблокировки следующей пещеры");
}

// Тест 5: Проверка завершения экспедиции (обновлено для 12 уровней)
function test_expedition_completion() {
    var state = create_new_game_state();
    
    // Проверяем, что экспедиция не завершена изначально
    assert_false(is_expedition_completed(state), 
                 "Тест 5.1: Экспедиция не должна быть завершена при старте");
    
    // Опускаем рычаги в первых 5 уровнях
    var i;
    for (i = 1; i <= 5; i++) {
        set_lever_pulled(state, i);
    }
    
    // Проверяем, что экспедиция все еще не завершена (старая логика для 6 уровней)
    assert_false(is_expedition_completed(state), 
                 "Тест 5.2: Экспедиция не должна быть завершена после 5 уровней");
    
    // Опускаем рычаг шестого уровня
    set_lever_pulled(state, 6);
    
    // Проверяем, что теперь экспедиция завершена (по старой логике)
    assert_true(is_expedition_completed(state), 
                "Тест 5.3: Экспедиция должна быть завершена после опускания рычага шестого уровня");
    
    show_debug_message("Тест 5 пройден: Проверка завершения экспедиции");
}

// Тест 6: Проверка статуса уровня
function test_level_status() {
    var state = create_new_game_state();
    
    // Проверяем статус первого уровня (должен быть доступен)
    assert_equal(get_level_status(state, 1), "available", 
                 "Тест 6.1: Уровень 1 должен быть доступен при старте");
    
    // Проверяем статус второго уровня (должен быть заблокирован)
    assert_equal(get_level_status(state, 2), "locked", 
                 "Тест 6.2: Уровень 2 должен быть заблокирован при старте");
    
    // Завершаем первый уровень
    set_level_completed(state, 1);
    assert_equal(get_level_status(state, 1), "completed", 
                 "Тест 6.3: Уровень 1 должен иметь статус completed после завершения");
    
    // Опускаем рычаг первого уровня
    set_lever_pulled(state, 1);
    assert_equal(get_level_status(state, 1), "completed", 
                 "Тест 6.4: Уровень 1 должен оставаться completed после опускания рычага");
    
    show_debug_message("Тест 6 пройден: Проверка статуса уровня");
}

// Тест 7: Проверка общего прогресса
function test_overall_progress() {
    var state = create_new_game_state();
    
    var progress = get_overall_progress(state);
    
    // Проверяем начальный прогресс
    assert_equal(progress.opened, 1, "Тест 7.1: Должен быть открыт 1 уровень при старте");
    assert_equal(progress.completed, 0, "Тест 7.2: Не должно быть завершенных уровней при старте");
    assert_false(progress.expedition_complete, "Тест 7.3: Экспедиция не должна быть завершена при старте");
    
    // Завершаем и открываем несколько уровней
    set_level_completed(state, 1);
    set_lever_pulled(state, 1);
    set_level_completed(state, 2);
    set_lever_pulled(state, 2);
    
    progress = get_overall_progress(state);
    assert_equal(progress.opened, 3, "Тест 7.4: Должно быть открыто 3 уровня после опускания 2 рычагов");
    assert_equal(progress.completed, 2, "Тест 7.5: Должно быть завершено 2 уровня");
    
    show_debug_message("Тест 7 пройден: Проверка общего прогресса");
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
    show_debug_message("=== Запуск тестов scr_game_state ===");
    
    test_create_new_game_state();
    test_level_completion();
    test_lever_pulling();
    test_next_cave_unlocked();
    test_expedition_completion();
    test_level_status();
    test_overall_progress();
    
    show_debug_message("=== Все тесты для scr_game_state пройдены успешно! ===");
}