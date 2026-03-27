/*
 * Объект головоломки лабиринта
 * Реализация алгоритма лабиринта из Rust-версии
 */

// Параметры лабиринта
var maze_config = {
    width: 15,               // Ширина лабиринта (должна быть нечетной)
    height: 15,              // Высота лабиринта (должна быть нечетной)
    cell_size: 30,           // Размер ячейки в пикселях
    wall_thickness: 4,       // Толщина стен
    start_x: 1,              // Начальная позиция X
    start_y: 1,              // Начальная позиция Y
    exit_x: 13,              // Позиция выхода X
    exit_y: 13,              // Позиция выхода Y
    player_start_offset: 15, // Смещение игрока от края ячейки
    player_size: 20          // Размер игрока
};

// Состояния головоломки
var puzzle_states = {
    SETUP: "setup",          // Инициализация
    ACTIVE: "active",        // Активна
    SOLVED: "solved",        // Решена
    INACTIVE: "inactive"     // Неактивна
};

// Глобальные переменные
current_state = puzzle_states.SETUP;
grid = [];                   // Сетка лабиринта (true = стена, false = проход)
player_x = maze_config.start_x;
player_y = maze_config.start_y;
exit_reached = false;
solved = false;

// Инициализация
function maze_init(width, height) {
    // Убедимся, что размеры нечетные
    if (width % 2 == 0) width += 1;
    if (height % 2 == 0) height += 1;
    
    maze_config.width = width;
    maze_config.height = height;
    
    // Установим выход в правый нижний угол
    maze_config.exit_x = width - 2;
    maze_config.exit_y = height - 2;
    
    // Инициализируем сетку как стены
    grid = array_create(height, width);
    for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
            grid[y, x] = true;  // true означает стену
        }
    }
    
    // Генерируем лабиринт
    generate_maze();
    
    // Установим начальное состояние
    current_state = puzzle_states.ACTIVE;
    player_x = maze_config.start_x;
    player_y = maze_config.start_y;
    exit_reached = false;
    solved = false;
}

// Генерация лабиринта алгоритмом DFS с возвратом
function generate_maze() {
    // Начальная точка (должна быть нечетной координаты)
    var start_x = 1;
    var start_y = 1;
    
    // Отмечаем начальную точку как проход
    grid[start_y, start_x] = false;
    
    // Стек для отслеживания пути
    var stack = ds_stack_create();
    ds_stack_push(stack, start_x);
    ds_stack_push(stack, start_y);
    
    // Направления: вверх, вправо, вниз, влево (в виде смещений)
    var directions = [
        {dx: 0, dy: -2},  // вверх
        {dx: 2, dy: 0},   // вправо
        {dx: 0, dy: 2},   // вниз
        {dx: -2, dy: 0}   // влево
    ];
    
    while (!ds_stack_empty(stack)) {
        var current_y = ds_stack_pop(stack);
        var current_x = ds_stack_pop(stack);
        
        // Найдем возможные направления
        var neighbors = [];
        
        for (var i = 0; i < 4; i++) {
            var new_x = current_x + directions[i].dx;
            var new_y = current_y + directions[i].dy;
            
            // Проверяем, в пределах ли границ и является ли ячейка стеной
            if (new_x > 0 && new_y > 0 && 
                new_x < maze_config.width - 1 && new_y < maze_config.height - 1 && 
                grid[new_y, new_x]) {
                // Добавляем соседа и смещение стены
                array_push(neighbors, {
                    x: new_x,
                    y: new_y,
                    wall_x: current_x + directions[i].dx / 2,
                    wall_y: current_y + directions[i].dy / 2
                });
            }
        }
        
        if (array_length(neighbors) > 0) {
            // Возвращаем координаты в стек
            ds_stack_push(stack, current_x);
            ds_stack_push(stack, current_y);
            
            // Случайно выбираем соседа
            var random_idx = irandom(array_length(neighbors) - 1);
            var chosen = neighbors[random_idx];
            
            // Пробиваем путь
            grid[chosen.y, chosen.x] = false;
            grid[chosen.wall_y, chosen.wall_x] = false;
            
            // Добавляем новую точку в стек
            ds_stack_push(stack, chosen.x);
            ds_stack_push(stack, chosen.y);
        }
    }
    
    // Убедимся, что выход свободен
    grid[maze_config.exit_y, maze_config.exit_x] = false;
    
    ds_stack_destroy(stack);
}

// Функция скольжения игрока до стены
function slide_to_wall(start_x, start_y, dx, dy) {
    var x = start_x;
    var y = start_y;
    
    while (true) {
        var next_x = x + dx;
        var next_y = y + dy;
        
        // Проверяем границы и стены
        if (next_x < 0 || next_y < 0 || 
            next_x >= maze_config.width || next_y >= maze_config.height || 
            grid[next_y, next_x]) {
            break;
        }
        
        x = next_x;
        y = next_y;
    }
    
    return {x: x, y: y};
}

// Обработка ввода
function handle_input() {
    if (current_state != puzzle_states.ACTIVE || solved) {
        return;
    }
    
    var new_pos = undefined;
    
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord('W'))) {
        new_pos = slide_to_wall(player_x, player_y, 0, -1);
    } else if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord('S'))) {
        new_pos = slide_to_wall(player_x, player_y, 0, 1);
    } else if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord('A'))) {
        new_pos = slide_to_wall(player_x, player_y, -1, 0);
    } else if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord('D'))) {
        new_pos = slide_to_wall(player_x, player_y, 1, 0);
    }
    
    // Если позиция изменилась, обновляем
    if (new_pos != undefined) {
        player_x = new_pos.x;
        player_y = new_pos.y;
        
        // Проверяем, достиг ли игрок выхода
        check_exit_reached();
    }
}

