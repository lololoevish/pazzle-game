// Скрипт головоломки "Песнь Пещер" для GameMaker
// Уровень 11: Усложненный ритм-пазл с музыкальными паттернами

function cave_song_puzzle_init() {
    global.cave_song_sequence = [];
    global.cave_song_player_sequence = [];
    global.cave_song_current_round = 0;
    global.cave_song_max_rounds = 6;
    global.cave_song_notes = ["C", "D", "E", "F", "G", "A", "B"]; // 7 нот
    global.cave_song_note_colors = [c_red, c_orange, c_yellow, c_green, c_aqua, c_blue, c_purple];
    global.cave_song_showing_sequence = false;
    global.cave_song_show_timer = 0;
    global.cave_song_current_note_index = 0;
    global.cave_song_waiting_for_input = false;
    global.cave_song_input_timeout = 300; // 5 секунд на ввод
    global.cave_song_solved = false;
    global.cave_song_note_display_time = 30; // 0.5 секунды на ноту
    global.cave_song_pause_between_notes = 15; // 0.25 секунды пауза
    
    // Генерация начальной последовательности
    cave_song_generate_sequence();
    
    return { round: global.cave_song_current_round, max_rounds: global.cave_song_max_rounds };
}

function cave_song_generate_sequence() {
    global.cave_song_sequence = [];
    var sequence_length = 3 + global.cave_song_current_round; // Длина увеличивается с раундом
    
    for (var i = 0; i < sequence_length; i++) {
        var random_note = irandom(array_length(global.cave_song_notes) - 1);
        array_push(global.cave_song_sequence, random_note);
    }
    
    global.cave_song_showing_sequence = true;
    global.cave_song_current_note_index = 0;
    global.cave_song_show_timer = global.cave_song_note_display_time;
    global.cave_song_player_sequence = [];
}

function cave_song_puzzle_update() {
    if (global.cave_song_solved) {
        return;
    }
    
    if (global.cave_song_showing_sequence) {
        global.cave_song_show_timer--;
        
        if (global.cave_song_show_timer <= 0) {
            global.cave_song_current_note_index++;
            
            if (global.cave_song_current_note_index >= array_length(global.cave_song_sequence)) {
                // Закончили показ последовательности
                global.cave_song_showing_sequence = false;
                global.cave_song_waiting_for_input = true;
                global.cave_song_input_timeout = 300;
                global.cave_song_player_sequence = [];
            } else {
                // Показываем следующую ноту
                global.cave_song_show_timer = global.cave_song_note_display_time + global.cave_song_pause_between_notes;
                
                // Воспроизводим звук ноты
                if (script_exists(play_event_sound)) {
                    play_event_sound("select");
                }
            }
        }
        return;
    }
    
    if (global.cave_song_waiting_for_input) {
        global.cave_song_input_timeout--;
        
        if (global.cave_song_input_timeout <= 0) {
            // Время истекло
            if (script_exists(play_event_sound)) {
                play_event_sound("cancel");
            }
            cave_song_reset_round();
            return;
        }
        
        // Обработка ввода клавиш 1-7 для нот
        for (var i = 0; i < array_length(global.cave_song_notes); i++) {
            if (keyboard_check_pressed(ord('1') + i)) {
                cave_song_handle_note_input(i);
                break;
            }
        }
    }
}

function cave_song_handle_note_input(note_index) {
    array_push(global.cave_song_player_sequence, note_index);
    
    // Воспроизводим звук
    if (script_exists(play_event_sound)) {
        play_event_sound("select");
    }
    
    // Проверяем правильность ввода
    var current_position = array_length(global.cave_song_player_sequence) - 1;
    
    if (global.cave_song_player_sequence[current_position] != global.cave_song_sequence[current_position]) {
        // Ошибка
        if (script_exists(play_event_sound)) {
            play_event_sound("cancel");
        }
        cave_song_reset_round();
        return;
    }
    
    // Проверяем, завершена ли последовательность
    if (array_length(global.cave_song_player_sequence) == array_length(global.cave_song_sequence)) {
        // Правильно воспроизведено
        global.cave_song_current_round++;
        
        if (script_exists(play_event_sound)) {
            play_event_sound("puzzle_success");
        }
        
        if (global.cave_song_current_round >= global.cave_song_max_rounds) {
            // Все раунды пройдены
            cave_song_puzzle_solve();
        } else {
            // Следующий раунд
            global.cave_song_waiting_for_input = false;
            cave_song_generate_sequence();
        }
    }
}

