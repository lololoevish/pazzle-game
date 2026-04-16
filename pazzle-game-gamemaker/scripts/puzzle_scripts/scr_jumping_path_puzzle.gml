// Скрипт головоломки "Прыгающий Путь" для GameMaker
// Уровень 9: Усложненный платформер с акцентом на точные прыжки

function jumping_path_puzzle_init() {
    global.jumping_path_player_x = 50;
    global.jumping_path_player_y = 550;
    global.jumping_path_velocity_x = 0;
    global.jumping_path_velocity_y = 0;
    global.jumping_path_on_ground = false;
    global.jumping_path_jump_buffer = 0;
    global.jumping_path_coyote_time = 0;
    global.jumping_path_gravity = 0.5;
    global.jumping_path_jump_strength = -12;
    global.jumping_path_move_speed = 4;
    global.jumping_path_solved = false;
    global.jumping_path_checkpoints_reached = 0;
    global.jumping_path_total_checkpoints = 5;
    
    // Платформы с увеличенной сложностью
    global.jumping_path_platforms = [
        {x: 0, y: 570, width: 100, height: 30, type: "start"},
        {x: 150, y: 520, width: 80, height: 20, type: "normal"},
        {x: 280, y: 450, width: 60, height: 20, type: "moving"},
        {x: 400, y: 380, width: 70, height: 20, type: "crumbling"},
        {x: 550, y: 320, width: 80, height: 20, type: "normal"},
        {x: 680, y: 250, width: 90, height: 20, type: "checkpoint"},
        {x: 750, y: 570, width: 50, height: 30, type: "goal"}
    ];
    
    // Движущиеся платформы
    global.jumping_path_moving_platform_offset = 0;
    global.jumping_path_moving_platform_direction = 1;
    
    return { checkpoints: global.jumping_path_total_checkpoints };
}

function jumping_path_puzzle_update() {
    if (global.jumping_path_solved) {
        return;
    }
    
    // Обработка ввода
    var move_x = 0;
    if (keyboard_check(vk_left) || keyboard_check(ord('A'))) {
        move_x = -global.jumping_path_move_speed;
    }
    if (keyboard_check(vk_right) || keyboard_check(ord('D'))) {
        move_x = global.jumping_path_move_speed;
    }
    
    global.jumping_path_velocity_x = move_x;
    
    // Jump buffer
    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord('W'))) {
        global.jumping_path_jump_buffer = 0.15 * 60; // 0.15 секунды
    }
    
    if (global.jumping_path_jump_buffer > 0) {
        global.jumping_path_jump_buffer--;
    }
    
    // Coyote time
    if (global.jumping_path_on_ground) {
        global.jumping_path_coyote_time = 0.1 * 60; // 0.1 секунды
    } else if (global.jumping_path_coyote_time > 0) {
        global.jumping_path_coyote_time--;
    }
    
    // Прыжок
    if (global.jumping_path_jump_buffer > 0 && global.jumping_path_coyote_time > 0) {
        global.jumping_path_velocity_y = global.jumping_path_jump_strength;
        global.jumping_path_jump_buffer = 0;
        global.jumping_path_coyote_time = 0;
        global.jumping_path_on_ground = false;
        
        if (script_exists(play_event_sound)) {
            play_event_sound("jump");
        }
    }
    
    // Variable jump height
    if (!keyboard_check(vk_space) && !keyboard_check(ord('W')) && global.jumping_path_velocity_y < 0) {
        global.jumping_path_velocity_y *= 0.5;
    }
    
    // Гравитация
    global.jumping_path_velocity_y += global.jumping_path_gravity;
    
    // Обновление позиции
    global.jumping_path_player_x += global.jumping_path_velocity_x;
    global.jumping_path_player_y += global.jumping_path_velocity_y;
    
    // Обновление движущихся платформ
    global.jumping_path_moving_platform_offset += global.jumping_path_moving_platform_direction * 2;
    if (abs(global.jumping_path_moving_platform_offset) > 50) {
        global.jumping_path_moving_platform_direction *= -1;
    }
    
    // Проверка коллизий с платформами
    global.jumping_path_on_ground = false;
    for (var i = 0; i < array_length(global.jumping_path_platforms); i++) {
        var plat = global.jumping_path_platforms[i];
        var plat_x = plat.x;
        
        // Движущиеся платформы
        if (plat.type == "moving") {
            plat_x += global.jumping_path_moving_platform_offset;
        }
        
        if (global.jumping_path_player_x + 20 > plat_x && 
            global.jumping_path_player_x < plat_x + plat.width &&
            global.jumping_path_player_y + 30 > plat.y && 
            global.jumping_path_player_y + 30 < plat.y + plat.height + 10 &&
            global.jumping_path_velocity_y >= 0) {
            
            global.jumping_path_player_y = plat.y - 30;
            global.jumping_path_velocity_y = 0;
            global.jumping_path_on_ground = true;
            
            // Проверка достижения цели
            if (plat.type == "goal") {
                jumping_path_puzzle_solve();
            }
            
            // Проверка чекпоинтов
            if (plat.type == "checkpoint" && !plat.reached) {
                plat.reached = true;
                global.jumping_path_checkpoints_reached++;
                if (script_exists(play_event_sound)) {
                    play_event_sound("puzzle_success");
                }
            }
        }
    }
    
    // Проверка падения
    if (global.jumping_path_player_y > 600) {
        jumping_path_reset_position();
    }
    
    // Ограничение по горизонтали
    global.jumping_path_player_x = clamp(global.jumping_path_player_x, 0, 780);
}

