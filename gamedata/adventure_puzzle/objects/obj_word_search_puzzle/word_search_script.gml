/*
 * Объект головоломки поиска слов
 * Реализация алгоритма поиска слов из Rust-версии
 */

// Параметры головоломки
var puzzle_config = {
    width: 12,
    height: 12,
    cell_size: 35,
    font_size: 20,
    highlight_color: $FF9900,  // Оранжевый для подсвеченных букв
    found_color: $00AA00,      // Зелёный для найденных слов
    default_color: c_white,    // Белый для обычных букв
    words_to_find: ["МАЗ", "ЛАБИРИНТ", "ГОЛОВОЛОМКА", "ПАЗЗЛ", "ИГРА"]
};

// Состояния головоломки
var puzzle_states = {
    SETUP: "setup",            // Инициализация
    PHASE1_SEARCH: "phase1_search", // Фаза 1 - поиск слов
    PHASE1_FOUND: "phase1_found",  // Фаза 1 - слово найдено
    PHASE2_MEMORY: "phase2_memory", // Фаза 2 - игра на память
    SOLVED: "solved",          // Решена
    INACTIVE: "inactive"       // Неактивна
};

// Глобальные переменные
current_state = puzzle_states.SETUP;
grid = [];                    // Сетка букв
selected_letters = [];        // Выбранные буквы
words_found = [];             // Найденные слова
current_word = [];           // Текущее слово для выделения
click_positions = [];        // Позиции кликов (для выделения)
selecting = false;           // В процессе выделения
start_selection = undefined;  // Начальная позиция выделения
end_selection = undefined;    // Конечная позиция выделения
solved = false;

// Инициализация
function word_search_init(width, height, words) {
    puzzle_config.width = width;
    puzzle_config.height = height;
    
    if (words != undefined) {
        puzzle_config.words_to_find = words;
    }
    
    // Инициализируем сетку
    grid = array_create(height, width);
    
    // Генерируем сетку букв
    generate_letter_grid();
    
    // Располагаем слова
    place_words();
    
    // Установим начальное состояние
    current_state = puzzle_states.PHASE1_SEARCH;
    selected_letters = [];
    words_found = [];
    click_positions = [];
    selecting = false;
    solved = false;
}

// Генерация сетки случайных букв
function generate_letter_grid() {
    var alphabet = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ";
    
    for (var y = 0; y < puzzle_config.height; y++) {
        for (var x = 0; x < puzzle_config.width; x++) {
            var rand_index = irandom(string_length(alphabet) - 1);
            grid[y, x] = string_char_at(alphabet, rand_index + 1);
        }
    }
}

// Размещение слов в сетке
function place_words() {
    for (var i = 0; i < array_length(puzzle_config.words_to_find); i++) {
        var word = puzzle_config.words_to_find[i];
        place_single_word(word);
    }
}

// Размещение одного слова
function place_single_word(word) {
    var placed = false;
    var attempts = 0;
    var max_attempts = 50;
    
    while (!placed && attempts < max_attempts) {
        var direction = irandom(3); // 0-горизонталь, 1-вертикаль, 2-диагональ
        var x, y;
        
        switch (direction) {
            case 0: // Горизонталь
                x = irandom(puzzle_config.width - string_length(word));
                y = irandom(puzzle_config.height - 1);
                
                if (try_place_word_horizontally(word, x, y)) {
                    placed = true;
                }
                break;
                
            case 1: // Вертикаль
                x = irandom(puzzle_config.width - 1);
                y = irandom(puzzle_config.height - string_length(word));
                
                if (try_place_word_vertically(word, x, y)) {
                    placed = true;
                }
                break;
                
            case 2: // Диагональ
                x = irandom(puzzle_config.width - string_length(word));
                y = irandom(puzzle_config.height - string_length(word));
                
                if (try_place_word_diagonally(word, x, y)) {
                    placed = true;
                }
                break;
        }
        
        attempts++;
    }
    
    if (!placed) {
        // Если не удалось разместить, просто записываем в случайное место
        x = irandom(puzzle_config.width - 1);
        y = irandom(puzzle_config.height - 1);
        
        for (var i = 0; i < string_length(word); i++) {
            if (x + i < puzzle_config.width) {
                grid[y, x + i] = string_char_at(word, i + 1);
            }
        }
    }
}

