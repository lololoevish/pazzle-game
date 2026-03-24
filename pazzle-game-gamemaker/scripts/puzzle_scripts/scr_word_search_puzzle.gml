// Скрипт головоломки "Поиск слов" для GameMaker

// Функция инициализации головоломки
function init() {
    // Размер сетки (10x10 как в Rust-версии)
    var width = 10;
    var height = 10;
    
    // Создаем сетку букв
    letter_grid = array_create(width * height);
    
    // Слова для поиска (русские слова как в Rust-версии)
    words_to_find = [
        "ЛАБИРИНТ",
        "ПАЗЗЛ",
        "ПЕЩЕРА",
        "ГОРОД"
    ];
    
    found_words = [];
    
    // Генерируем сетку
    generate_grid(width, height);
    
    // Состояние выбора букв
    selected_letters = [];
    selected_positions = [];
    
    // Координаты начального и конечного нажатия для выбора слова
    drag_start_x = -1;
    drag_start_y = -1;
    drag_end_x = -1;
    drag_end_y = -1;
    
    // Состояние завершения
    solved = false;
    
    return {
        grid: letter_grid,
        width: width,
        height: height,
        words: words_to_find,
        found_words: found_words
    };
}

// Функция генерации сетки букв
function generate_grid(width, height) {
    // Заполняем сетку случайными буквами
    var x, y;
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            letter_grid[y * width + x] = get_random_letter();
        }
    }
    
    // Вставляем слова в сетку
    var word;
    for (word in words_to_find) {
        place_word(word, width, height);
    }
}

// Функция получения случайной буквы
function get_random_letter() {
    var letters = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ";
    return string_char_at(letters, irandom_range(1, string_length(letters)));
}

// Функция размещения слова в сетке
function place_word(word, width, height) {
    var placed = false;
    var attempts = 0;
    var max_attempts = 50;
    
    while (!placed && attempts < max_attempts) {
        attempts++;
        
        // Выбираем случайное направление: горизонталь, вертикаль, диагональ
        var direction = irandom_range(0, 3); // 0-горизонталь, 1-вертикаль, 2-диагональ вправо вниз, 3-диагональ вправо вверх
        
        // Выбираем начальную позицию
        var start_x, start_y;
        var word_len = string_length(word);
        
        switch (direction) {
            case 0: // Горизонталь
                start_x = irandom_range(0, width - word_len);
                start_y = irandom_range(0, height - 1);
                break;
            case 1: // Вертикаль
                start_x = irandom_range(0, width - 1);
                start_y = irandom_range(0, height - word_len);
                break;
            case 2: // Диагональ вправо вниз
                start_x = irandom_range(0, width - word_len);
                start_y = irandom_range(0, height - word_len);
                break;
            case 3: // Диагональ вправо вверх
                start_x = irandom_range(0, width - word_len);
                start_y = irandom_range(word_len - 1, height - 1);
                break;
        }
        
        // Проверяем, можно ли разместить слово
        if (can_place_word(word, start_x, start_y, direction, width, height)) {
            // Размещаем слово
            var i;
            for (i = 0; i < word_len; i++) {
                var pos_x, pos_y;
                switch (direction) {
                    case 0: pos_x = start_x + i; pos_y = start_y; break;
                    case 1: pos_x = start_x; pos_y = start_y + i; break;
                    case 2: pos_x = start_x + i; pos_y = start_y + i; break;
                    case 3: pos_x = start_x + i; pos_y = start_y - i; break;
                }
                
                letter_grid[pos_y * width + pos_x] = string_char_at(word, i + 1);
            }
            
            placed = true;
        }
    }
}

// Функция проверки, можно ли разместить слово
function can_place_word(word, start_x, start_y, direction, width, height) {
    var word_len = string_length(word);
    var i;
    
    for (i = 0; i < word_len; i++) {
        var pos_x, pos_y;
        switch (direction) {
            case 0: pos_x = start_x + i; pos_y = start_y; break;
            case 1: pos_x = start_x; pos_y = start_y + i; break;
            case 2: pos_x = start_x + i; pos_y = start_y + i; break;
            case 3: pos_x = start_x + i; pos_y = start_y - i; break;
        }
        
        // Проверяем, не выходит ли за границы
        if (pos_x < 0 || pos_x >= width || pos_y < 0 || pos_y >= height) {
            return false;
        }
        
        // Проверяем, пустая ли ячейка или совпадает с буквой слова
        var current_char = letter_grid[pos_y * width + pos_x];
        var target_char = string_char_at(word, i + 1);
        
        if (current_char != ' ' && current_char != target_char) {
            return false;
        }
    }
    
    return true;
}

// Функция обновления логики головоломки
function update() {
    if (!solved) {
        // Обработка мыши для выбора слов
        handle_mouse_input();
    }
}