function cave_song_reset_round() {
    global.cave_song_waiting_for_input = false;
    global.cave_song_showing_sequence = false;
    global.cave_song_player_sequence = [];
    
    // Повторяем текущий раунд
    cave_song_generate_sequence();
}

function cave_song_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }
    
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(room_width / 2, 30, "Песнь Пещер");
    draw_set_halign(fa_left);
    
    draw_text(50, 60, "Раунд: " + string(global.cave_song_current_round + 1) + "/" + string(global.cave_song_max_rounds));
    
    if (global.cave_song_showing_sequence) {
        draw_text(50, 90, "Слушайте и запоминайте мелодию пещер...");
        
        // Показываем текущую ноту
        if (global.cave_song_show_timer > global.cave_song_pause_between_notes) {
            var current_note = global.cave_song_sequence[global.cave_song_current_note_index];
            var note_name = global.cave_song_notes[current_note];
            var note_color = global.cave_song_note_colors[current_note];
            
            draw_set_color(note_color);
            draw_set_halign(fa_center);
            draw_circle(room_width / 2, room_height / 2, 80, false);
            draw_set_color(c_white);
            draw_text(room_width / 2, room_height / 2 - 10, note_name);
            draw_set_halign(fa_left);
        }
        
        // Показываем всю последовательность внизу
        draw_set_color(c_white);
        draw_text(50, 500, "Последовательность:");
        for (var i = 0; i < array_length(global.cave_song_sequence); i++) {
            var note = global.cave_song_sequence[i];
            var note_color = global.cave_song_note_colors[note];
            
            if (i <= global.cave_song_current_note_index) {
                draw_set_color(note_color);
            } else {
                draw_set_color(c_dkgray);
            }
            
            draw_circle(100 + i * 60, 530, 20, false);
            draw_set_color(c_white);
            draw_text(90 + i * 60, 520, global.cave_song_notes[note]);
        }
        
    } else if (global.cave_song_waiting_for_input) {
        draw_text(50, 90, "Повторите мелодию!");
        draw_text(50, 110, "Времени осталось: " + string(floor(global.cave_song_input_timeout / 60)) + " сек");
        
        // Показываем введенную последовательность
        draw_text(50, 140, "Ваша мелодия:");
        for (var i = 0; i < array_length(global.cave_song_player_sequence); i++) {
            var note = global.cave_song_player_sequence[i];
            var note_color = global.cave_song_note_colors[note];
            
            draw_set_color(note_color);
            draw_circle(100 + i * 60, 170, 20, false);
            draw_set_color(c_white);
            draw_text(90 + i * 60, 160, global.cave_song_notes[note]);
        }
        
        // Показываем клавиши управления
        draw_set_color(c_yellow);
        draw_text(50, 250, "Клавиши:");
        for (var i = 0; i < array_length(global.cave_song_notes); i++) {
            var note_color = global.cave_song_note_colors[i];
            draw_set_color(note_color);
            draw_circle(80 + i * 80, 300, 25, false);
            draw_set_color(c_white);
            draw_text(70 + i * 80, 290, string(i + 1));
            draw_text(65 + i * 80, 330, global.cave_song_notes[i]);
        }
    }
}

function cave_song_puzzle_is_solved() {
    return global.cave_song_solved;
}

function cave_song_puzzle_solve() {
    global.cave_song_solved = true;
    if (script_exists(play_event_sound)) {
        play_event_sound("puzzle_completed");
        play_event_sound("friendship_gained");
    }
}

function cave_song_puzzle_reset() {
    return cave_song_puzzle_init();
}