function jumping_path_reset_position() {
    global.jumping_path_player_x = 50;
    global.jumping_path_player_y = 550;
    global.jumping_path_velocity_x = 0;
    global.jumping_path_velocity_y = 0;
    
    if (script_exists(play_event_sound)) {
        play_event_sound("cancel");
    }
}

function jumping_path_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }
    
    // Рисование платформ
    for (var i = 0; i < array_length(global.jumping_path_platforms); i++) {
        var plat = global.jumping_path_platforms[i];
        var plat_x = plat.x;
        
        if (plat.type == "moving") {
            plat_x += global.jumping_path_moving_platform_offset;
        }
        
        // Цвет в зависимости от типа
        switch (plat.type) {
            case "start":
                draw_set_color(c_green);
                break;
            case "goal":
                draw_set_color(c_yellow);
                break;
            case "checkpoint":
                draw_set_color(plat.reached ? c_aqua : c_blue);
                break;
            case "moving":
                draw_set_color(c_purple);
                break;
            case "crumbling":
                draw_set_color(c_orange);
                break;
            default:
                draw_set_color(c_gray);
        }
        
        draw_rectangle(plat_x, plat.y, plat_x + plat.width, plat.y + plat.height, false);
    }
    
    // Рисование игрока
    draw_set_color(c_white);
    draw_rectangle(global.jumping_path_player_x, global.jumping_path_player_y, 
                   global.jumping_path_player_x + 20, global.jumping_path_player_y + 30, false);
    
    // UI
    draw_set_color(c_white);
    draw_text(10, 10, "Прыгающий Путь");
    draw_text(10, 30, "Чекпоинты: " + string(global.jumping_path_checkpoints_reached) + "/" + string(global.jumping_path_total_checkpoints));
    draw_text(10, 50, "Управление: A/D или ←/→ - движение, W/SPACE - прыжок");
}

function jumping_path_puzzle_is_solved() {
    return global.jumping_path_solved;
}

function jumping_path_puzzle_solve() {
    global.jumping_path_solved = true;
    if (script_exists(play_event_sound)) {
        play_event_sound("puzzle_completed");
    }
}

function jumping_path_puzzle_reset() {
    return jumping_path_puzzle_init();
}
