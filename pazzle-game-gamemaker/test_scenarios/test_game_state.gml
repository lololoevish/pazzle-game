// Сценарии тестирования для scr_game_state

// Тест 1: Создание нового состояния игры
function test_create_new_game_state() {
    var state = scr_game_state.create_new_game_state();
    
    // Проверяем начальные значения
    assert_equal(state.current_state, "MENU", "Тест 1.1: Начальное состояние должно быть MENU");
    assert_equal(state.current_level, 1, "Тест 1.2: Начальный уровень должен быть 1");
    
    // Проверяем прогресс уровней
    var i;
    for (i = 1; i <= 6; i++) {
        var completed_key = "level_" + string(i) + "_completed";
        var lever_key = "level_" + string(i) + "_lever_pulled";
        
        assert_false(ds_map_find_value(state.progress, completed_key), 
                     "Тест 1.3: Уровень " + string(i) + " не должен быть завершен при старте");
        assert_false(ds_map_find_value(state.progress, lever_key), 
                     "Тест 1.4: Рычаг уровня " + string(i) + " не должен быть опущен при старте");
    }
    
    // Проверяем награды NPC
    assert_false(state.elder_trial_completed, "Тест 1.5: Испытание старосты не должно быть завершено при старте");
    assert_false(state.mechanic_training_completed, "Тест 1.6: Калибровка механика не должна быть завершена при старте");
    assert_false(state.archivist_quiz_completed, "Тест 1.7: Викторина архивариуса не должна быть завершена при старте");
    
    // Проверяем начальное количество золота
    assert_equal(state.gold, 0, "Тест 1.8: Начальное количество золота должно быть 0");
    
    show_debug_message("Тест 1 пройден: Создание нового состояния игры");
}

// Тест 2: Установка и проверка завершения уровня
function test_level_completion() {
    var state = scr_game_state.create_new_game_state();
    
    // Проверяем, что уровень не завершен изначально
    assert_false(scr_game_state.is_level_completed(state, 1), 
                 "Тест 2.1: Уровень 1 не должен быть завершен до установки");
    
    // Устанавливаем завершение уровня
    scr_game_state.set_level_completed(state, 1);
    
    // Проверяем, что уровень теперь завершен
    assert_true(scr_game_state.is_level_completed(state, 1), 
                "Тест 2.2: Уровень 1 должен быть завершен после установки");
    
    // Проверяем, что другие уровни не затронуты
    assert_false(scr_game_state.is_level_completed(state, 2), 
                 "Тест 2.3: Уровень 2 не должен быть завершен после установки уровня 1");
    
    show_debug_message("Тест 2 пройден: Установка и проверка завершения уровня");
}

// Тест 3: Установка и проверка опускания рычага
function test_lever_pulling() {
    var state = scr_game_state.create_new_game_state();
    
    // Проверяем, что рычаг не опущен изначально
    assert_false(scr_game_state.is_lever_pulled(state, 1), 
                 "Тест 3.1: Рычаг уровня 1 не должен быть опущен до установки");
    
    // Устанавливаем опускание рычага
    scr_game_state.set_lever_pulled(state, 1);
    
    // Проверяем, что рычаг теперь опущен
    assert_true(scr_game_state.is_lever_pulled(state, 1), 
                "Тест 3.2: Рычаг уровня 1 должен быть опущен после установки");
    
    // Проверяем, что другие уровни не затронуты
    assert_false(scr_game_state.is_lever_pulled(state, 2), 
                 "Тест 3.3: Рычаг уровня 2 не должен быть опущен после установки уровня 1");
    
    show_debug_message("Тест 3 пройден: Установка и проверка опускания рычага");
}

// Тест 4: Проверка разблокировки следующей пещеры
function test_next_cave_unlocked() {
    var state = scr_game_state.create_new_game_state();
    
    // Проверяем, что следующая пещера не разблокирована без опущенного рычага
    assert_false(scr_game_state.is_next_cave_unlocked(state, 1), 
                 "Тест 4.1: Следующая пещера не должна быть разблокирована без опущенного рычага");
    
    // Опускаем рычаг первого уровня
    scr_game_state.set_lever_pulled(state, 1);
    
    // Проверяем, что теперь вторая пещера разблокирована
    assert_true(scr_game_state.is_next_cave_unlocked(state, 1), 
                "Тест 4.2: Вторая пещера должна быть разблокирована после опускания рычага первого уровня");
    
    // Проверяем, что это не влияет на другие уровни
    assert_false(scr_game_state.is_next_cave_unlocked(state, 2), 
                 "Тест 4.3: Третья пещера не должна быть разблокирована после опускания рычага первого уровня");
    
    show_debug_message("Тест 4 пройден: Проверка разблокировки следующей пещеры");
}

// Тест 5: Проверка завершения экспедиции
function test_expedition_completion() {
    var state = scr_game_state.create_new_game_state();
    
    // Проверяем, что экспедиция не завершена изначально
    assert_false(scr_game_state.is_expedition_completed(state), 
                 "Тест 5.1: Экспедиция не должна быть завершена при старте");
    
    // Опускаем рычаги в первых 5 уровнях
    var i;
    for (i = 1; i <= 5; i++) {
        scr_game_state.set_lever_pulled(state, i);
    }
    
    // Проверяем, что экспедиция все еще не завершена
    assert_false(scr_game_state.is_expedition_completed(state), 
                 "Тест 5.2: Экспедиция не должна быть завершена после 5 уровней");
    
    // Опускаем рычаг шестого уровня
    scr_game_state.set_lever_pulled(state, 6);
    
    // Проверяем, что теперь экспедиция завершена
    assert_true(scr_game_state.is_expedition_completed(state), 
                "Тест 5.3: Экспедиция должна быть завершена после опускания рычага шестого уровня");
    
    show_debug_message("Тест 5 пройден: Проверка завершения экспедиции");
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
    test_create_new_game_state();
    test_level_completion();
    test_lever_pulling();
    test_next_cave_unlocked();
    test_expedition_completion();
    
    show_debug_message("Все тесты для scr_game_state пройдены успешно!");
}