// Попытка размещения слова горизонтально
function try_place_word_horizontally(word, start_x, y) {
    for (var i = 0; i < string_length(word); i++) {
        if (start_x + i >= puzzle_config.width) {
            return false;
        }
        
        // Проверяем, не мешает ли уже существующая буква
        var existing_char = grid[y, start_x + i];
        var new_char = string_char_at(word, i + 1);
        
        if (existing_char != new_char && existing_char != '#') { // '#' будет обозначать пустую ячейку
            return false;
        }
    }
    
    // Размещаем слово
    for (var i = 0; i < string_length(word); i++) {
        grid[y, start_x + i] = string_char_at(word, i + 1);
    }
    
    return true;
}

// Попытка размещения слова вертикально
function try_place_word_vertically(word, x, start_y) {
    for (var i = 0; i < string_length(word); i++) {
        if (start_y + i >= puzzle_config.height) {
            return false;
        }
        
        var existing_char = grid[start_y + i, x];
        var new_char = string_char_at(word, i + 1);
        
        if (existing_char != new_char && existing_char != '#') {
            return false;
        }
    }
    
    for (var i = 0; i < string_length(word); i++) {
        grid[start_y + i, x] = string_char_at(word, i + 1);
    }
    
    return true;
}

// Попытка размещения слова по диагонали
function try_place_word_diagonally(word, start_x, start_y) {
    for (var i = 0; i < string_length(word); i++) {
        if (start_x + i >= puzzle_config.width || start_y + i >= puzzle_config.height) {
            return false;
        }
        
        var existing_char = grid[start_y + i, start_x + i];
        var new_char = string_char_at(word, i + 1);
        
        if (existing_char != new_char && existing_char != '#') {
            return false;
        }
    }
    
    for (var i = 0; i < string_length(word); i++) {
        grid[start_y + i, start_x + i] = string_char_at(word, i + 1);
    }
    
    return true;
}

// Обработка клика мыши
function handle_mouse_click() {
    if (current_state != puzzle_states.PHASE1_SEARCH || solved) {
        return;
    }
    
    var mouse_x = mouse_x;
    var mouse_y = mouse_y;
    
    // Вычисляем смещение для центрирования сетки
    var offset_x = (room_width - (puzzle_config.width * puzzle_config.cell_size)) / 2;
    var offset_y = (room_height - (puzzle_config.height * puzzle_config.cell_size)) / 2 + 50;
    
    // Определяем, на какую ячейку кликнули
    var grid_x = floor((mouse_x - offset_x) / puzzle_config.cell_size);
    var grid_y = floor((mouse_y - offset_y) / puzzle_config.cell_size);
    
    // Проверяем, в пределах ли координаты
    if (grid_x >= 0 && grid_x < puzzle_config.width && 
        grid_y >= 0 && grid_y < puzzle_config.height) {
        
        if (!selecting) {
            // Начинаем выделение
            start_selection = {x: grid_x, y: grid_y};
            end_selection = {x: grid_x, y: grid_y};
            selecting = true;
            click_positions = [{x: grid_x, y: grid_y}];
        } else {
            // Завершаем выделение
            end_selection = {x: grid_y, y: grid_y};
            array_push(click_positions, {x: grid_x, y: grid_y});
            
            // Проверяем, является ли выделение действительным
            if (click_positions[0].x == grid_x && click_positions[0].y == grid_y) {
                // Один клик - обрабатываем как начало нового выделения
                start_selection = {x: grid_x, y: grid_y};
                end_selection = {x: grid_x, y: grid_y};
                click_positions = [{x: grid_x, y: grid_y}];
            } else {
                // Два клика - завершаем выделение
                if (validate_selection()) {
                    var found_word = extract_word();
                    if (check_word(found_word)) {
                        process_found_word(found_word);
                    }
                }
                
                // Сбрасываем выделение
                start_selection = undefined;
                end_selection = undefined;
                click_positions = [];
                selecting = false;
            }
        }
    }
}

// Проверка, что выделение валидно (по прямой линии)
function validate_selection() {
    if (click_positions[0] == undefined || click_positions[1] == undefined) {
        return false;
    }
    
    var start = click_positions[0];
    var end = click_positions[1];
    
    // Проверяем, находится ли линия по горизонтали, вертикали или диагонали
    return (start.x == end.x) ||         // Вертикаль
           (start.y == end.y) ||         // Горизонталь
           (abs(start.x - end.x) == abs(start.y - end.y)); // Диагональ
}

