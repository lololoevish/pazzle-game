// Скрипт головоломки "Загадки Сфинкса" для GameMaker

function riddle_puzzle_init() {
    global.riddles = [
        {question: "Что ходит утром на четырёх ногах, днём на двух, а вечером на трёх?", answer: "человек", solved: false},
        {question: "Что выше леса, но легче пера?", answer: "дым", solved: false},
        {question: "Что может путешествовать по свету, оставаясь в углу?", answer: "марка", solved: false},
        {question: "Что имеет лицо, но не может видеть?", answer: "монета", solved: false},
        {question: "Что всегда идёт, но никогда не приходит?", answer: "время", solved: false}
    ];
    
    global.riddle_current_index = 0;
    global.riddle_player_answers = [];
    global.riddle_correct_count = 0;
    global.riddle_max_attempts = 3;
    global.riddle_current_attempts = 0;
    global.riddle_solved = false;
    
    return { total: array_length(global.riddles) };
}

function riddle_puzzle_update() {
    if (global.riddle_solved) {
        return;
    }
    
    // Обработка ввода ответа от игрока
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord(' '))) {
        riddle_submit_answer();
    }
}

function riddle_submit_answer() {
    // Здесь будет обработка ответа игрока
    // Псевдокод для обработки введенного ответа
    var player_input = global.current_player_input; // предполагаем, что ввод откуда-то поступает
    if (player_input != undefined && string_length(player_input) > 0) {
        var current_riddle = global.riddles[global.riddle_current_index];
        if (string_lower(string_trim(player_input)) == string_lower(current_riddle.answer)) {
            current_riddle.solved = true;
            global.riddle_correct_count++;
            
            // Воспроизведение звука успеха
            if (script_exists(play_event_sound)) {
                play_event_sound("puzzle_success");
            }
            
            // Переход к следующей загадке
            global.riddle_current_index++;
            
            if (global.riddle_current_index >= array_length(global.riddles)) {
                // Все загадки решены
                riddle_puzzle_solve();
            } else {
                // Сброс попыток для следующей загадки
                global.riddle_current_attempts = 0;
            }
        } else {
            global.riddle_current_attempts++;
            
            // Воспроизведение звука ошибки
            if (script_exists(play_event_sound)) {
                play_event_sound("cancel");
            }
            
            if (global.riddle_current_attempts >= global.riddle_max_attempts) {
                // Слишком много попыток, сброс уровня
                riddle_reset_level();
            }
        }
        
        // Очистка ввода
        if (global.current_player_input != undefined) {
            global.current_player_input = "";
        }
    }
}

function riddle_reset_level() {
    global.riddle_current_index = 0;
    global.riddle_current_attempts = 0;
    global.riddle_correct_count = 0;
    
    // Сброс состояния загадок
    for (var i = 0; i < array_length(global.riddles); i++) {
        global.riddles[i].solved = false;
    }
}

function riddle_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }
    
    // Рисование текущей загадки
    draw_set_color(c_white);
    var current_riddle = global.riddles[global.riddle_current_index];
    var question_text = "Загадка " + string(global.riddle_current_index + 1) + ": " + current_riddle.question;
    
    draw_text(50, 100, question_text);
    draw_text(50, 120, "Попыток осталось: " + string(global.riddle_max_attempts - global.riddle_current_attempts));
    draw_text(50, 140, "Решено загадок: " + string(global.riddle_correct_count) + "/" + string(array_length(global.riddles)));
    
    // Показ ввода игрока
    if (global.current_player_input != undefined) {
        draw_text(50, 160, "Ваш ответ: " + global.current_player_input);
    }
    
    draw_set_color(c_yellow);
    draw_text(50, 180, "[Нажмите ENTER для подтверждения]");
}

function riddle_puzzle_is_solved() {
    return global.riddle_solved;
}

function riddle_puzzle_solve() {
    global.riddle_solved = true;
    if (script_exists(play_event_sound)) {
        play_event_sound("puzzle_completed");
    }
}

function riddle_puzzle_reset() {
    return riddle_puzzle_init();
}