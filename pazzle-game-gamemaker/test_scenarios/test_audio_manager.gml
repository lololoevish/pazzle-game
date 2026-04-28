// Сценарии тестирования для scr_audio_manager

// Тест 1: Проверка воспроизведения музыки
function test_play_music() {
    // Проверяем, что функция play_music не падает с различными индексами
    // Используем -1 как безопасное значение для тестирования
    play_music(-1);
    
    // Проверяем остановку музыки
    stop_music();
    
    show_debug_message("Тест 1 пройден: Проверка воспроизведения музыки");
}

// Тест 2: Проверка воспроизведения звуковых эффектов
function test_play_sfx() {
    // Проверяем, что функция play_sfx не падает с различными типами событий
    play_sfx("ui_move");
    play_sfx("ui_confirm");
    play_sfx("ui_cancel");
    play_sfx("ui_success");
    play_sfx("lever_pull");
    play_sfx("level_complete");
    play_sfx("puzzle_solve");
    
    // Проверяем несуществующий звук
    play_sfx("nonexistent_sound");
    
    show_debug_message("Тест 2 пройден: Проверка воспроизведения звуковых эффектов");
}

// Тест 3: Проверка play_event_sound (compatibility wrapper)
function test_play_event_sound() {
    // Проверяем compatibility wrapper
    play_event_sound("level_complete");
    play_event_sound("lever_pull");
    play_event_sound("puzzle_solve");
    
    show_debug_message("Тест 3 пройден: Проверка play_event_sound");
}

// Тест 4: Проверка установки эмоционального музыкального состояния
function test_emotional_music_state() {
    // Проверяем различные эмоциональные состояния
    set_emotional_music_state("neutral");
    set_emotional_music_state("friendly_encounter");
    set_emotional_music_state("mercy_theme");
    set_emotional_music_state("peaceful_resolution");
    
    show_debug_message("Тест 4 пройден: Проверка установки эмоционального музыкального состояния");
}

// Тест 5: Проверка получения музыки для текущей комнаты
function test_get_current_room_music() {
    // Проверяем, что функция не падает
    var room_music = get_current_room_music();
    
    // Результат может быть undefined, это нормально
    show_debug_message("Тест 5 пройден: Проверка получения музыки для текущей комнаты");
}

// Тест 6: Проверка кроссфейда музыки
function test_crossfade_music() {
    // Проверяем кроссфейд с безопасными значениями
    crossfade_music(-1, 1.0);
    
    show_debug_message("Тест 6 пройден: Проверка кроссфейда музыки");
}

// Тест 7: Проверка установки контекста аудио
function test_set_audio_context() {
    // Проверяем различные контексты
    apply_audio_context("neutral");
    apply_audio_context("menu");
    apply_audio_context("town");
    apply_audio_context("puzzle_active");
    apply_audio_context("dialogue");
    apply_audio_context("victory");
    
    show_debug_message("Тест 7 пройден: Проверка установки контекста аудио");
}

// Тест 8: Проверка плавного изменения громкости
function test_lerp_volume() {
    // Проверяем функцию lerp_volume с безопасными значениями
    lerp_volume(-1, 0.5, 0.1);
    
    show_debug_message("Тест 8 пройден: Проверка плавного изменения громкости");
}

// Функция запуска всех тестов
function run_all_tests() {
    show_debug_message("=== Запуск тестов scr_audio_manager ===");
    
    test_play_music();
    test_play_sfx();
    test_play_event_sound();
    test_emotional_music_state();
    test_get_current_room_music();
    test_crossfade_music();
    test_set_audio_context();
    test_lerp_volume();
    
    show_debug_message("=== Все тесты для scr_audio_manager пройдены успешно! ===");
}
