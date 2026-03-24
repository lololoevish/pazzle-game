// Скрипт головоломки "Поиск пар/Память" для GameMaker

// Функция инициализации головоломки
function init() {
    // Размер сетки (4x4 = 8 пар)
    var grid_size = 4;
    var num_pairs = (grid_size * grid_size) / 2;
    
    // Создаем символы для пар
    symbols = ["🍎", "🍌", "🍇", "🍊", "🍓", "🍒", "🍑", "🥝"]; // 8 разных символов
    
    // Создаем сетку карточек
    card_grid = array_create(grid_size * grid_size);
    revealed_cards = array_create(grid_size * grid_size);
    matched_cards = array_create(grid_size * grid_size);
    
    // Информация о текущем выборе
    first_selected = -1;
    second_selected = -1;
    waiting_second = false;
    
    // Генерируем сетку
    generate_grid(grid_size);
    
    // Состояние завершения
    solved = false;
    
    return {
        grid: card_grid,
        revealed: revealed_cards,
        matched: matched_cards,
        size: grid_size,
        pairs: num_pairs
    };
}

// Функция генерации сетки карточек
function generate_grid(size) {
    // Создаем список всех символов (по 2 каждого)
    var all_symbols = [];
    var i;
    for (i = 0; i < array_length_1d(symbols); i++) {
        array_push(all_symbols, symbols[i]);
        array_push(all_symbols, symbols[i]);
    }
    
    // Перемешиваем символы
    shuffle_array(all_symbols);
    
    // Заполняем сетку
    for (i = 0; i < size * size; i++) {
        card_grid[i] = all_symbols[i];
        revealed_cards[i] = false;
        matched_cards[i] = false;
    }
}

// Функция перемешивания массива
function shuffle_array(arr) {
    var i;
    for (i = array_length_1d(arr) - 1; i > 0; i--) {
        var j = irandom_range(0, i);
        var temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
}

// Функция обновления логики головоломки
function update() {
    if (!solved) {
        // Обработка щелчков мыши
        if (mouse_check_button_pressed(mb_left)) {
            var clicked_card = get_card_at_position(mouse_x, mouse_y);
            if (clicked_card != -1) {
                handle_card_click(clicked_card);
            }
        }
    }
}

// Функция получения индекса карточки по позиции мыши
function get_card_at_position(mx, my) {
    var grid_size = 4;
    var card_size = 80;
    var spacing = 10;
    var total_size = grid_size * card_size + (grid_size - 1) * spacing;
    var start_x = (room_width - total_size) / 2;
    var start_y = (room_height - total_size) / 2;
    
    var col = floor((mx - start_x) / (card_size + spacing));
    var row = floor((my - start_y) / (card_size + spacing));
    
    if (col >= 0 && col < grid_size && row >= 0 && row < grid_size) {
        var index = row * grid_size + col;
        
        // Проверяем, не открыта ли карта уже и не совпадает ли
        if (!revealed_cards[index] && !matched_cards[index]) {
            return index;
        }
    }
    
    return -1;
}

// Функция обработки клика по карточке
function handle_card_click(card_index) {
    if (waiting_second) {
        // Это второй выбор
        second_selected = card_index;
        revealed_cards[second_selected] = true;
        
        // Проверяем совпадение
        if (card_grid[first_selected] == card_grid[second_selected]) {
            // Совпадение найдено
            matched_cards[first_selected] = true;
            matched_cards[second_selected] = true;
            
            // Воспроизводим звук успеха
            scr_audio_manager.play_sfx("puzzle_success");
            
            // Проверяем, все ли пары найдены
            check_completion();
        } else {
            // Несовпадение - воспроизводим звук ошибки
            scr_audio_manager.play_sfx("cancel");
        }
        
        // Убираем выбор через задержку
        alarm[0] = 30; // 0.5 секунды
        waiting_second = false;
    } else {
        // Это первый выбор
        first_selected = card_index;
        revealed_cards[first_selected] = true;
        
        // Воспроизводим звук выбора
        scr_audio_manager.play_sfx("interaction");
        
        waiting_second = true;
    }
}

// Функция проверки завершения головоломки
function check_completion() {
    var grid_size = 4;
    var all_matched = true;
    var i;
    for (i = 0; i < grid_size * grid_size; i++) {
        if (!matched_cards[i]) {
            all_matched = false;
            break;
        }
    }
    
    if (all_matched) {
        solve_puzzle();
    }
}

// Функция сброса выбора после ошибки
function reset_selection() {
    // Скрываем неподходящие карточки
    if (card_grid[first_selected] != card_grid[second_selected]) {
        revealed_cards[first_selected] = false;
        revealed_cards[second_selected] = false;
    }
    
    // Сбрасываем переменные выбора
    first_selected = -1;
    second_selected = -1;
}

// Функция отрисовки головоломки
function draw(gui_view = false) {
    if (!gui_view) {
        var grid_size = 4;
        var card_size = 80;
        var spacing = 10;
        var total_size = grid_size * card_size + (grid_size - 1) * spacing;
        var start_x = (room_width - total_size) / 2;
        var start_y = (room_height - total_size) / 2;
        
        // Рисуем сетку карточек
        var i, j;
        for (j = 0; j < grid_size; j++) {
            for (i = 0; i < grid_size; i++) {
                var index = j * grid_size + i;
                var x_pos = start_x + i * (card_size + spacing);
                var y_pos = start_y + j * (card_size + spacing);
                
                if (matched_cards[index]) {
                    // Совпавшие карточки - зеленая рамка
                    draw_set_color(c_green);
                    draw_rectangle(x_pos, y_pos, x_pos + card_size, y_pos + card_size, false);
                } else if (revealed_cards[index] && !matched_cards[index]) {
                    // Открытые карточки - показываем символ
                    draw_set_color(c_white);
                    draw_rectangle(x_pos, y_pos, x_pos + card_size, y_pos + card_size, true);
                    draw_set_color(c_black);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_text(x_pos + card_size/2, y_pos + card_size/2, card_grid[index]);
                    
                    // Обводка
                    draw_set_color(c_black);
                    draw_rectangle(x_pos, y_pos, x_pos + card_size, y_pos + card_size, false);
                } else {
                    // Закрытые карточки
                    draw_set_color(c_blue);
                    draw_rectangle(x_pos, y_pos, x_pos + card_size, y_pos + card_size, true);
                    
                    // Обводка
                    draw_set_color(c_white);
                    draw_rectangle(x_pos, y_pos, x_pos + card_size, y_pos + card_size, false);
                    
                    // Рисуем вопросительный знак
                    draw_set_color(c_white);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_text(x_pos + card_size/2, y_pos + card_size/2, "?");
                }
            }
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
    scr_audio_manager.play_sfx("puzzle_completed");
}

// Функция сброса головоломки
function reset() {
    var puzzle_data = init();
    solved = false;
    
    return puzzle_data;
}