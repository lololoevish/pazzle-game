// Скрипт головоломки "Платформер" для GameMaker

function platformer_puzzle_approach(current, target, amount) {
    if (current < target) return min(current + amount, target);
    if (current > target) return max(current - amount, target);
    return target;
}

function platformer_puzzle_init() {
    global.platformer_player = {
        x: 50,
        y: 400,
        width: 20,
        height: 20,
        speed: 260,
        hspeed: 0,
        vspeed: 0,
        jump_speed: 560,
        jump_cut_speed: 220,
        gravity_rise_hold: 1350,
        gravity_rise_release: 2500,
        gravity_fall: 2850,
        max_fall_speed: 900,
        on_ground: false,
        coyote_timer: 0,
        jump_buffer_timer: 0
    };

    global.platformer_platforms = [
        {x: 0, y: 580, w: 800, h: 20},
        {x: 100, y: 500, w: 100, h: 20},
        {x: 300, y: 450, w: 100, h: 20},
        {x: 500, y: 400, w: 100, h: 20},
        {x: 200, y: 350, w: 100, h: 20},
        {x: 400, y: 300, w: 100, h: 20},
        {x: 600, y: 250, w: 100, h: 20},
        {x: 350, y: 200, w: 100, h: 20}
    ];

    global.platformer_crystals = [
        {x: 130, y: 470, collected: false},
        {x: 330, y: 420, collected: false},
        {x: 530, y: 370, collected: false},
        {x: 230, y: 320, collected: false},
        {x: 430, y: 270, collected: false},
        {x: 630, y: 220, collected: false}
    ];

    global.platformer_goal = {x: 380, y: 170, w: 40, h: 40};
    global.platformer_collected_crystals = 0;
    global.platformer_total_crystals = array_length(global.platformer_crystals);
    global.platformer_time_limit = 1800;
    global.platformer_time_remaining = global.platformer_time_limit;
    global.platformer_solved = false;

    return { total: global.platformer_total_crystals };
}

function platformer_puzzle_update() {
    if (global.platformer_solved) {
        return;
    }

    global.platformer_time_remaining--;
    if (global.platformer_time_remaining <= 0) {
        platformer_puzzle_reset_level();
        return;
    }

    platformer_puzzle_handle_player_movement();
    platformer_puzzle_update_player_physics();
    platformer_puzzle_check_collisions();
    platformer_puzzle_check_completion();
}

function platformer_puzzle_handle_player_movement() {
    var dt = clamp(delta_time / 1000000, 0, 0.05);
    var input_x = 0;
    var jump_pressed = keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord('W'));
    var jump_down = keyboard_check(vk_space) || keyboard_check(vk_up) || keyboard_check(ord('W'));
    var jump_released = keyboard_check_released(vk_space) || keyboard_check_released(vk_up) || keyboard_check_released(ord('W'));
    var player = global.platformer_player;

    if (keyboard_check(vk_right) || keyboard_check(ord('D'))) input_x += 1;
    if (keyboard_check(vk_left) || keyboard_check(ord('A'))) input_x -= 1;

    var target_hspeed = input_x * player.speed;
    var accel = player.on_ground ? 2200 : 1600;
    var decel = player.on_ground ? 2600 : 1400;

    if (input_x != 0) {
        player.hspeed = platformer_puzzle_approach(player.hspeed, target_hspeed, accel * dt);
    } else {
        player.hspeed = platformer_puzzle_approach(player.hspeed, 0, decel * dt);
    }

    if (jump_pressed) {
        player.jump_buffer_timer = 0.15;
    } else {
        player.jump_buffer_timer = max(0, player.jump_buffer_timer - dt);
    }

    if (player.on_ground) {
        player.coyote_timer = 0.5;
    } else {
        player.coyote_timer = max(0, player.coyote_timer - dt);
    }

    if (player.jump_buffer_timer > 0 && (player.on_ground || player.coyote_timer > 0)) {
        player.vspeed = -player.jump_speed;
        player.on_ground = false;
        player.coyote_timer = 0;
        player.jump_buffer_timer = 0;
        play_sfx("interaction");
    }

    if (jump_released && player.vspeed < -player.jump_cut_speed) {
        player.vspeed = -player.jump_cut_speed;
    }

    var gravity_value = player.gravity_fall;
    if (player.vspeed < 0) {
        gravity_value = jump_down ? player.gravity_rise_hold : player.gravity_rise_release;
    }

    player.vspeed = min(player.vspeed + gravity_value * dt, player.max_fall_speed);
    global.platformer_player = player;
}

function platformer_puzzle_update_player_physics() {
    var dt = clamp(delta_time / 1000000, 0, 0.05);
    platformer_puzzle_move_axis(global.platformer_player.hspeed * dt, true);
    global.platformer_player.on_ground = false;
    platformer_puzzle_move_axis(global.platformer_player.vspeed * dt, false);

    if (global.platformer_player.x < 0) global.platformer_player.x = 0;
    if (global.platformer_player.x + global.platformer_player.width > room_width) global.platformer_player.x = room_width - global.platformer_player.width;
    if (global.platformer_player.y < 0) {
        global.platformer_player.y = 0;
        global.platformer_player.vspeed = max(0, global.platformer_player.vspeed);
    }
    if (global.platformer_player.y > room_height + global.platformer_player.height) {
        platformer_puzzle_reset_level();
    }
}

