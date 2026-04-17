// Скрипт головоломки "Запоминалка" для GameMaker
// Уровень 10: Усложненная память с визуальными паттернами

function memory_advanced_puzzle_init() {
    global.memory_adv_grid_size = 5; // 5x5 сетка
    global.memory_adv_grid = [];
    global.memory_adv_revealed = [];
    global.memory_adv_pattern_to_remember = [];
    global.memory_adv_player_pattern = [];
    global.memory_adv_current_stage = 0;
    global.memory_adv_max_stages = 4;
    global.memory_adv_showing_pattern = false;
    global.memory_adv_show_timer = 0;
    global.memory_adv_pattern_length = 3; // Начальная длина паттерна
    global.memory_adv_solved = false;
    global.memory_adv_cell_size = 60;
    global.memory_adv_grid_offset_x = 200;
    global.memory_adv_grid_offset_y = 150;
    
    // Инициализация сетки
    for (var i = 0; i < global.memory_adv_grid_size; i++) {
        global.memory_adv_grid[i] = [];
        global.memory_adv_revealed[i] = [];
        for (var j = 0; j < global.memory_adv_grid_size; j++) {
            global.memory_adv_grid[i][j] = irandom(3); // 4 типа символов
            global.memory_adv_revealed[i][j] = false;
        }
    }
    
    // Генерация паттерна для запоминания
    memory_adv_generate_pattern();
    
    return { stage: global.memory_adv_current_stage, max_stages: global.memory_adv_max_stages };
}

function memory_adv_generate_pattern() {
    global.memory_adv_pattern_to_remember = [];
    var pattern_len = global.memory_adv_pattern_length + global.memory_adv_current_stage;
    
    for (var i = 0; i < pattern_len; i++) {
        var cell = {
            row: irandom(global.memory_adv_grid_size - 1),
            col: irandom(global.memory_adv_grid_size - 1)
        };
        array_push(global.memory_adv_pattern_to_remember, cell);
    }
    
    global.memory_adv_showing_pattern = true;
    global.memory_adv_show_timer = 180; // 3 секунды на запоминание
    global.memory_adv_player_pattern = [];
}

function memory_advanced_puzzle_update() {
    if (global.memory_adv_solved) {
        return;
    }
    
    if (global.memory_adv_showing_pattern) {
        global.memory_adv_show_timer--;
        if (global.memory_adv_show_timer <= 0) {
            global.memory_adv_showing_pattern = false;
        }
        return;
    }
    
    // Обработка кликов мыши
    if (mouse_check_button_pressed(mb_left)) {
        var mouse_grid_x = floor((mouse_x - global.memory_adv_grid_offset_x) / global.memory_adv_cell_size);
        var mouse_grid_y = floor((mouse_y - global.memory_adv_grid_offset_y) / global.memory_adv_cell_size);
        
        if (mouse_grid_x >= 0 && mouse_grid_x < global.memory_adv_grid_size &&
            mouse_grid_y >= 0 && mouse_grid_y < global.memory_adv_grid_size) {
            
            memory_adv_handle_cell_click(mouse_grid_y, mouse_grid_x);
        }
    }
}

function memory_adv_handle_cell_click(row, col) {
    // Добавляем выбранную ячейку в паттерн игрока
    var cell = { row: row, col: col };
    array_push(global.memory_adv_player_pattern, cell);
    
    if (script_exists(play_event_sound)) {
        play_event_sound("select");
    }
    
    // Проверяем правильность выбора
    var current_index = array_length(global.memory_adv_player_pattern) - 1;
    var expected_cell = global.memory_adv_pattern_to_remember[current_index];
    
    if (cell.row != expected_cell.row || cell.col != expected_cell.col) {
        // Ошибка
        if (script_exists(play_event_sound)) {
            play_event_sound("cancel");
        }
        memory_adv_reset_stage();
        return;
    }
    
    // Проверяем, завершен ли паттерн
    if (array_length(global.memory_adv_player_pattern) == array_length(global.memory_adv_pattern_to_remember)) {
        // Паттерн правильно воспроизведен
        global.memory_adv_current_stage++;
        
        if (script_exists(play_event_sound)) {
            play_event_sound("puzzle_success");
        }
        
        if (global.memory_adv_current_stage >= global.memory_adv_max_stages) {
            // Все этапы пройдены
            memory_advanced_puzzle_solve();
        } else {
            // Переход к следующему этапу
            memory_adv_generate_pattern();
        }
    }
}