// Функция обработки мышиного ввода
function handle_mouse_input() {
    var mouse_cell_size = 32;
    var grid_width = 10;
    var grid_height = 10;
    var offset_x = (room_width - grid_width * mouse_cell_size) / 2;
    var offset_y = (room_height - grid_height * mouse_cell_size) / 2;
    
    // Проверяем нажатие мыши
    if (mouse_check_button_pressed(mb_left)) {
        var mouse_grid_x = floor((mouse_x - offset_x) / mouse_cell_size);
        var mouse_grid_y = floor((mouse_y - offset_y) / mouse_cell_size);
        
        if (mouse_grid_x >= 0 && mouse_grid_x < grid_width && 
            mouse_grid_y >= 0 && mouse_grid_y < grid_height) {
            drag_start_x = mouse_grid_x;
            drag_start_y = mouse_grid_y;
        }
    }
    
    // Проверяем отпускание мыши
    if (mouse_check_button_released(mb_left) && drag_start_x != -1) {
        var mouse_grid_x = floor((mouse_x - offset_x) / mouse_cell_size);
        var mouse_grid_y = floor((mouse_y - offset_y) / mouse_cell_size);
        
        if (mouse_grid_x >= 0 && mouse_grid_x < grid_width && 
            mouse_grid_y >= 0 && mouse_grid_y < grid_height) {
            drag_end_x = mouse_grid_x;
            drag_end_y = mouse_grid_y;
            
            // Проверяем слово
            check_word(drag_start_x, drag_start_y, drag_end_x, drag_end_y);
        }
        
        // Сбрасываем координаты
        drag_start_x = -1;
        drag_end_x = -1;
    }
}

// Функция проверки слова
function check_word(start_x, start_y, end_x, end_y) {
    // Проверяем, что выбор происходит по прямой линии (горизонталь, вертикаль или диагональ)
    if (start_x != end_x && start_y != end_y && abs(start_x - end_x) != abs(start_y - end_y)) {
        return; // Не по прямой
    }
    
    // Получаем буквы в выбранном диапазоне
    var letters = "";
    var step_x, step_y;
    
    if (start_x == end_x) {
        step_x = 0;
        step_y = (end_y > start_y) ? 1 : -1;
    } else if (start_y == end_y) {
        step_x = (end_x > start_x) ? 1 : -1;
        step_y = 0;
    } else {
        step_x = (end_x > start_x) ? 1 : -1;
        step_y = (end_y > start_y) ? 1 : -1;
    }
    
    var x = start_x;
    var y = start_y;
    var width = 10;
    
    while (true) {
        letters += letter_grid[y * width + x];
        
        if (x == end_x && y == end_y) break;
        
        x += step_x;
        y += step_y;
    }
    
    // Проверяем, есть ли это слово в списке
    var word_found = false;
    var target_word;
    for (target_word in words_to_find) {
        if (string_upper(letters) == target_word || string_lower(letters) == string_lower(target_word)) {
            // Проверяем, не было ли уже найдено это слово
            if (!array_contains(found_words, target_word)) {
                array_push(found_words, target_word);
                word_found = true;
                
                // Воспроизводим звук успеха
                scr_audio_manager.play_sfx("puzzle_success");
                
                break;
            }
        }
    }
    
    // Проверяем, найдены ли все слова
    if (array_length_1d(found_words) == array_length_1d(words_to_find)) {
        solve_puzzle();
    }
}

// Функция отрисовки головоломки
function draw(gui_view = false) {
    if (!gui_view) {
        var width = 10;
        var height = 10;
        var cell_size = 32;
        var offset_x = (room_width - width * cell_size) / 2;
        var offset_y = (room_height - height * cell_size) / 2;
        
        // Рисуем сетку
        var x, y;
        for (y = 0; y < height; y++) {
            for (x = 0; x < width; x++) {
                var screen_x = offset_x + x * cell_size;
                var screen_y = offset_y + y * cell_size;
                
                // Фон ячейки
                if (array_contains(selected_positions, [x, y])) {
                    draw_set_color(c_lightblue);
                } else {
                    draw_set_color(c_white);
                }
                
                draw_rectangle(screen_x, screen_y, screen_x + cell_size, screen_y + cell_size, true);
                
                // Граница ячейки
                draw_set_color(c_black);
                draw_rectangle(screen_x, screen_y, screen_x + cell_size, screen_y + cell_size, false);
                
                // Буква
                draw_set_color(c_black);
                var text = letter_grid[y * width + x];
                var text_x = screen_x + cell_size / 2 - string_width(text) / 2;
                var text_y = screen_y + cell_size / 2 - string_height(text) / 2;
                draw_text(text_x, text_y, text);
            }
        }
        
        // Рисуем список слов для поиска
        draw_set_color(c_black);
        var list_offset_x = offset_x + width * cell_size + 20;
        var list_offset_y = offset_y;
        var line_height = 20;
        
        draw_text(list_offset_x, list_offset_y, "Слова для поиска:");
        
        var word_idx;
        for (word_idx = 0; word_idx < array_length_1d(words_to_find); word_idx++) {
            if (array_contains(found_words, words_to_find[word_idx])) {
                draw_set_color(c_green);
            } else {
                draw_set_color(c_black);
            }
            
            draw_text(list_offset_x, list_offset_y + (word_idx + 1) * line_height, words_to_find[word_idx]);
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

// Вспомогательная функция для проверки, содержит ли массив элемент
function array_contains(arr, element) {
    if (typeof(element) == typeof("")) {
        var i;
        for (i = 0; i < array_length_1d(arr); i++) {
            if (arr[i] == element) {
                return true;
            }
        }
        return false;
    } else {
        // Для массивов
        var i;
        for (i = 0; i < array_length_1d(arr); i++) {
            if (variable_struct_names_count(arr[i]) > 0) {
                // Это структура, проверяем поля
                if (arr[i][0] == element[0] && arr[i][1] == element[1]) {
                    return true;
                }
            } else {
                // Это массив
                if (arr[i][0] == element[0] && arr[i][1] == element[1]) {
                    return true;
                }
            }
        }
        return false;
    }
}