// Проверка достижения выхода
function check_exit_reached() {
    if (player_x == maze_config.exit_x && player_y == maze_config.exit_y) {
        exit_reached = true;
        solved = true;
        current_state = puzzle_states.SOLVED;
        
        // Уведомляем о решении головоломки
        scr_ui_manager.show_message("Головоломка решена! Вы достигли выхода.");
        scr_audio_manager.play_event_sound("puzzle_solve");
        
        // Сообщаем игровому контроллеру о завершении уровня (если применимо)
        // Это зависит от контекста, в котором используется головоломка
    }
}

// Обновление логики
function update() {
    // В данной головоломке обновление происходит в основном через обработку ввода
}

// Отрисовка лабиринта
function draw_maze() {
    // Вычисляем смещение, чтобы лабиринт был в центре
    var offset_x = (room_width - (maze_config.width * maze_config.cell_size)) / 2;
    var offset_y = (room_height - (maze_config.height * maze_config.cell_size)) / 2 + 30;
    
    // Рисуем сетку лабиринта
    for (var y = 0; y < maze_config.height; y++) {
        for (var x = 0; x < maze_config.width; x++) {
            var screen_x = offset_x + x * maze_config.cell_size;
            var screen_y = offset_y + y * maze_config.cell_size;
            
            // Выбираем цвет в зависимости от типа ячейки
            if (grid[y, x]) {
                // Стена
                draw_set_color(c_gray);
            } else {
                // Проход
                draw_set_color(c_lightgray);
            }
            
            // Рисуем квадрат ячейки
            draw_rectangle(screen_x, screen_y, 
                          screen_x + maze_config.cell_size - maze_config.wall_thickness, 
                          screen_y + maze_config.cell_size - maze_config.wall_thickness);
            
            // Для проходов рисуем немного темнее пол
            if (!grid[y, x]) {
                draw_set_color(make_color_rgb(200, 210, 225));
                draw_rectangle(screen_x, 
                              screen_y + maze_config.cell_size - maze_config.wall_thickness,
                              screen_x + maze_config.cell_size - maze_config.wall_thickness,
                              screen_y + maze_config.cell_size);
            }
        }
    }
    
    // Рисуем начальную позицию
    var start_scr_x = offset_x + maze_config.start_x * maze_config.cell_size + maze_config.cell_size / 2;
    var start_scr_y = offset_y + maze_config.start_y * maze_config.cell_size + maze_config.cell_size / 2;
    draw_set_color(c_green);
    draw_circle(start_scr_x, start_scr_y, maze_config.player_size / 2);
    draw_circle_outline(start_scr_x, start_scr_y, maze_config.player_size / 2 + 2, c_white);
    
    // Рисуем выход
    var exit_scr_x = offset_x + maze_config.exit_x * maze_config.cell_size + maze_config.cell_size / 2;
    var exit_scr_y = offset_y + maze_config.exit_y * maze_config.cell_size + maze_config.cell_size / 2;
    draw_set_color(c_red);
    draw_circle(exit_scr_x, exit_scr_y, maze_config.player_size / 2);
    draw_circle(exit_scr_x, exit_scr_y, maze_config.player_size / 4, c_yellow);
    draw_circle_outline(exit_scr_x, exit_scr_y, maze_config.player_size / 2 + 2, c_white);
    
    // Рисуем позицию игрока
    var player_scr_x = offset_x + player_x * maze_config.cell_size + maze_config.cell_size / 2;
    var player_scr_y = offset_y + player_y * maze_config.cell_size + maze_config.cell_size / 2;
    draw_set_color(c_blue);
    draw_circle(player_scr_x, player_scr_y, maze_config.player_size / 3);
    draw_circle_outline(player_scr_x, player_scr_y, maze_config.player_size / 3 + 2, c_white);
}

// Функция отрисовки оболочки головоломки
function draw_puzzle_shell() {
    // Верхняя панель с информацией
    draw_set_color(c_navy);
    draw_rectangle(0, 0, room_width, 80);
    draw_set_color(c_white);
    draw_set_font(fnt_default);
    draw_set_halign(fa_center);
    draw_text(room_width / 2, 20, "Головоломка: Лабиринт");
    draw_text(room_width / 2, 40, "Скользите до ближайшей стены. Найдите путь к выходу.");
    draw_text(room_width / 2, 60, "WASD - движение");
    
    // Основная область рисования лабиринта (уже в draw_maze)
    
    // Нижняя панель с инструкцией
    draw_set_color(c_darkblue);
    draw_rectangle(0, room_height - 60, room_width, room_height);
    draw_set_color(c_yellow);
    if (solved) {
        draw_text(20, room_height - 40, "Головоломка решена! Нажмите ESC для выхода.");
    } else {
        draw_text(20, room_height - 40, "Доберитесь до красного круга (выход)");
    }
    draw_text(room_width - 200, room_height - 40, "ESC - выйти из головоломки");
}

// Основная функция отрисовки
function draw() {
    // Рисуем оболочку головоломки
    draw_puzzle_shell();
    
    // Рисуем сам лабиринт
    draw_maze();
}

// Функция сброса головоломки
function reset_maze() {
    player_x = maze_config.start_x;
    player_y = maze_config.start_y;
    exit_reached = false;
    solved = false;
    current_state = puzzle_states.ACTIVE;
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