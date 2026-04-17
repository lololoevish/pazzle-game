// Скрипт финальной головоломки для GameMaker

function final_challenge_puzzle_init() {
    global.final_player = {
        x: 50,
        y: 550,
        width: 20,
        height: 20,
        speed: 5,
        hspeed: 0,
        vspeed: 0,
        gravity: 0.6,
        jump_strength: -12,
        on_ground: true
    };

    global.final_artifacts = [
        {x: 200, y: 500, collected: false},
        {x: 400, y: 400, collected: false},
        {x: 600, y: 300, collected: false},
        {x: 300, y: 200, collected: false},
        {x: 500, y: 100, collected: false}
    ];

    global.final_obstacles = [
        {x: 150, y: 450, width: 30, height: 10, hspd: 2, start_x: 150, end_x: 250},
        {x: 350, y: 350, width: 25, height: 10, hspd: -1.5, start_x: 300, end_x: 400},
        {x: 550, y: 250, width: 35, height: 10, hspd: 2.5, start_x: 500, end_x: 600},
        {x: 250, y: 150, width: 20, height: 10, hspd: -2, start_x: 200, end_x: 300}
    ];

    global.final_goal = {x: 700, y: 50, w: 40, h: 40};
    global.final_platforms = [
        {x: 0, y: 580, w: 800, h: 20},
        {x: 100, y: 500, w: 100, h: 10},
        {x: 300, y: 400, w: 100, h: 10},
        {x: 500, y: 300, w: 100, h: 10},
        {x: 200, y: 200, w: 100, h: 10},
        {x: 400, y: 100, w: 100, h: 10}
    ];

    global.final_collected_artifacts = 0;
    global.final_total_artifacts = array_length(global.final_artifacts);
    global.final_time_limit = 3600;
    global.final_time_remaining = global.final_time_limit;
    global.final_difficulty_factor = 1.0;
    global.final_solved = false;

    return { total: global.final_total_artifacts };
}

function final_challenge_puzzle_update() {
    if (global.final_solved) {
        return;
    }

    global.final_time_remaining--;
    if (global.final_time_remaining <= 0) {
        final_challenge_reset_level();
        return;
    }

    final_challenge_handle_player_movement();
    final_challenge_update_player_physics();
    final_challenge_update_obstacles();
    final_challenge_check_collisions();
    final_challenge_check_completion();
}

function final_challenge_handle_player_movement() {
    global.final_player.hspeed = 0;
    if (keyboard_check(vk_right) || keyboard_check(ord('D'))) {
        global.final_player.hspeed = global.final_player.speed * global.final_difficulty_factor;
    }
    if (keyboard_check(vk_left) || keyboard_check(ord('A'))) {
        global.final_player.hspeed = -global.final_player.speed * global.final_difficulty_factor;
    }

    if ((keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord('W'))) && global.final_player.on_ground) {
        global.final_player.vspeed = global.final_player.jump_strength;
        global.final_player.on_ground = false;
        play_sfx("interaction");
    }
}

function final_challenge_update_player_physics() {
    global.final_player.vspeed += global.final_player.gravity * global.final_difficulty_factor;
    final_challenge_move_axis(global.final_player.hspeed, true);
    global.final_player.on_ground = false;
    final_challenge_move_axis(global.final_player.vspeed, false);

    if (global.final_player.x < 0) global.final_player.x = 0;
    if (global.final_player.x + global.final_player.width > room_width) global.final_player.x = room_width - global.final_player.width;
    if (global.final_player.y < 0) {
        global.final_player.y = 0;
        global.final_player.vspeed = max(0, global.final_player.vspeed);
    }
    if (global.final_player.y > room_height + global.final_player.height) {
        final_challenge_reset_player_position();
    }
}

function final_challenge_update_obstacles() {
    for (var i = 0; i < array_length(global.final_obstacles); i++) {
        global.final_obstacles[i].x += global.final_obstacles[i].hspd;
        if (global.final_obstacles[i].x <= global.final_obstacles[i].start_x || global.final_obstacles[i].x + global.final_obstacles[i].width >= global.final_obstacles[i].end_x) {
            global.final_obstacles[i].hspd = -global.final_obstacles[i].hspd;
        }
    }
}

function final_challenge_check_collisions() {
    for (var i = 0; i < array_length(global.final_artifacts); i++) {
        if (!global.final_artifacts[i].collected) {
            if (final_challenge_point_in_rect(global.final_player.x + global.final_player.width / 2, global.final_player.y + global.final_player.height / 2, global.final_artifacts[i].x, global.final_artifacts[i].y, global.final_artifacts[i].x + 20, global.final_artifacts[i].y + 20)) {
                global.final_artifacts[i].collected = true;
                global.final_collected_artifacts++;
                global.final_difficulty_factor = 1.0 + global.final_collected_artifacts * 0.1;
                play_sfx("puzzle_success");
            }
        }
    }

    for (var i = 0; i < array_length(global.final_obstacles); i++) {
        if (final_challenge_rect_overlap(global.final_player.x, global.final_player.y, global.final_player.x + global.final_player.width, global.final_player.y + global.final_player.height, global.final_obstacles[i].x, global.final_obstacles[i].y, global.final_obstacles[i].x + global.final_obstacles[i].width, global.final_obstacles[i].y + global.final_obstacles[i].height)) {
            final_challenge_reset_player_position();
            play_sfx("cancel");
        }
    }
}

