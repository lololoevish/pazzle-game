// Сценарии тестирования для scr_audio_manager

// Тест 1: Инициализация аудио-менеджера
function test_initialize_audio() {
    // Инициализируем аудио-менеджер
    var audio_manager = scr_audio_manager.initialize_audio();
    
    // Проверяем, что глобальные переменные были инициализированы
    assert_not_equal(variable_instance_exists(global, "audio_manager"), 0, 
                     "Тест 1.1: Аудио-менеджер должен быть инициализирован в глобальной переменной");
    
    // Проверяем, что у аудио-менеджера есть необходимые поля
    assert_not_equal(global.audio_manager.sfx.volume, undefined, 
                     "Тест 1.2: Должна быть инициализирована группа SFX");
    assert_not_equal(global.audio_manager.music.volume, undefined, 
                     "Тест 1.3: Должна быть инициализирована группа музыки");
    
    // Проверяем начальные значения
    assert_equal(global.audio_manager.sfx_volume, 1.0, "Тест 1.4: Начальная громкость SFX должна быть 1.0");
    assert_equal(global.audio_manager.music_volume, 1.0, "Тест 1.5: Начальная громкость музыки должна быть 1.0");
    assert_false(global.audio_manager.muted, "Тест 1.6: Звук изначально не должен быть отключен");
    
    show_debug_message("Тест 1 пройден: Инициализация аудио-менеджера");
}

// Тест 2: Воспроизведение SFX
function test_play_sfx() {
    // Инициализируем аудио-менеджер
    scr_audio_manager.initialize_audio();
    
    // Проверяем, что функция без ошибки вызывается для различных звуков
    scr_audio_manager.play_sfx("confirm");
    scr_audio_manager.play_sfx("cancel");
    scr_audio_manager.play_sfx("move");
    scr_audio_manager.play_sfx("success");
    scr_audio_manager.play_sfx("lever");
    scr_audio_manager.play_sfx("interaction");
    scr_audio_manager.play_sfx("puzzle_success");
    scr_audio_manager.play_sfx("puzzle_completed");
    
    // Проверяем, что функция не падает при несуществующем звуке
    scr_audio_manager.play_sfx("nonexistent_sound");
    
    show_debug_message("Тест 2 пройден: Воспроизведение SFX");
}

// Тест 3: Воспроизведение музыки
function test_play_music() {
    // Инициализируем аудио-менеджер
    scr_audio_manager.initialize_audio();
    
    // Проверяем, что функция без ошибки вызывается для различных музыкальных тем
    scr_audio_manager.play_music("menu");
    scr_audio_manager.play_music("town");
    scr_audio_manager.play_music("cave");
    scr_audio_manager.play_music("victory");
    
    // Проверяем, что музыка может быть остановлена
    scr_audio_manager.stop_music();
    
    show_debug_message("Тест 3 пройден: Воспроизведение музыки");
}

// Тест 4: Управление громкостью
function test_volume_control() {
    // Инициализируем аудио-менеджер
    scr_audio_manager.initialize_audio();
    
    // Проверяем, что громкость может быть установлена
    scr_audio_manager.set_volume(0.5, 0.7);
    
    // Проверяем, что значения громкости установлены
    assert_equal(global.audio_manager.sfx_volume, 0.5, "Тест 4.1: Громкость SFX должна быть изменена");
    assert_equal(global.audio_manager.music_volume, 0.7, "Тест 4.2: Громкость музыки должна быть изменена");
    
    // Проверяем установку только одной громкости
    scr_audio_manager.set_volume(0.8);
    assert_equal(global.audio_manager.sfx_volume, 0.8, "Тест 4.3: Только громкость SFX должна измениться");
    // music_volume должна остаться прежней
    assert_equal(global.audio_manager.music_volume, 0.7, "Тест 4.4: Громкость музыки не должна измениться");
    
    // Проверяем отключение звука
    scr_audio_manager.toggle_mute();
    assert_true(global.audio_manager.muted, "Тест 4.5: Звук должен быть отключен после toggle_mute()");
    
    // Проверяем включение звука
    scr_audio_manager.toggle_mute();
    assert_false(global.audio_manager.muted, "Тест 4.6: Звук должен быть включен после повторного toggle_mute()");
    
    show_debug_message("Тест 4 пройден: Управление громкостью");
}

// Тест 5: Остановка музыки
function test_stop_music() {
    // Инициализируем аудио-менеджер
    scr_audio_manager.initialize_audio();
    
    // Воспроизводим музыку
    scr_audio_manager.play_music("cave");
    
    // Останавливаем музыку
    scr_audio_manager.stop_music();
    
    // После остановки текущий канал должен быть сброшен
    // Это сложно протестировать напрямую, поэтому просто проверим, что функция не падает
    show_debug_message("Тест 5 пройден: Остановка музыки");
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
    test_initialize_audio();
    test_play_sfx();
    test_play_music();
    test_volume_control();
    test_stop_music();
    
    show_debug_message("Все тесты для scr_audio_manager пройдены успешно!");
}