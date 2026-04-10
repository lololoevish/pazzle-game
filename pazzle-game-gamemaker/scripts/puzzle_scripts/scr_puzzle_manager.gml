// Менеджер головоломок для GameMaker

function init_puzzle_manager() {
    global.puzzle_manager_initialized = true;
}

function create_puzzle(type) {
    switch (type) {
        case "maze":
            return maze_puzzle_init();
        case "word_search":
            return word_search_puzzle_init();
        case "rhythm":
            return rhythm_puzzle_init();
        case "pairs":
            return memory_match_puzzle_init();
        case "platformer":
            return platformer_puzzle_init();
        case "final":
            return final_challenge_puzzle_init();
        case "riddle":
            return riddle_puzzle_init();
        case "sound_trap":
            return sound_trap_puzzle_init();
        default:
            show_debug_message("Unknown puzzle type: " + string(type));
            return undefined;
    }
}

function update_puzzle(type) {
    switch (type) {
        case "maze":
            maze_puzzle_update();
            break;
        case "word_search":
            word_search_puzzle_update();
            break;
        case "rhythm":
            rhythm_puzzle_update();
            break;
        case "pairs":
            memory_match_puzzle_update();
            break;
        case "platformer":
            platformer_puzzle_update();
            break;
        case "final":
            final_challenge_puzzle_update();
            break;
        case "riddle":
            riddle_puzzle_update();
            break;
        case "sound_trap":
            sound_trap_puzzle_update();
            break;
    }
}

function draw_puzzle(type, gui_view) {
    switch (type) {
        case "maze":
            maze_puzzle_draw(gui_view);
            break;
        case "word_search":
            word_search_puzzle_draw(gui_view);
            break;
        case "rhythm":
            rhythm_puzzle_draw(gui_view);
            break;
        case "riddle":
            riddle_puzzle_draw(gui_view);
            break;
        case "sound_trap":
            sound_trap_puzzle_draw(gui_view);
            break;
        case "pairs":
            memory_match_puzzle_draw(gui_view);
            break;
        case "platformer":
            platformer_puzzle_draw(gui_view);
            break;
        case "final":
            final_challenge_puzzle_draw(gui_view);
            break;
    }
}

function is_puzzle_solved(type) {
    switch (type) {
        case "maze":
            return maze_puzzle_is_solved();
        case "word_search":
            return word_search_puzzle_is_solved();
        case "rhythm":
            return rhythm_puzzle_is_solved();
        case "pairs":
            return memory_match_puzzle_is_solved();
        case "platformer":
            return platformer_puzzle_is_solved();
        case "final":
            return final_challenge_puzzle_is_solved();
        default:
            return false;
    }
}

function reset_puzzle(type) {
    switch (type) {
        case "maze":
            return maze_puzzle_reset();
        case "word_search":
            return word_search_puzzle_reset();
        case "rhythm":
            return rhythm_puzzle_reset();
        case "pairs":
            return memory_match_puzzle_reset();
        case "platformer":
            return platformer_puzzle_reset();
        case "final":
            return final_challenge_puzzle_reset();
        default:
            return undefined;
    }
}

function destroy_puzzle_manager() {
    global.puzzle_manager_initialized = false;
}