function final_challenge_collides_at(test_x, test_y) {
    for (var i = 0; i < array_length(global.final_platforms); i++) {
        var plat = global.final_platforms[i];
        if (final_challenge_rect_overlap(
            test_x,
            test_y,
            test_x + global.final_player.width,
            test_y + global.final_player.height,
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

function final_challenge_move_axis(amount, is_horizontal) {
    var remaining = amount;

    while (abs(remaining) > 0) {
        var step = clamp(remaining, -1, 1);
        var next_x = global.final_player.x + (is_horizontal ? step : 0);
        var next_y = global.final_player.y + (is_horizontal ? 0 : step);

        if (!final_challenge_collides_at(next_x, next_y)) {
            global.final_player.x = next_x;
            global.final_player.y = next_y;
        } else {
            if (is_horizontal) {
                global.final_player.hspeed = 0;
            } else {
                if (step > 0) {
                    global.final_player.on_ground = true;
                }
                global.final_player.vspeed = 0;
            }
            break;
        }

        remaining -= step;
    }
}

function final_challenge_reset_player_position() {
    global.final_player.x = 50;
    global.final_player.y = 550;
    global.final_player.hspeed = 0;
    global.final_player.vspeed = 0;
    global.final_player.on_ground = false;
}

function final_challenge_check_completion() {
    if (final_challenge_rect_overlap(global.final_player.x, global.final_player.y, global.final_player.x + global.final_player.width, global.final_player.y + global.final_player.height, global.final_goal.x, global.final_goal.y, global.final_goal.x + global.final_goal.w, global.final_goal.y + global.final_goal.h)
        && global.final_collected_artifacts >= global.final_total_artifacts) {
        final_challenge_puzzle_solve();
    }
}

function final_challenge_rect_overlap(x1, y1, x2, y2, x3, y3, x4, y4) {
    return x1 < x4 && x2 > x3 && y1 < y4 && y2 > y3;
}

function final_challenge_point_in_rect(px, py, rx1, ry1, rx2, ry2) {
    return px >= rx1 && px <= rx2 && py >= ry1 && py <= ry2;
}

function final_challenge_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }

    draw_set_color(c_gray);
    for (var i = 0; i < array_length(global.final_platforms); i++) {
        draw_rectangle(global.final_platforms[i].x, global.final_platforms[i].y, global.final_platforms[i].x + global.final_platforms[i].w, global.final_platforms[i].y + global.final_platforms[i].h, true);
    }

    draw_set_color(c_orange);
    for (var i = 0; i < array_length(global.final_obstacles); i++) {
        draw_rectangle(global.final_obstacles[i].x, global.final_obstacles[i].y, global.final_obstacles[i].x + global.final_obstacles[i].width, global.final_obstacles[i].y + global.final_obstacles[i].height, true);
    }

    draw_set_color(c_purple);
    for (var i = 0; i < array_length(global.final_artifacts); i++) {
        if (!global.final_artifacts[i].collected) {
            draw_rectangle(global.final_artifacts[i].x, global.final_artifacts[i].y, global.final_artifacts[i].x + 20, global.final_artifacts[i].y + 20, true);
        }
    }

    draw_set_color(c_lime);
    draw_rectangle(global.final_goal.x, global.final_goal.y, global.final_goal.x + global.final_goal.w, global.final_goal.y + global.final_goal.h, true);

    draw_set_color(c_red);
    draw_rectangle(global.final_player.x, global.final_player.y, global.final_player.x + global.final_player.width, global.final_player.y + global.final_player.height, true);
}

function final_challenge_puzzle_is_solved() {
    return global.final_solved;
}

function final_challenge_puzzle_solve() {
    global.final_solved = true;
    play_sfx("puzzle_completed");
}

function final_challenge_reset_level() {
    final_challenge_reset_player_position();
    global.final_collected_artifacts = 0;
    global.final_difficulty_factor = 1.0;
    for (var i = 0; i < array_length(global.final_artifacts); i++) {
        global.final_artifacts[i].collected = false;
    }
    for (var i = 0; i < array_length(global.final_obstacles); i++) {
        global.final_obstacles[i].x = global.final_obstacles[i].start_x;
    }
    global.final_time_remaining = global.final_time_limit;
}

function final_challenge_puzzle_reset() {
    return final_challenge_puzzle_init();
}
