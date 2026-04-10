// Скрипт головоломки "Ритм/Паттерн" для GameMaker

function rhythm_puzzle_init() {
    global.rhythm_num_buttons = 4;
    global.rhythm_button_colors = [c_red, c_green, c_blue, c_yellow];
    global.rhythm_sequence = [];
    global.rhythm_player_sequence = [];
    global.rhythm_round = 1;
    global.rhythm_max_round = 8;
    global.rhythm_showing_pattern = false;
    global.rhythm_waiting_input = false;
    global.rhythm_pattern_index = 0;
    global.rhythm_pattern_timer = 0;
    global.rhythm_input_timeout = 120;
    global.rhythm_solved = false;

    rhythm_generate_sequence(global.rhythm_round);

    return { round: global.rhythm_round };
}

function rhythm_generate_sequence(round_num) {
    global.rhythm_sequence = [];
    for (var i = 0; i < round_num; i++) {
        array_push(global.rhythm_sequence, irandom(global.rhythm_num_buttons - 1));
    }
}

function rhythm_puzzle_update() {
    if (global.rhythm_solved) {
        return;
    }

    if (global.rhythm_showing_pattern) {
        global.rhythm_pattern_timer--;
        if (global.rhythm_pattern_timer <= 0) {
            global.rhythm_pattern_index++;
            if (global.rhythm_pattern_index >= array_length(global.rhythm_sequence)) {
                global.rhythm_showing_pattern = false;
                global.rhythm_waiting_input = true;
                global.rhythm_player_sequence = [];
                global.rhythm_input_timeout = 180;
            } else {
                global.rhythm_pattern_timer = 20;
            }
        }
        return;
    }

    if (!global.rhythm_waiting_input) {
        global.rhythm_showing_pattern = true;
        global.rhythm_pattern_index = 0;
        global.rhythm_pattern_timer = 20;
        global.rhythm_player_sequence = [];
        play_sfx("puzzle_success");
        return;
    }

    global.rhythm_input_timeout--;
    if (global.rhythm_input_timeout <= 0) {
        rhythm_reset_round();
        return;
    }

    rhythm_handle_input();
}

function rhythm_handle_input() {
    var button_pressed = -1;

    if (keyboard_check_pressed(vk_1) || keyboard_check_pressed(ord('Q'))) button_pressed = 0;
    else if (keyboard_check_pressed(vk_2) || keyboard_check_pressed(ord('W'))) button_pressed = 1;
    else if (keyboard_check_pressed(vk_3) || keyboard_check_pressed(ord('E'))) button_pressed = 2;
    else if (keyboard_check_pressed(vk_4) || keyboard_check_pressed(ord('R'))) button_pressed = 3;

    if (button_pressed == -1) {
        return;
    }

    array_push(global.rhythm_player_sequence, button_pressed);
    play_sfx("interaction");

    var current_position = array_length(global.rhythm_player_sequence) - 1;
    if (global.rhythm_player_sequence[current_position] != global.rhythm_sequence[current_position]) {
        play_sfx("cancel");
        rhythm_reset_round();
        return;
    }

    if (array_length(global.rhythm_player_sequence) == array_length(global.rhythm_sequence)) {
        if (global.rhythm_round >= global.rhythm_max_round) {
            rhythm_puzzle_solve();
        } else {
            global.rhythm_round++;
            rhythm_generate_sequence(global.rhythm_round);
            global.rhythm_showing_pattern = false;
            global.rhythm_waiting_input = false;
            global.rhythm_pattern_index = 0;
            global.rhythm_pattern_timer = 0;
            global.rhythm_player_sequence = [];
            global.rhythm_input_timeout = 180;
        }
    }
}

function rhythm_reset_round() {
    global.rhythm_waiting_input = false;
    global.rhythm_showing_pattern = false;
    global.rhythm_pattern_index = 0;
    global.rhythm_pattern_timer = 0;
    global.rhythm_player_sequence = [];
    global.rhythm_input_timeout = 180;
}

function rhythm_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }

    var button_size = 80;
    var spacing = 20;
    var total_width = global.rhythm_num_buttons * button_size + (global.rhythm_num_buttons - 1) * spacing;
    var start_x = (room_width - total_width) / 2;
    var y_pos = room_height / 2 - 50;

    for (var i = 0; i < global.rhythm_num_buttons; i++) {
        var x_pos = start_x + i * (button_size + spacing);
        var is_active = global.rhythm_showing_pattern
            && global.rhythm_pattern_index < array_length(global.rhythm_sequence)
            && global.rhythm_sequence[global.rhythm_pattern_index] == i;

        if (is_active) {
            draw_set_color(global.rhythm_button_colors[i]);
        } else {
            draw_set_color(make_color_rgb(
                color_get_red(global.rhythm_button_colors[i]) * 0.5,
                color_get_green(global.rhythm_button_colors[i]) * 0.5,
                color_get_blue(global.rhythm_button_colors[i]) * 0.5
            ));
        }

        draw_set_alpha(is_active ? 1.0 : 0.7);
        draw_rectangle(x_pos, y_pos, x_pos + button_size, y_pos + button_size, true);
        draw_set_color(c_white);
        draw_set_alpha(1.0);
        draw_rectangle(x_pos, y_pos, x_pos + button_size, y_pos + button_size, false);
        draw_text(x_pos + button_size / 2 - 5, y_pos + button_size / 2 - 7, string(i + 1));
    }

    draw_set_color(c_white);
    draw_text(room_width / 2 - 50, y_pos - 30, "Раунд: " + string(global.rhythm_round) + "/" + string(global.rhythm_max_round));
}

function rhythm_puzzle_is_solved() {
    return global.rhythm_solved;
}

function rhythm_puzzle_solve() {
    global.rhythm_solved = true;
    play_sfx("puzzle_completed");
}

function rhythm_puzzle_reset() {
    return rhythm_puzzle_init();
}
