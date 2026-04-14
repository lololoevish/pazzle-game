// Скрипт головоломки "Двенадцатый Подвиг" для GameMaker
// Финальное испытание с каламбуром номера 12 и эпичностью

function epic_finale_puzzle_init() {
    // Подготовка к эпическому финалу
    global.epic_finale_sequence = [
        { challenge: "Сила", completed: false, hint: "Преодолейте искушение использовать силу" },
        { challenge: "Мудрость", completed: false, hint: "Выберите путь знаний" },
        { challenge: "Сострадание", completed: false, hint: "Проявите милосердие к противнику" },
        { challenge: "Самопожертвование", completed: false, hint: "Откажитесь от выгоды ради других" },
        { challenge: "Единство", completed: false, hint: "Найдите общий язык" },
        { challenge: "Терпение", completed: false, hint: "Подождите нужный момент" },
        { challenge: "Смелость", completed: false, hint: "Ступите в неизвестность" },
        { challenge: "Справедливость", completed: false, hint: "Примите беспристрастное решение" },
        { challenge: "Надежда", completed: false, hint: "Не теряйте веру" },
        { challenge: "Истинность", completed: false, hint: "Скажите правду, даже если больно" },
        { challenge: "Миротворчество", completed: false, hint: "Примирите враждующих" },
        { challenge: "Преображение", completed: false, hint: "Станьте лучше, чем были" }
    ];
    
    global.epic_finale_current_challenge = 0;
    global.epic_finale_completed_challenges = 0;
    global.epic_finale_total_challenges = 12; // 12 подвигов
    global.epic_finale_player_choices = [];
    global.epic_finale_solved = false;
    global.epic_finale_timer = 0;
    global.epic_finale_max_time = 3600; // 1 минута на прохождение
    
    // Используем элементы "дружбы" из Deltarune механик
    global.player_mercy_points = (global.player_mercy_points != undefined) ? global.player_mercy_points : 0;
    
    return { challenges: global.epic_finale_total_challenges, name: "Двенадцатый Подвиг" };
}

function epic_finale_puzzle_update() {
    if (global.epic_finale_solved) {
        return;
    }
    
    // Уменьшаем таймер
    global.epic_finale_timer++;
    
    if (global.epic_finale_timer > global.epic_finale_max_time) {
        // Время истекло, сброс
        epic_finale_reset_level();
        return;
    }
    
    // Обработка выбора игрока
    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord('A'))) {
        epic_finale_make_choice("left");
    } else if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord('D'))) {
        epic_finale_make_choice("right");
    } else if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) {
        epic_finale_make_choice("mercy"); // Действие милосердия
    }
}

function epic_finale_make_choice(choice_type) {
    var current_challenge = global.epic_finale_sequence[global.epic_finale_current_challenge];
    
    // В зависимости от выбора игрока и текущего испытания
    var result = evaluate_choice(current_challenge, choice_type);
    
    if (result.success) {
        current_challenge.completed = true;
        global.epic_finale_completed_challenges++;
        
        // За успешное прохождение искушения добавляем очки милосердия
        global.player_mercy_points += 2;
        
        // Воспроизвести звук успеха
        if (script_exists(play_event_sound)) {
            play_event_sound("friendship_gained");
        }
        
        global.epic_finale_current_challenge++;
        
        if (global.epic_finale_current_challenge >= global.epic_finale_total_challenges) {
            // Все 12 подвигов пройдены
            epic_finale_puzzle_solve();
        }
    } else {
        // Неудача, но не фатальная - учимся на ошибках
        if (script_exists(play_event_sound)) {
            play_event_sound("npc_friendly_response");
        }
        
        // Добавляем небольшой штраф или требуем повторить
        // Вместо полного сброса, просто даем подсказку и продолжаем
        show_debug_message("Подсказка: " + current_challenge.hint);
    }
    
    // Сохраняем выбор игрока
    var player_choice = {
        challenge: global.epic_finale_current_challenge,
        choice: choice_type,
        timestamp: global.epic_finale_timer
    };
    
    array_push(global.epic_finale_player_choices, player_choice);
}

function evaluate_choice(challenge, choice_type) {
    // В реальном пазле была бы сложная логика, здесь упрощенная
    // Используем комбинацию навыков игрока (включая mercy points) для оценки
    var success_chance = 0.7; // 70% шанс успеха по умолчанию
    
    // Увеличиваем шанс успеха за счет mercy points
    success_chance += (global.player_mercy_points * 0.02); // +2% за каждое очко милосердия
    
    // Некоторые выборы (mercy) могут быть особенно эффективны для некоторых вызовов
    if (choice_type == "mercy") {
        switch (challenge.challenge) {
            case "Сострадание":
            case "Самопожертвование":
            case "Миротворчество":
                success_chance = min(success_chance + 0.2, 1.0); // +20% бонус
                break;
        }
    }
    
    return { success: random(1) < success_chance };
}

function epic_finale_reset_level() {
    global.epic_finale_current_challenge = 0;
    global.epic_finale_completed_challenges = 0;
    global.epic_finale_timer = 0;
    
    for (var i = 0; i < array_length(global.epic_finale_sequence); i++) {
        global.epic_finale_sequence[i].completed = false;
    }
}

function epic_finale_puzzle_draw(gui_view) {
    if (gui_view) {
        return;
    }
    
    draw_set_color(c_white);
    
    // Заголовок с каламбуром
    draw_set_font(global.fnt_default);
    draw_set_halign(fa_center);
    draw_text(room_width / 2, 50, "Двенадцатый Подвиг");
    draw_set_halign(fa_left);
    
    // Отображение текущего вызова
    if (global.epic_finale_current_challenge < global.epic_finale_total_challenges) {
        var current_challenge = global.epic_finale_sequence[global.epic_finale_current_challenge];
        draw_text(50, 100, "Испытание #" + string(global.epic_finale_current_challenge + 1) + ": " + current_challenge.challenge);
        draw_text(50, 120, "Подсказка: " + current_challenge.hint);
        
        // Отображение выборов
        draw_text(50, 160, "[A/←] Левый путь");
        draw_text(50, 180, "[D/→] Правый путь");
        draw_text(50, 200, "[SPACE/ENTER] Показать милосердие");
    } else {
        draw_text(50, 100, "Все двенадцать подвигов пройдены!");
    }
    
    // Статистика
    draw_text(50, 240, "Пройдено: " + string(global.epic_finale_completed_challenges) + "/" + string(global.epic_finale_total_challenges));
    draw_text(50, 260, "Очки милосердия: " + string(global.player_mercy_points));
    draw_text(50, 280, "Времени прошло: " + string(floor(global.epic_finale_timer / 60)) + " сек");
    
    draw_set_color(c_yellow);
    draw_text(50, 320, "Наследие Экспедиции: " + string(global.player_mercy_points) + " сердец доброты собрано");
}

function epic_finale_puzzle_is_solved() {
    return global.epic_finale_solved;
}

function epic_finale_puzzle_solve() {
    global.epic_finale_solved = true;
    global.expedition_complete = true; // Отметить завершение экспедиции
    
    // Воспроизвести финальный звук
    if (script_exists(play_event_sound)) {
        play_event_sound("puzzle_completed");
        play_event_sound("friendship_gained");
    }
    
    // Завершить экспедицию
    if (script_exists(complete_level)) {
        complete_level(12);
    }
    
    show_debug_message("Поздравляем! Вы прошли Двенадцатый Подвиг и завершили Экспедицию!");
}

function epic_finale_puzzle_reset() {
    return epic_finale_puzzle_init();
}