function memory_adv_reset_stage() {
    global.memory_adv_player_pattern = [];
    global.memory_adv_showing_pattern = true;
    global.memory_adv_show_timer = 180;
}

function memory_advanced_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }
    
    draw_set_color(c_white);
    draw_text(50, 50, "Запоминалка - Этап " + string(global.memory_adv_current_stage + 1) + "/" + string(global.memory_adv_max_stages));
    
    if (global.memory_adv_showing_pattern) {
        draw_text(50, 80, "Запомните последовательность! Осталось: " + string(floor(global.memory_adv_show_timer / 60)) + " сек");
    } else {
        draw_text(50, 80, "Повторите последовательность кликами");
        draw_text(50, 100, "Прогресс: " + string(array_length(global.memory_adv_player_pattern)) + "/" + string(array_length(global.memory_adv_pattern_to_remember)));
    }
    
    // Рисование сетки
    for (var i = 0; i < global.memory_adv_grid_size; i++) {
        for (var j = 0; j < global.memory_adv_grid_size; j++) {
            var cell_x = global.memory_adv_grid_offset_x + j * global.memory_adv_cell_size;
            var cell_y = global.memory_adv_grid_offset_y + i * global.memory_adv_cell_size;
            
            // Определяем, нужно ли подсвечивать ячейку
            var is_in_pattern = false;
            var pattern_index = -1;
            
            if (global.memory_adv_showing_pattern) {
                // Показываем паттерн
                for (var k = 0; k < array_length(global.memory_adv_pattern_to_remember); k++) {
                    var pattern_cell = global.memory_adv_pattern_to_remember[k];
                    if (pattern_cell.row == i && pattern_cell.col == j) {
                        is_in_pattern = true;
                        pattern_index = k;
                        break;
                    }
                }
            } else {
                // Показываем выбранные игроком ячейки
                for (var k = 0; k < array_length(global.memory_adv_player_pattern); k++) {
                    var player_cell = global.memory_adv_player_pattern[k];
                    if (player_cell.row == i && player_cell.col == j) {
                        is_in_pattern = true;
                        pattern_index = k;
                        break;
                    }
                }
            }
            
            // Цвет ячейки
            if (is_in_pattern) {
                if (global.memory_adv_showing_pattern) {
                    draw_set_color(c_yellow);
                } else {
                    draw_set_color(c_lime);
                }
            } else {
                draw_set_color(c_dkgray);
            }
            
            draw_rectangle(cell_x, cell_y, cell_x + global.memory_adv_cell_size - 2, 
                          cell_y + global.memory_adv_cell_size - 2, false);
            
            // Рамка
            draw_set_color(c_white);
            draw_rectangle(cell_x, cell_y, cell_x + global.memory_adv_cell_size - 2, 
                          cell_y + global.memory_adv_cell_size - 2, true);
            
            // Номер в паттерне
            if (is_in_pattern && pattern_index >= 0) {
                draw_set_color(c_black);
                draw_text(cell_x + 20, cell_y + 20, string(pattern_index + 1));
            }
        }
    }
}

function memory_advanced_puzzle_is_solved() {
    return global.memory_adv_solved;
}

function memory_advanced_puzzle_solve() {
    global.memory_adv_solved = true;
    if (script_exists(play_event_sound)) {
        play_event_sound("puzzle_completed");
    }
}

function memory_advanced_puzzle_reset() {
    return memory_advanced_puzzle_init();
}
