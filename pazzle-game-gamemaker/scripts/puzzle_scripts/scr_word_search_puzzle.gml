// Скрипт головоломки "Поиск слов" для GameMaker

function word_search_puzzle_init() {
    global.word_grid_width = 10;
    global.word_grid_height = 10;
    global.word_letter_grid = array_create(global.word_grid_width * global.word_grid_height, " ");
    global.word_words_to_find = ["ЛАБИРИНТ", "ПАЗЗЛ", "ПЕЩЕРА", "ГОРОД"];
    global.word_found_words = [];
    global.word_drag_start_x = -1;
    global.word_drag_start_y = -1;
    global.word_drag_end_x = -1;
    global.word_drag_end_y = -1;
    global.word_selected_positions = [];
    global.word_solved = false;

    word_generate_grid();

    return { width: global.word_grid_width, height: global.word_grid_height };
}

function word_generate_grid() {
    for (var y = 0; y < global.word_grid_height; y++) {
        for (var x = 0; x < global.word_grid_width; x++) {
            global.word_letter_grid[y * global.word_grid_width + x] = " ";
        }
    }

    for (var i = 0; i < array_length(global.word_words_to_find); i++) {
        word_place_word(global.word_words_to_find[i]);
    }

    for (var y = 0; y < global.word_grid_height; y++) {
        for (var x = 0; x < global.word_grid_width; x++) {
            if (global.word_letter_grid[y * global.word_grid_width + x] == " ") {
                global.word_letter_grid[y * global.word_grid_width + x] = word_get_random_letter();
            }
        }
    }
}

function word_get_random_letter() {
    var letters = "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЫЬЭЮЯ";
    return string_char_at(letters, irandom_range(1, string_length(letters)));
}

function word_place_word(word) {
    var attempts = 0;
    while (attempts < 100) {
        attempts++;
        var direction = irandom_range(0, 3);
        var start_x = 0;
        var start_y = 0;
        var word_len = string_length(word);

        switch (direction) {
            case 0:
                start_x = irandom_range(0, global.word_grid_width - word_len);
                start_y = irandom_range(0, global.word_grid_height - 1);
                break;
            case 1:
                start_x = irandom_range(0, global.word_grid_width - 1);
                start_y = irandom_range(0, global.word_grid_height - word_len);
                break;
            case 2:
                start_x = irandom_range(0, global.word_grid_width - word_len);
                start_y = irandom_range(0, global.word_grid_height - word_len);
                break;
            case 3:
                start_x = irandom_range(0, global.word_grid_width - word_len);
                start_y = irandom_range(word_len - 1, global.word_grid_height - 1);
                break;
        }

        if (word_can_place_word(word, start_x, start_y, direction)) {
            for (var i = 0; i < word_len; i++) {
                var pos_x = start_x;
                var pos_y = start_y;
                switch (direction) {
                    case 0: pos_x += i; break;
                    case 1: pos_y += i; break;
                    case 2: pos_x += i; pos_y += i; break;
                    case 3: pos_x += i; pos_y -= i; break;
                }
                global.word_letter_grid[pos_y * global.word_grid_width + pos_x] = string_char_at(word, i + 1);
            }
            return;
        }
    }
}

function word_can_place_word(word, start_x, start_y, direction) {
    for (var i = 0; i < string_length(word); i++) {
        var pos_x = start_x;
        var pos_y = start_y;

        switch (direction) {
            case 0: pos_x += i; break;
            case 1: pos_y += i; break;
            case 2: pos_x += i; pos_y += i; break;
            case 3: pos_x += i; pos_y -= i; break;
        }

        if (pos_x < 0 || pos_x >= global.word_grid_width || pos_y < 0 || pos_y >= global.word_grid_height) {
            return false;
        }

        var current_char = global.word_letter_grid[pos_y * global.word_grid_width + pos_x];
        var target_char = string_char_at(word, i + 1);
        if (current_char != " " && current_char != target_char) {
            return false;
        }
    }

    return true;
}

function word_search_puzzle_update() {
    if (global.word_solved) {
        return;
    }

    word_handle_mouse_input();
}

