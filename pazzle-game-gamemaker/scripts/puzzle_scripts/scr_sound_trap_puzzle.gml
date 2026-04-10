// Скрипт головоломки "Звуковые Ловушки" для GameMaker

function sound_trap_puzzle_init() {
    global.sound_trap_sequence = []; // Последовательность звуков
    global.sound_trap_player_sequence = []; // Последовательность игрока
    global.sound_trap_current_stage = 0; // Этап прохождения
    global.sound_trap_max_stages = 5; // Максимальное количество этапов
    global.sound_trap_notes = ["до", "ре", "ми", "фа", "соль", "ля", "си"]; // Звуковые ноты
    global.sound_trap_showing_sequence = false; // Показывается ли последовательность
    global.sound_trap_waiting_for_input = false; // Ожидание ввода
    global.sound_trap_timer = 0; // Таймер
    global.sound_trap_input_timeout = 120; // Таймаут ввода
    global.sound_trap_solved = false; // Решено ли
    
    // Генерация начальной последовательности
    sound_trap_generate_sequence();
    
    return { stage: global.sound_trap_current_stage, max_stages: global.sound_trap_max_stages };
}

function sound_trap_generate_sequence() {
    // Генерация новой последовательности
    global.sound_trap_sequence = [];
    var sequence_length = global.sound_trap_current_stage + 2; // Длина увеличивается с этапом
    
    for (var i = 0; i < sequence_length; i++) {
        var random_note = irandom(array_length(global.sound_trap_notes) - 1);
        array_push(global.sound_trap_sequence, random_note);
    }
}

function sound_trap_puzzle_update() {
    if (global.sound_trap_solved) {
        return;
    }
    
    if (global.sound_trap_showing_sequence) {
        // Отображение последовательности
        global.sound_trap_timer--;
        if (global.sound_trap_timer <= 0) {
            global.sound_trap_showing_sequence = false;
            global.sound_trap_waiting_for_input = true;
            global.sound_trap_player_sequence = [];
            global.sound_trap_input_timeout = 180; // 3 секунды на ввод
        }
        return;
    }
    
    if (global.sound_trap_waiting_for_input) {
        global.sound_trap_input_timeout--;
        if (global.sound_trap_input_timeout <= 0) {
            sound_trap_reset_stage();
            return;
        }
        
        sound_trap_handle_input();
    } else {
        // Начинаем воспроизведение последовательности
        global.sound_trap_showing_sequence = true;
        global.sound_trap_timer = 60; // 1 секунда между нотами * длину последовательности
        sound_trap_play_sequence();
    }
}

function sound_trap_play_sequence() {
    // Воспроизводим каждую ноту в последовательности с задержкой
    for (var i = 0; i < array_length(global.sound_trap_sequence); i++) {
        // Используем таймер для отложенного воспроизведения
        // В реальной реализации использовались бы реальные звуковые ресурсы
        var note_index = global.sound_trap_sequence[i];
        var note_name = global.sound_trap_notes[note_index];
        
        // Воспроизводим звук
        if (script_exists(play_event_sound)) {
            play_event_sound("snd_mercy_action"); // Используем существующий звук
        }
        
        // Здесь нужна задержка, но в реальной реализации это делается через таймер
    }
}

function sound_trap_handle_input() {
    // Обработка нажатий клавиш 1-7 для нот
    for (var i = 0; i < array_length(global.sound_trap_notes); i++) {
        if (keyboard_check_pressed(vk_1 + i)) {
            // Нажата клавиша, соответствующая ноте
            array_push(global.sound_trap_player_sequence, i);
            
            // Воспроизвести звук
            if (script_exists(play_event_sound)) {
                play_event_sound("snd_friendship_gained");
            }
            
            // Проверить совпадение
            var current_position = array_length(global.sound_trap_player_sequence) - 1;
            if (global.sound_trap_player_sequence[current_position] != global.sound_trap_sequence[current_position]) {
                // Ошибка
                if (script_exists(play_event_sound)) {
                    play_event_sound("cancel");
                }
                sound_trap_reset_stage();
                return;
            }
            
            // Проверить, полностью ли введена последовательность
            if (array_length(global.sound_trap_player_sequence) == array_length(global.sound_trap_sequence)) {
                // Правильно введено, переход к следующему этапу
                global.sound_trap_current_stage++;
                
                if (global.sound_trap_current_stage >= global.sound_trap_max_stages) {
                    // Все этапы пройдены
                    sound_trap_puzzle_solve();
                } else {
                    // Новый этап
                    global.sound_trap_waiting_for_input = false;
                    global.sound_trap_showing_sequence = false;
                    sound_trap_generate_sequence();
                }
            }
            break;
        }
    }
}

function sound_trap_reset_stage() {
    global.sound_trap_waiting_for_input = false;
    global.sound_trap_showing_sequence = false;
    global.sound_trap_player_sequence = [];
    global.sound_trap_input_timeout = 180;
    // Остаемся на том же этапе
}

function sound_trap_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }
    
    draw_set_color(c_white);
    
    if (global.sound_trap_showing_sequence) {
        draw_text(50, 100, "Слушайте и запомните последовательность звуков:");
        draw_text(50, 120, "Этап " + string(global.sound_trap_current_stage + 1) + " из " + string(global.sound_trap_max_stages));
    } else if (global.sound_trap_waiting_for_input) {
        draw_text(50, 100, "Повторите последовательность звуков:");
        draw_text(50, 120, "Введите ноты: 1-7");
        draw_text(50, 140, "Осталось времени: " + string(floor(global.sound_trap_input_timeout / 60)) + " сек");
        
        // Отобразить введенную последовательность
        var seq_str = "Ваша последовательность: ";
        for (var i = 0; i < array_length(global.sound_trap_player_sequence); i++) {
            seq_str += global.sound_trap_notes[global.sound_trap_player_sequence[i]];
            if (i < array_length(global.sound_trap_player_sequence) - 1) {
                seq_str += " - ";
            }
        }
        draw_text(50, 160, seq_str);
    } else {
        draw_text(50, 100, "Готовимся к этапу " + string(global.sound_trap_current_stage + 1));
        draw_text(50, 120, "Нажмите любую клавишу для начала");
    }
    
    draw_set_color(c_yellow);
    draw_text(50, 200, "Клавиши: 1='до', 2='ре', 3='ми', 4='фа', 5='соль', 6='ля', 7='си'");
}

function sound_trap_puzzle_is_solved() {
    return global.sound_trap_solved;
}

function sound_trap_puzzle_solve() {
    global.sound_trap_solved = true;
    if (script_exists(play_event_sound)) {
        play_event_sound("puzzle_completed");
    }
}

function sound_trap_puzzle_reset() {
    return sound_trap_puzzle_init();
}