function platformer_puzzle_check_collisions() {
    var player = global.platformer_player;

    for (var i = 0; i < array_length(global.platformer_crystals); i++) {
        if (!global.platformer_crystals[i].collected) {
            if (platformer_puzzle_point_in_rect(player.x + player.width / 2, player.y + player.height / 2, global.platformer_crystals[i].x, global.platformer_crystals[i].y, global.platformer_crystals[i].x + 20, global.platformer_crystals[i].y + 20)) {
                global.platformer_crystals[i].collected = true;
                global.platformer_collected_crystals++;
                play_sfx("puzzle_success");
            }
        }
    }

    global.platformer_player = player;
}

function platformer_puzzle_collides_at(test_x, test_y) {
    for (var i = 0; i < array_length(global.platformer_platforms); i++) {
        var plat = global.platformer_platforms[i];
        if (platformer_puzzle_rect_overlap(
            test_x,
            test_y,
            test_x + global.platformer_player.width,
            test_y + global.platformer_player.height,
            plat.x,
            plat.y,
            plat.x + plat.w,
            plat.y + plat.h
        )) {
            return true;
        }
    }

    return false;
}

function platformer_puzzle_move_axis(amount, is_horizontal) {
    var remaining = amount;
    var player = global.platformer_player;

    while (abs(remaining) > 0) {
        var step = clamp(remaining, -1, 1);
        var next_x = player.x + (is_horizontal ? step : 0);
        var next_y = player.y + (is_horizontal ? 0 : step);

        if (!platformer_puzzle_collides_at(next_x, next_y)) {
            player.x = next_x;
            player.y = next_y;
        } else {
            if (is_horizontal) {
                player.hspeed = 0;
            } else {
                if (step > 0) {
                    player.on_ground = true;
                }
                player.vspeed = 0;
            }
            break;
        }

        remaining -= step;
    }

    global.platformer_player = player;
}

function platformer_puzzle_check_completion() {
    var player = global.platformer_player;
    if (platformer_puzzle_rect_overlap(player.x, player.y, player.x + player.width, player.y + player.height, global.platformer_goal.x, global.platformer_goal.y, global.platformer_goal.x + global.platformer_goal.w, global.platformer_goal.y + global.platformer_goal.h)
        && global.platformer_collected_crystals >= global.platformer_total_crystals) {
        platformer_puzzle_solve();
    }
}

function platformer_puzzle_rect_overlap(x1, y1, x2, y2, x3, y3, x4, y4) {
    return x1 < x4 && x2 > x3 && y1 < y4 && y2 > y3;
}

function platformer_puzzle_point_in_rect(px, py, rx1, ry1, rx2, ry2) {
    return px >= rx1 && px <= rx2 && py >= ry1 && py <= ry2;
}

function platformer_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }

    for (var i = 0; i < array_length(global.platformer_platforms); i++) {
        var plat = global.platformer_platforms[i];
        draw_set_color(c_brown);
        draw_rectangle(plat.x, plat.y, plat.x + plat.w, plat.y + plat.h, true);
    }

    for (var i = 0; i < array_length(global.platformer_crystals); i++) {
        if (!global.platformer_crystals[i].collected) {
            draw_set_color(c_aqua);
            draw_rectangle(global.platformer_crystals[i].x, global.platformer_crystals[i].y, global.platformer_crystals[i].x + 20, global.platformer_crystals[i].y + 20, true);
        }
    }

    draw_set_color(c_gold);
    draw_rectangle(global.platformer_goal.x, global.platformer_goal.y, global.platformer_goal.x + global.platformer_goal.w, global.platformer_goal.y + global.platformer_goal.h, true);

    draw_set_color(c_red);
    draw_rectangle(global.platformer_player.x, global.platformer_player.y, global.platformer_player.x + global.platformer_player.width, global.platformer_player.y + global.platformer_player.height, true);
}

function platformer_puzzle_is_solved() {
    return global.platformer_solved;
}

function platformer_puzzle_solve() {
    global.platformer_solved = true;
    play_sfx("puzzle_completed");
}

function platformer_puzzle_reset_level() {
    global.platformer_player.x = 50;
    global.platformer_player.y = 400;
    global.platformer_player.hspeed = 0;
    global.platformer_player.vspeed = 0;
    global.platformer_player.coyote_timer = 0;
    global.platformer_player.jump_buffer_timer = 0;
    global.platformer_player.on_ground = false;
    global.platformer_collected_crystals = 0;
    for (var i = 0; i < array_length(global.platformer_crystals); i++) {
        global.platformer_crystals[i].collected = false;
    }
    global.platformer_time_remaining = global.platformer_time_limit;
}

function platformer_puzzle_reset() {
    return platformer_puzzle_init();
}