// Извлечение слова из выделенной линии
function extract_word() {
    var start = click_positions[0];
    var end = click_positions[1];
    
    var word = "";
    
    var dx = sign(end.x - start.x);
    var dy = sign(end.y - start.y);
    
    var current_x = start.x;
    var current_y = start.y;
    
    while (true) {
        word += grid[current_y, current_x];
        
        if (current_x == end.x && current_y == end.y) {
            break;
        }
        
        current_x += dx;
        current_y += dy;
    }
    
    return word;
}

// Проверка, является ли слово одним из искомых
function check_word(extracted_word) {
    for (var i = 0; i < array_length(puzzle_config.words_to_find); i++) {
        if (string_upper(extracted_word) == string_upper(puzzle_config.words_to_find[i])) {
            return true;
        }
    }
    return false;
}

// Обработка найденного слова
function process_found_word(found_word) {
    // Проверяем, не найдено ли уже это слово
    for (var i = 0; i < array_length(words_found); i++) {
        if (string_upper(words_found[i]) == string_upper(found_word)) {
            return; // Слово уже найдено
        }
    }
    
    // Добавляем найденное слово в список
    array_push(words_found, found_word);
    
    scr_ui_manager.show_message("Найдено слово: " + found_word);
    scr_audio_manager.play_event_sound("ui_success");
    
    // Проверяем, все ли слова найдены
    check_completion();
}

// Проверка завершения головоломки
function check_completion() {
    if (array_length(words_found) == array_length(puzzle_config.words_to_find)) {
        // Все слова найдены
        solved = true;
        current_state = puzzle_states.PHASE2_MEMORY;
        
        scr_ui_manager.show_message("Все слова найдены! Переход к следующей фазе...");
        scr_audio_manager.play_event_sound("puzzle_solve");
        
        // Через некоторое время переходим к фазе памяти
        // Для простоты пока что просто завершаем
        current_state = puzzle_states.SOLVED;
    }
}

// Обработка ввода
function handle_input() {
    // Обработка клика мыши
    if (mouse_check_button_pressed(mb_left)) {
        handle_mouse_click();
    }
    
    // Обработка клавиатуры
    if (keyboard_check_pressed(vk_escape)) {
        // Выход из головоломки
        current_state = puzzle_states.INACTIVE;
    }
    
    // Обработка других клавиш...
}

// Обновление логики
function update() {
    // В данной головоломке обновление происходит в основном через обработку ввода
}

// Отрисовка сетки
function draw_grid() {
    var offset_x = (room_width - (puzzle_config.width * puzzle_config.cell_size)) / 2;
    var offset_y = (room_height - (puzzle_config.height * puzzle_config.cell_size)) / 2 + 50;
    
    // Рисуем сетку и буквы
    for (var y = 0; y < puzzle_config.height; y++) {
        for (var x = 0; x < puzzle_config.width; x++) {
            var screen_x = offset_x + x * puzzle_config.cell_size;
            var screen_y = offset_y + y * puzzle_config.cell_size;
            
            // Рисуем фон ячейки
            draw_set_color(c_black);
            draw_rectangle(screen_x, screen_y, 
                          screen_x + puzzle_config.cell_size, 
                          screen_y + puzzle_config.cell_size);
            
            // Проверяем, находится ли текущая ячейка в выделенной области
            var highlighted = false;
            var found = false;
            
            if (start_selection != undefined && end_selection != undefined && selecting) {
                // Проверяем, находится ли ячейка на линии между start и end
                highlighted = is_cell_on_line(x, y, start_selection, end_selection);
            }
            
            // Проверяем, является ли буква частью найденного слова
            for (var i = 0; i < array_length(words_found); i++) {
                var word = words_found[i];
                if (is_cell_part_of_word(x, y, word)) {
                    found = true;
                    break;
                }
            }
            
            // Выбираем цвет в зависимости от состояния
            if (found) {
                draw_set_color(puzzle_config.found_color);
            } else if (highlighted) {
                draw_set_color(puzzle_config.highlight_color);
            } else {
                draw_set_color(puzzle_config.default_color);
            }
            
            // Рисуем букву
            draw_set_font(fnt_default);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(screen_x + puzzle_config.cell_size / 2, 
                     screen_y + puzzle_config.cell_size / 2, 
                     grid[y, x]);
        }
    }
}

