// Скрипт головоломки "Лабиринт" для GameMaker

// Функция инициализации головоломки
function init() {
    // Создаем сетку лабиринта (15x15 как в Rust-версии)
    var width = 15;
    var height = 15;
    
    // Создаем структуру лабиринта
    maze_grid = array_create(width * height);
    
    // Генерируем лабиринт с помощью алгоритма DFS
    generate_maze(width, height);
    
    // Устанавливаем начальную и конечную позиции
    start_x = 1;
    start_y = 1;
    end_x = width - 2;
    end_y = height - 2;
    
    // Позиция игрока в лабиринте
    player_x = start_x;
    player_y = start_y;
    
    // Состояние завершения
    solved = false;
    
    return {
        grid: maze_grid,
        width: width,
        height: height,
        start_pos: [start_x, start_y],
        end_pos: [end_x, end_y],
        player_pos: [player_x, player_y]
    };
}

// Функция генерации лабиринта (DFS)
function generate_maze(width, height) {
    // Инициализация сетки стенами
    var x, y;
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            // Края - всегда стены, внутренние - тоже сначала
            if (x == 0 || y == 0 || x == width-1 || y == height-1) {
                maze_grid[y * width + x] = 1; // Стена
            } else {
                maze_grid[y * width + x] = 1; // Стена
            }
        }
    }
    
    // DFS для генерации проходов
    var stack = ds_stack_create();
    var visited = array_create(width * height);
    
    // Начинаем с (1,1)
    var current_x = 1;
    var current_y = 1;
    maze_grid[current_y * width + current_x] = 0; // Отмечаем как проход
    ds_stack_push(stack, current_x);
    ds_stack_push(stack, current_y);
    visited[current_y * width + current_x] = 1;
    
    var directions = [
        [-2, 0, -1, 0],   // Влево
        [2, 0, 1, 0],    // Вправо
        [0, -2, 0, -1],  // Вверх
        [0, 2, 0, 1]     // Вниз
    ];
    
    while (ds_stack_size(stack) > 0) {
        var neighbors = [];
        
        // Проверяем все возможные направления
        var dir;
        for (dir = 0; dir < 4; dir++) {
            var new_x = current_x + directions[dir][0];
            var new_y = current_y + directions[dir][1];
            var wall_x = current_x + directions[dir][2];
            var wall_y = current_y + directions[dir][3];
            
            if (new_x > 0 && new_x < width-1 && new_y > 0 && new_y < height-1) {
                if (!visited[new_y * width + new_x]) {
                    neighbors[neighbors.length] = [new_x, new_y, wall_x, wall_y];
                }
            }
        }
        
        if (array_length_1d(neighbors) > 0) {
            // Выбираем случайного соседа
            var chosen = neighbors[random(array_length_1d(neighbors))];
            
            // Убираем стены
            maze_grid[chosen[1] * width + chosen[0]] = 0;
            maze_grid[chosen[3] * width + chosen[2]] = 0;
            
            // Добавляем в посещенные
            visited[chosen[1] * width + chosen[0]] = 1;
            
            // Добавляем в стек
            ds_stack_push(stack, current_x);
            ds_stack_push(stack, current_y);
            
            // Переходим к новой позиции
            current_x = chosen[0];
            current_y = chosen[1];
        } else {
            // Возвращаемся назад
            current_y = ds_stack_pop(stack);
            current_x = ds_stack_pop(stack);
        }
    }
    
    ds_stack_destroy(stack);
}

// Функция обновления логики головоломки
function update() {
    // Обработка движения игрока
    if (!solved) {
        var moved = false;
        
        // Проверяем нажатия клавиш для движения
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord('D'))) {
            moved = move_player(1, 0);
        } else if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord('A'))) {
            moved = move_player(-1, 0);
        } else if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord('W'))) {
            moved = move_player(0, -1);
        } else if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord('S'))) {
            moved = move_player(0, 1);
        }
        
        // Проверяем, достиг ли игрок конца
        if (player_x == end_x && player_y == end_y) {
            solve_puzzle();
        }
    }
}

// Функция движения игрока в лабиринте (реализация скольжения до стены)
function move_player(dx, dy) {
    var moved = false;
    
    // В лабиринте Rust-версии реализовано скольжение до стены
    // Двигаем игрока, пока следующая клетка не будет стеной
    while (true) {
        var next_x = player_x + dx;
        var next_y = player_y + dy;
        
        var width = sqrt(array_length_1d(maze_grid));  // Это приблизительно, точное значение должно быть известно
        
        // Проверяем, не выходит ли за границы и не стена ли это
        if (next_x >= 0 && next_x < width && next_y >= 0 && next_y < width && 
            maze_grid[next_y * width + next_x] == 0) {
            player_x = next_x;
            player_y = next_y;
            moved = true;
        } else {
            // Наткнулись на стену или границу - останавливаемся
            break;
        }
    }
    
    return moved;
}

// Функция отрисовки головоломки
function draw(gui_view = false) {
    if (!gui_view) {
        var width = sqrt(array_length_1d(maze_grid));
        var cell_size = 32; // Размер ячейки в пикселях
        var offset_x = (room_width - width * cell_size) / 2;
        var offset_y = (room_height - width * cell_size) / 2;
        
        // Рисуем сетку лабиринта
        var x, y;
        for (y = 0; y < width; y++) {
            for (x = 0; x < width; x++) {
                var screen_x = offset_x + x * cell_size;
                var screen_y = offset_y + y * cell_size;
                
                if (maze_grid[y * width + x] == 1) {
                    // Стена
                    draw_set_color(c_black);
                    draw_rectangle(screen_x, screen_y, screen_x + cell_size, screen_y + cell_size, false);
                } else {
                    // Проход
                    draw_set_color(c_white);
                    draw_rectangle(screen_x, screen_y, screen_x + cell_size, screen_y + cell_size, false);
                    
                    // Рисуем сетку
                    draw_set_color(c_gray);
                    draw_rectangle(screen_x, screen_y, screen_x + cell_size, screen_y + cell_size, true);
                }
            }
        }
        
        // Рисуем игрока
        var player_screen_x = offset_x + player_x * cell_size + cell_size/2;
        var player_screen_y = offset_y + player_y * cell_size + cell_size/2;
        
        draw_set_color(c_red);
        draw_circle(player_screen_x, player_screen_y, cell_size/2 - 2, true);
        
        // Рисуем конечную точку
        var end_screen_x = offset_x + end_x * cell_size + cell_size/2;
        var end_screen_y = offset_y + end_y * cell_size + cell_size/2;
        
        draw_set_color(c_green);
        draw_circle(end_screen_x, end_screen_y, cell_size/2 - 2, true);
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
    play_sfx("puzzle_success");
}

// Функция сброса головоломки
function reset() {
    var puzzle_data = init();
    solved = false;
    return puzzle_data;
}
