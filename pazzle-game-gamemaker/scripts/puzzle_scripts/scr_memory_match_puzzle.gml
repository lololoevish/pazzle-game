// Скрипт головоломки "Поиск пар/Память" для GameMaker

function memory_match_puzzle_init() {
    global.memory_grid_size = 4;
    global.memory_symbols = ["A", "B", "C", "D", "E", "F", "G", "H"];
    global.memory_card_grid = array_create(global.memory_grid_size * global.memory_grid_size);
    global.memory_revealed = array_create(global.memory_grid_size * global.memory_grid_size, false);
    global.memory_matched = array_create(global.memory_grid_size * global.memory_grid_size, false);
    global.memory_first_selected = -1;
    global.memory_second_selected = -1;
    global.memory_waiting_second = false;
    global.memory_hide_timer = 0;
    global.memory_solved = false;

    memory_generate_grid();

    return { size: global.memory_grid_size };
}

function memory_generate_grid() {
    var all_symbols = [];
    for (var i = 0; i < array_length(global.memory_symbols); i++) {
        array_push(all_symbols, global.memory_symbols[i]);
        array_push(all_symbols, global.memory_symbols[i]);
    }

    for (var i = array_length(all_symbols) - 1; i > 0; i--) {
        var j = irandom(i);
        var temp = all_symbols[i];
        all_symbols[i] = all_symbols[j];
        all_symbols[j] = temp;
    }

    for (var i = 0; i < global.memory_grid_size * global.memory_grid_size; i++) {
        global.memory_card_grid[i] = all_symbols[i];
        global.memory_revealed[i] = false;
        global.memory_matched[i] = false;
    }
}

function memory_match_puzzle_update() {
    if (global.memory_solved) {
        return;
    }

    if (global.memory_hide_timer > 0) {
        global.memory_hide_timer--;
        if (global.memory_hide_timer <= 0) {
            memory_reset_selection();
        }
        return;
    }

    if (mouse_check_button_pressed(mb_left)) {
        var card_index = memory_get_card_at_position(mouse_x, mouse_y);
        if (card_index != -1) {
            memory_handle_card_click(card_index);
        }
    }
}

function memory_get_card_at_position(mx, my) {
    var card_size = 80;
    var spacing = 10;
    var total_size = global.memory_grid_size * card_size + (global.memory_grid_size - 1) * spacing;
    var start_x = (room_width - total_size) / 2;
    var start_y = (room_height - total_size) / 2;

    var col = floor((mx - start_x) / (card_size + spacing));
    var row = floor((my - start_y) / (card_size + spacing));

    if (col >= 0 && col < global.memory_grid_size && row >= 0 && row < global.memory_grid_size) {
        var index = row * global.memory_grid_size + col;
        if (!global.memory_revealed[index] && !global.memory_matched[index]) {
            return index;
        }
    }

    return -1;
}

function memory_handle_card_click(card_index) {
    if (global.memory_waiting_second) {
        global.memory_second_selected = card_index;
        global.memory_revealed[card_index] = true;

        if (global.memory_card_grid[global.memory_first_selected] == global.memory_card_grid[global.memory_second_selected]) {
            global.memory_matched[global.memory_first_selected] = true;
            global.memory_matched[global.memory_second_selected] = true;
            play_sfx("puzzle_success");
            global.memory_first_selected = -1;
            global.memory_second_selected = -1;
            global.memory_waiting_second = false;
            memory_check_completion();
        } else {
            play_sfx("cancel");
            global.memory_hide_timer = 20;
            global.memory_waiting_second = false;
        }
    } else {
        global.memory_first_selected = card_index;
        global.memory_revealed[card_index] = true;
        global.memory_waiting_second = true;
        play_sfx("interaction");
    }
}

function memory_reset_selection() {
    if (global.memory_first_selected != -1 && global.memory_second_selected != -1) {
        global.memory_revealed[global.memory_first_selected] = false;
        global.memory_revealed[global.memory_second_selected] = false;
    }

    global.memory_first_selected = -1;
    global.memory_second_selected = -1;
    global.memory_hide_timer = 0;
}

function memory_check_completion() {
    for (var i = 0; i < global.memory_grid_size * global.memory_grid_size; i++) {
        if (!global.memory_matched[i]) {
            return;
        }
    }

    memory_match_puzzle_solve();
}

function memory_match_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }

    var card_size = 80;
    var spacing = 10;
    var total_size = global.memory_grid_size * card_size + (global.memory_grid_size - 1) * spacing;
    var start_x = (room_width - total_size) / 2;
    var start_y = (room_height - total_size) / 2;

    for (var row = 0; row < global.memory_grid_size; row++) {
        for (var col = 0; col < global.memory_grid_size; col++) {
            var index = row * global.memory_grid_size + col;
            var x_pos = start_x + col * (card_size + spacing);
            var y_pos = start_y + row * (card_size + spacing);

            if (global.memory_matched[index]) {
                draw_set_color(c_green);
                draw_rectangle(x_pos, y_pos, x_pos + card_size, y_pos + card_size, true);
            } else if (global.memory_revealed[index]) {
                draw_set_color(c_white);
                draw_rectangle(x_pos, y_pos, x_pos + card_size, y_pos + card_size, true);
                draw_set_color(c_black);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(x_pos + card_size / 2, y_pos + card_size / 2, global.memory_card_grid[index]);
            } else {
                draw_set_color(c_blue);
                draw_rectangle(x_pos, y_pos, x_pos + card_size, y_pos + card_size, true);
                draw_set_color(c_white);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(x_pos + card_size / 2, y_pos + card_size / 2, "?");
            }

            draw_set_color(c_black);
            draw_rectangle(x_pos, y_pos, x_pos + card_size, y_pos + card_size, false);
        }
    }
}

function memory_match_puzzle_is_solved() {
    return global.memory_solved;
}

function memory_match_puzzle_solve() {
    global.memory_solved = true;
    play_sfx("puzzle_completed");
}

function memory_match_puzzle_reset() {
    return memory_match_puzzle_init();
}
