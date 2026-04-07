// Скрипт головоломки "Ритм/Паттерн" для GameMaker

// Функция инициализации головоломки
function init() {
    // Количество кнопок/элементов в паттерне
    num_buttons = 4;
    
    // Доступные цвета для кнопок
    button_colors = [c_red, c_green, c_blue, c_yellow];
    
    // Текущая последовательность
    sequence = [];
    
    // Ответ игрока
    player_sequence = [];
    
    // Раунд
    round = 1;
    
    // Максимальная длина последовательности
    max_round = 8;
    
    // Состояния
    showing_pattern = false;
    waiting_input = false;
    pattern_show_time = 0;
    input_timeout = 0;
    
    // Создаем последовательность для первого раунда
    generate_sequence(round);
    
    // Состояние завершения
    solved = false;
    
    return {
        num_buttons: num_buttons,
        sequence: sequence,
        round: round,
        max_round: max_round,
        showing_pattern: showing_pattern,
        waiting_input: waiting_input
    };
}

// Функция генерации последовательности
function generate_sequence(round_num) {
    sequence = [];
    var i;
    for (i = 0; i < round_num; i++) {
        array_push(sequence, irandom_range(0, num_buttons - 1));
    }
}

// Функция обновления логики головоломки
function update() {
    if (!solved) {
        if (showing_pattern) {
            // Отображение паттерна
            pattern_show_time--;
            if (pattern_show_time <= 0) {
                showing_pattern = false;
                waiting_input = true;
                player_sequence = [];
            }
        } else if (waiting_input) {
            // Ожидание ввода игрока
            input_timeout--;
            if (input_timeout <= 0) {
                // Тайм-аут ввода
                reset_round();
            } else {
                // Обработка ввода игрока (например, нажатие клавиш 1-4)
                handle_player_input();
            }
        } else {
            // Отображение паттерна
            show_pattern();
        }
    }
}

// Функция отображения паттерна
function show_pattern() {
    showing_pattern = true;
    pattern_show_time = 30 * array_length_1d(sequence); // 30 тиков на элемент
    waiting_input = false;
    
    // Воспроизводим звук начала паттерна
    play_sfx("puzzle_success");
}

// Функция обработки ввода игрока
function handle_player_input() {
    var button_pressed = -1;
    
    // Проверяем нажатия клавиш 1-4
    if (keyboard_check_pressed(vk_1) || keyboard_check_pressed(ord('Q'))) {
        button_pressed = 0;
    } else if (keyboard_check_pressed(vk_2) || keyboard_check_pressed(ord('W'))) {
        button_pressed = 1;
    } else if (keyboard_check_pressed(vk_3) || keyboard_check_pressed(ord('E'))) {
        button_pressed = 2;
    } else if (keyboard_check_pressed(vk_4) || keyboard_check_pressed(ord('R'))) {
        button_pressed = 3;
    }
    
    if (button_pressed != -1) {
        // Добавляем нажатие в последовательность игрока
        array_push(player_sequence, button_pressed);
        
        // Воспроизводим звук нажатия
        play_sfx("interaction");
        
        // Проверяем, совпадает ли с правильной последовательностью
        var current_position = array_length_1d(player_sequence) - 1;
        if (player_sequence[current_position] != sequence[current_position]) {
            // Ошибка
            play_sfx("cancel");
            reset_round();
        } else if (array_length_1d(player_sequence) == array_length_1d(sequence)) {
            // Правильный ввод завершен
            if (round >= max_round) {
                // Головоломка решена
                solve_puzzle();
            } else {
                // Переход к следующему раунду
                next_round();
            }
        }
    }
}

// Функция сброса раунда
function reset_round() {
    player_sequence = [];
    input_timeout = 120; // 2 секунды на ввод
}

// Функция перехода к следующему раунду
function next_round() {
    round++;
    generate_sequence(round);
    reset_round();
}

// Функция отрисовки головоломки
function draw(gui_view = false) {
    if (!gui_view) {
        var button_size = 80;
        var spacing = 20;
        var total_width = num_buttons * button_size + (num_buttons - 1) * spacing;
        var start_x = (room_width - total_width) / 2;
        var y_pos = room_height / 2 - 50;
        
        // Рисуем кнопки
        var i;
        for (i = 0; i < num_buttons; i++) {
            var x_pos = start_x + i * (button_size + spacing);
            
            // Если паттерн отображается и это текущая кнопка в последовательности
            var is_active = false;
            if (showing_pattern) {
                var step_time = 30; // время на один элемент
                var current_step = floor((30 * array_length_1d(sequence) - pattern_show_time) / step_time);
                
                if (current_step < array_length_1d(sequence) && sequence[current_step] == i) {
                    is_active = true;
                }
            }
            
            if (is_active) {
                draw_set_color(button_colors[i]);
            } else {
                draw_set_color(make_color_rgb(
                    color_get_red(button_colors[i]) * 0.5,
                    color_get_green(button_colors[i]) * 0.5,
                    color_get_blue(button_colors[i]) * 0.5
                ));
            }
            
            draw_set_alpha(is_active ? 1.0 : 0.7);
            draw_rectangle(x_pos, y_pos, x_pos + button_size, y_pos + button_size, true);
            
            draw_set_color(c_white);
            draw_set_alpha(1.0);
            draw_rectangle(x_pos, y_pos, x_pos + button_size, y_pos + button_size, false);
            
            // Рисуем номер кнопки
            draw_set_color(c_white);
            draw_text(x_pos + button_size/2 - 5, y_pos + button_size/2 - 7, string(i + 1));
        }
        
        // Отображаем текущий раунд
        draw_set_color(c_white);
        draw_text(room_width / 2 - 50, y_pos - 30, "Раунд: " + string(round) + "/" + string(max_round));
        
        // Если ожидаем ввод, показываем подсказку
        if (waiting_input) {
            draw_set_color(c_yellow);
            draw_text(room_width / 2 - 100, y_pos + button_size + 20, "Повторите последовательность (клавиши 1-4)");
        } else if (showing_pattern) {
            draw_set_color(c_gray);
            draw_text(room_width / 2 - 80, y_pos + button_size + 20, "Смотрите внимательно...");
        }
    }
}

// Функция проверки завершения головоломки
function is_solved() {
    return solved;
}

// Функция завершения головоломки
function solve_puzzle() {
    solved = true;
    
    // Воспроизводим звук успеха
    play_sfx("puzzle_completed");
}

// Функция сброса головоломки
function reset() {
    round = 1;
    generate_sequence(round);
    reset_round();
    solved = false;
    
    return init();
}
