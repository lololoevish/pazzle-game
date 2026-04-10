// Скрипт головоломки "Лабиринт" для GameMaker

function maze_puzzle_init() {
    global.maze_width = 15;
    global.maze_height = 15;
    global.maze_grid = array_create(global.maze_width * global.maze_height, 1);

    maze_generate_maze(global.maze_width, global.maze_height);

    global.maze_start_x = 1;
    global.maze_start_y = 1;
    global.maze_end_x = global.maze_width - 2;
    global.maze_end_y = global.maze_height - 2;
    global.maze_player_x = global.maze_start_x;
    global.maze_player_y = global.maze_start_y;
    global.maze_solved = false;

    return {
        width: global.maze_width,
        height: global.maze_height
    };
}

function maze_generate_maze(width, height) {
    var visited = array_create(width * height, false);
    var stack = ds_stack_create();

    var current_x = 1;
    var current_y = 1;
    global.maze_grid[current_y * width + current_x] = 0;
    visited[current_y * width + current_x] = true;

    while (true) {
        var neighbors = [];
        var dirs = [
            [-2, 0, -1, 0],
            [2, 0, 1, 0],
            [0, -2, 0, -1],
            [0, 2, 0, 1]
        ];

        for (var i = 0; i < 4; i++) {
            var nx = current_x + dirs[i][0];
            var ny = current_y + dirs[i][1];
            if (nx > 0 && nx < width - 1 && ny > 0 && ny < height - 1) {
                if (!visited[ny * width + nx]) {
                    array_push(neighbors, [nx, ny, current_x + dirs[i][2], current_y + dirs[i][3]]);
                }
            }
        }

        if (array_length(neighbors) > 0) {
            var chosen = neighbors[irandom(array_length(neighbors) - 1)];
            ds_stack_push(stack, current_x);
            ds_stack_push(stack, current_y);
            global.maze_grid[chosen[1] * width + chosen[0]] = 0;
            global.maze_grid[chosen[3] * width + chosen[2]] = 0;
            visited[chosen[1] * width + chosen[0]] = true;
            current_x = chosen[0];
            current_y = chosen[1];
        } else if (ds_stack_size(stack) > 0) {
            current_y = ds_stack_pop(stack);
            current_x = ds_stack_pop(stack);
        } else {
            break;
        }
    }

    ds_stack_destroy(stack);
}

function maze_puzzle_update() {
    if (global.maze_solved) {
        return;
    }

    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord('D'))) {
        maze_move_player(1, 0);
    } else if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord('A'))) {
        maze_move_player(-1, 0);
    } else if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord('W'))) {
        maze_move_player(0, -1);
    } else if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord('S'))) {
        maze_move_player(0, 1);
    }

    if (global.maze_player_x == global.maze_end_x && global.maze_player_y == global.maze_end_y) {
        maze_puzzle_solve();
    }
}

function maze_move_player(dx, dy) {
    var moved = false;
    while (true) {
        var next_x = global.maze_player_x + dx;
        var next_y = global.maze_player_y + dy;

        if (next_x >= 0 && next_x < global.maze_width && next_y >= 0 && next_y < global.maze_height) {
            if (global.maze_grid[next_y * global.maze_width + next_x] == 0) {
                global.maze_player_x = next_x;
                global.maze_player_y = next_y;
                moved = true;
            } else {
                break;
            }
        } else {
            break;
        }
    }

    if (moved) {
        play_sfx("interaction");
    }
}

function maze_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }

    var cell_size = 32;
    var offset_x = (room_width - global.maze_width * cell_size) / 2;
    var offset_y = (room_height - global.maze_height * cell_size) / 2;

    for (var y = 0; y < global.maze_height; y++) {
        for (var x = 0; x < global.maze_width; x++) {
            var screen_x = offset_x + x * cell_size;
            var screen_y = offset_y + y * cell_size;

            if (global.maze_grid[y * global.maze_width + x] == 1) {
                draw_set_color(c_black);
                draw_rectangle(screen_x, screen_y, screen_x + cell_size, screen_y + cell_size, false);
            } else {
                draw_set_color(c_white);
                draw_rectangle(screen_x, screen_y, screen_x + cell_size, screen_y + cell_size, false);
                draw_set_color(c_gray);
                draw_rectangle(screen_x, screen_y, screen_x + cell_size, screen_y + cell_size, true);
            }
        }
    }

    draw_set_color(c_red);
    draw_circle(offset_x + global.maze_player_x * cell_size + cell_size / 2, offset_y + global.maze_player_y * cell_size + cell_size / 2, cell_size / 2 - 2, true);

    draw_set_color(c_green);
    draw_circle(offset_x + global.maze_end_x * cell_size + cell_size / 2, offset_y + global.maze_end_y * cell_size + cell_size / 2, cell_size / 2 - 2, true);
}

function maze_puzzle_is_solved() {
    return global.maze_solved;
}

function maze_puzzle_solve() {
    global.maze_solved = true;
    play_sfx("puzzle_completed");
}

function maze_puzzle_reset() {
    return maze_puzzle_init();
}