// Проверка, находится ли ячейка на линии между двумя точками
function is_cell_on_line(x, y, start, end) {
    if (start == undefined || end == undefined) {
        return false;
    }
    
    // Проверяем, находится ли точка на прямой линии
    if (start.x == end.x) {
        // Вертикаль
        return x == start.x && min(start.y, end.y) <= y && y <= max(start.y, end.y);
    } else if (start.y == end.y) {
        // Горизонталь
        return y == start.y && min(start.x, end.x) <= x && x <= max(start.x, end.x);
    } else if (abs(start.x - end.x) == abs(start.y - end.y)) {
        // Диагональ
        var dx = sign(end.x - start.x);
        var dy = sign(end.y - start.y);
        
        var temp_x = start.x;
        var temp_y = start.y;
        
        while (temp_x != end.x + dx || temp_y != end.y + dy) {
            if (temp_x == x && temp_y == y) {
                return true;
            }
            temp_x += dx;
            temp_y += dy;
        }
    }
    
    return false;
}

// Проверка, является ли ячейка частью найденного слова
function is_cell_part_of_word(x, y, word) {
    // Эта функция будет проверять, находится ли ячейка с координатами (x, y)
    // в одном из найденных слов и их позициях
    // Пока что упрощенно возвращаем false, подробная реализация будет позже
    return false;
}

// Отрисовка оболочки головоломки
function draw_puzzle_shell() {
    // Верхняя панель с информацией
    draw_set_color(c_navy);
    draw_rectangle(0, 0, room_width, 100);
    draw_set_color(c_white);
    draw_set_font(fnt_default);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(room_width / 2, 20, "Головоломка: Поиск слов");
    draw_text(room_width / 2, 40, "Найдите все слова из списка:");
    
    // Рисуем список слов
    var words_x = room_width / 2 - 150;
    for (var i = 0; i < array_length(puzzle_config.words_to_find); i++) {
        var word = puzzle_config.words_to_find[i];
        var found = false;
        
        // Проверяем, найдено ли слово
        for (var j = 0; j < array_length(words_found); j++) {
            if (string_upper(words_found[j]) == string_upper(word)) {
                found = true;
                break;
            }
        }
        
        if (found) {
            draw_set_color(c_green);
        } else {
            draw_set_color(c_lightgray);
        }
        
        draw_text(words_x + (i % 3) * 100, 60 + floor(i / 3) * 20, word);
    }
    
    draw_set_color(c_white);
    draw_text(room_width / 2, 80, "Кликните на первую букву слова, затем на последнюю");
    
    // Нижняя панель с инструкцией
    draw_set_color(c_darkblue);
    draw_rectangle(0, room_height - 40, room_width, room_height);
    draw_set_color(c_yellow);
    if (solved) {
        draw_text(20, room_height - 30, "Головоломка решена! Нажмите ESC для выхода.");
    } else {
        draw_text(20, room_height - 30, "Найдено слов: " + string(array_length(words_found)) + "/" + string(array_length(puzzle_config.words_to_find)));
    }
    draw_text(room_width - 220, room_height - 30, "ESC - выйти из головоломки");
}

// Основная функция отрисовки
function draw() {
    // Рисуем оболочку головоломки
    draw_puzzle_shell();
    
    // Рисуем сетку
    draw_grid();
}

// Функция сброса головоломки
function reset_word_search() {
    selected_letters = [];
    words_found = [];
    click_positions = [];
    selecting = false;
    start_selection = undefined;
    end_selection = undefined;
    solved = false;
    current_state = puzzle_states.PHASE1_SEARCH;
    
    // Перегенерируем сетку
    generate_letter_grid();
    place_words();
}

// Функция проверки, решена ли головоломка
function is_solved() {
    return solved;
}

// Функция получения состояния головоломки
function get_state() {
    return current_state;
}

// Функция установки состояния
function set_state(new_state) {
    if (puzzle_states[new_state] != undefined) {
        current_state = new_state;
    }
}

// Функция получения количества найденных слов
function get_found_words_count() {
    return array_length(words_found);
}

// Функция получения общего количества слов
function get_total_words_count() {
    return array_length(puzzle_config.words_to_find);
}