function word_handle_mouse_input() {
    var cell_size = 32;
    var offset_x = (room_width - global.word_grid_width * cell_size) / 2;
    var offset_y = (room_height - global.word_grid_height * cell_size) / 2;

    if (mouse_check_button_pressed(mb_left)) {
        var gx = floor((mouse_x - offset_x) / cell_size);
        var gy = floor((mouse_y - offset_y) / cell_size);
        if (gx >= 0 && gx < global.word_grid_width && gy >= 0 && gy < global.word_grid_height) {
            global.word_drag_start_x = gx;
            global.word_drag_start_y = gy;
        }
    }

    if (mouse_check_button_released(mb_left) && global.word_drag_start_x != -1) {
        var gx = floor((mouse_x - offset_x) / cell_size);
        var gy = floor((mouse_y - offset_y) / cell_size);
        if (gx >= 0 && gx < global.word_grid_width && gy >= 0 && gy < global.word_grid_height) {
            word_check_word(global.word_drag_start_x, global.word_drag_start_y, gx, gy);
        }
        global.word_drag_start_x = -1;
        global.word_drag_start_y = -1;
    }
}

function word_check_word(start_x, start_y, end_x, end_y) {
    if (start_x != end_x && start_y != end_y && abs(start_x - end_x) != abs(start_y - end_y)) {
        return;
    }

    var letters = "";
    var positions = [];
    var step_x = sign(end_x - start_x);
    var step_y = sign(end_y - start_y);
    var x = start_x;
    var y = start_y;

    while (true) {
        letters += global.word_letter_grid[y * global.word_grid_width + x];
        array_push(positions, [x, y]);
        if (x == end_x && y == end_y) {
            break;
        }
        x += step_x;
        y += step_y;
    }

    var reversed = "";
    for (var i = string_length(letters); i >= 1; i--) {
        reversed += string_char_at(letters, i);
    }

    for (var i = 0; i < array_length(global.word_words_to_find); i++) {
        var target_word = global.word_words_to_find[i];
        if ((letters == target_word || reversed == target_word) && !word_array_contains(global.word_found_words, target_word)) {
            array_push(global.word_found_words, target_word);
            global.word_selected_positions = positions;
            play_sfx("puzzle_success");
            if (array_length(global.word_found_words) == array_length(global.word_words_to_find)) {
                word_search_puzzle_solve();
            }
            return;
        }
    }

    play_sfx("cancel");
}

function word_search_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }

    var cell_size = 32;
    var offset_x = (room_width - global.word_grid_width * cell_size) / 2;
    var offset_y = (room_height - global.word_grid_height * cell_size) / 2;

    for (var y = 0; y < global.word_grid_height; y++) {
        for (var x = 0; x < global.word_grid_width; x++) {
            var screen_x = offset_x + x * cell_size;
            var screen_y = offset_y + y * cell_size;
            var is_selected = word_array_contains_position(global.word_selected_positions, x, y);

            draw_set_color(is_selected ? c_lightblue : c_white);
            draw_rectangle(screen_x, screen_y, screen_x + cell_size, screen_y + cell_size, true);
            draw_set_color(c_black);
            draw_rectangle(screen_x, screen_y, screen_x + cell_size, screen_y + cell_size, false);
            draw_text(screen_x + cell_size / 2 - 6, screen_y + cell_size / 2 - 8, global.word_letter_grid[y * global.word_grid_width + x]);
        }
    }

    var list_offset_x = offset_x + global.word_grid_width * cell_size + 20;
    draw_set_color(c_black);
    draw_text(list_offset_x, offset_y, "Слова для поиска:");
    for (var i = 0; i < array_length(global.word_words_to_find); i++) {
        draw_set_color(word_array_contains(global.word_found_words, global.word_words_to_find[i]) ? c_green : c_black);
        draw_text(list_offset_x, offset_y + (i + 1) * 20, global.word_words_to_find[i]);
    }
}

function word_array_contains(arr, value) {
    for (var i = 0; i < array_length(arr); i++) {
        if (arr[i] == value) {
            return true;
        }
    }
    return false;
}

function word_array_contains_position(arr, x, y) {
    for (var i = 0; i < array_length(arr); i++) {
        if (arr[i][0] == x && arr[i][1] == y) {
            return true;
        }
    }
    return false;
}

function word_search_puzzle_is_solved() {
    return global.word_solved;
}

function word_search_puzzle_solve() {
    global.word_solved = true;
    play_sfx("puzzle_completed");
}

function word_search_puzzle_reset() {
    return word_search_puzzle_init();
}
