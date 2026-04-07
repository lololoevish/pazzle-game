// Скрипт финальной головоломки для GameMaker

// Функция инициализации финальной головоломки
function init() {
    // Параметры игрока
    player = {
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
    
    // Артефакты для сбора
    artifacts = [
        {x: 200, y: 500, collected: false},
        {x: 400, y: 400, collected: false},
        {x: 600, y: 300, collected: false},
        {x: 300, y: 200, collected: false},
        {x: 500, y: 100, collected: false}
    ];
    
    // Препятствия (движущиеся платформы или враги)
    obstacles = [
        {x: 150, y: 450, width: 30, height: 10, hspd: 2, vspd: 0, start_x: 150, end_x: 250},  // Движущаяся платформа
        {x: 350, y: 350, width: 25, height: 10, hspd: -1.5, vspd: 0, start_x: 300, end_x: 400},
        {x: 550, y: 250, width: 35, height: 10, hspd: 2.5, vspd: 0, start_x: 500, end_x: 600},
        {x: 250, y: 150, width: 20, height: 10, hspd: -2, vspd: 0, start_x: 200, end_x: 300}
    ];
    
    // Цель (выход с уровня)
    goal = {x: 700, y: 50, w: 40, h: 40};
    
    // Платформы
    platforms = [
        {x: 0, y: 580, w: 800, h: 20},     // Пол
        {x: 100, y: 500, w: 100, h: 10},   // Платформа 1
        {x: 300, y: 400, w: 100, h: 10},   // Платформа 2
        {x: 500, y: 300, w: 100, h: 10},   // Платформа 3
        {x: 200, y: 200, w: 100, h: 10},   // Платформа 4
        {x: 400, y: 100, w: 100, h: 10}    // Платформа 5
    ];
    
    // Состояние
    collected_artifacts = 0;
    total_artifacts = array_length_1d(artifacts);
    solved = false;
    
    // Таймер для финальной головоломки
    time_limit = 3600; // 60 секунд
    time_remaining = time_limit;
    
    // Сложность (увеличивается с каждым собранным артефактом)
    difficulty_factor = 1.0;
    
    return {
        player: player,
        artifacts: artifacts,
        obstacles: obstacles,
        platforms: platforms,
        goal: goal,
        collected: collected_artifacts,
        total: total_artifacts,
        time: time_remaining
    };
}

// Функция обновления логики головоломки
function update() {
    if (!solved) {
        // Обновляем таймер
        time_remaining--;
        if (time_remaining <= 0) {
            // Время вышло, сбрасываем уровень
            reset_level();
            return;
        }
        
        // Обработка движения игрока
        handle_player_movement();
        
        // Обновление физики игрока
        update_player_physics();
        
        // Обновление препятствий
        update_obstacles();
        
        // Проверка столкновений
        check_collisions();
        
        // Проверка завершения
        check_completion();
    }
}

// Функция обработки движения игрока
function handle_player_movement() {
    // Горизонтальное движение
    player.hspeed = 0;
    if (keyboard_check(vk_right) || keyboard_check(ord('D'))) {
        player.hspeed = player.speed * difficulty_factor;
    }
    if (keyboard_check(vk_left) || keyboard_check(ord('A'))) {
        player.hspeed = -player.speed * difficulty_factor;
    }
    
    // Прыжок
    if ((keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord('W'))) && player.on_ground) {
        player.vspeed = player.jump_strength;
        player.on_ground = false;
        play_sfx("interaction");
    }
}

// Функция обновления физики игрока
function update_player_physics() {
    // Применяем гравитацию
    player.vspeed += player.gravity * difficulty_factor;
    
    // Обновляем позицию
    player.x += player.hspeed;
    player.y += player.vspeed;
    
    // Проверяем границы комнаты
    if (player.x < 0) player.x = 0;
    if (player.x + player.width > room_width) player.x = room_width - player.width;
    if (player.y < 0) player.y = 0;
    if (player.y > room_height) {
        // Игрок упал, сбрасываем позицию
        reset_player_position();
    }
}

// Функция обновления препятствий
function update_obstacles() {
    var i;
    for (i = 0; i < array_length_1d(obstacles); i++) {
        var obs = obstacles[i];
        
        // Двигаем препятствие
        obs.x += obs.hspd;
        
        // Обрабатываем отскок от границ
        if (obs.x <= obs.start_x || obs.x + obs.width >= obs.end_x) {
            obs.hspd = -obs.hspd;
        }
    }
}

// Функция проверки коллизий
function check_collisions() {
    // Сбрасываем состояние пола
    player.on_ground = false;
    
    // Проверяем столкновения с платформами
    var i;
    for (i = 0; i < array_length_1d(platforms); i++) {
        var plat = platforms[i];
        
        // Проверяем столкновение с платформой сверху (при падении)
        if (player.x + player.width > plat.x && 
            player.x < plat.x + plat.w &&
            player.y + player.height > plat.y && 
            player.y + player.height < plat.y + plat.h &&
            player.vspeed >= 0) { // Только если падаем
            
            player.y = plat.y - player.height;
            player.vspeed = 0;
            player.on_ground = true;
        }
        // Проверяем столкновения со всех сторон
        else if (rectangle_in_rectangle(player.x, player.y, player.x + player.width, player.y + player.height,
                                        plat.x, plat.y, plat.x + plat.w, plat.y + plat.h)) {
            // Столкновение сбоку или снизу
            if (player.hspeed > 0) { // Движемся вправо
                player.x = plat.x - player.width;
            } else if (player.hspeed < 0) { // Движемся влево
                player.x = plat.x + plat.w;
            } else if (player.vspeed < 0) { // Движемся вверх
                player.y = plat.y + plat.h;
                player.vspeed = 0;
            }
        }
    }
    
    // Проверяем столкновения с артефактами
    for (i = 0; i < array_length_1d(artifacts); i++) {
        if (!artifacts[i].collected) {
            if (point_in_rectangle(player.x + player.width/2, player.y + player.height/2,
                                  artifacts[i].x, artifacts[i].y, 
                                  artifacts[i].x + 20, artifacts[i].y + 20)) {
                // Собрали артефакт
                artifacts[i].collected = true;
                collected_artifacts++;
                
                // Увеличиваем сложность с каждым собранным артефактом
                difficulty_factor = 1.0 + (collected_artifacts * 0.1);
                
                play_sfx("puzzle_success");
            }
        }
    }
    
    // Проверяем столкновения с препятствиями
    for (i = 0; i < array_length_1d(obstacles); i++) {
        if (rectangle_in_rectangle(player.x, player.y, player.x + player.width, player.y + player.height,
                                   obstacles[i].x, obstacles[i].y, 
                                   obstacles[i].x + obstacles[i].width, obstacles[i].y + obstacles[i].height)) {
            // Столкновение с препятствием - сбрасываем позицию игрока
            reset_player_position();
            play_sfx("cancel");
        }
    }
}

// Функция сброса позиции игрока
function reset_player_position() {
    player.x = 50;
    player.y = 550;
    player.hspeed = 0;
    player.vspeed = 0;
    player.on_ground = true;
}

// Функция проверки завершения уровня
function check_completion() {
    // Проверяем, достиг ли игрок цели и собрал ли все артефакты
    if (rectangle_in_rectangle(player.x, player.y, player.x + player.width, player.y + player.height,
                              goal.x, goal.y, goal.x + goal.w, goal.y + goal.h) &&
        collected_artifacts >= total_artifacts) {
        solve_puzzle();
    }
}

// Вспомогательная функция проверки столкновения прямоугольников
function rectangle_in_rectangle(x1, y1, x2, y2, x3, y3, x4, y4) {
    return (x1 < x4 && x2 > x3 && y1 < y4 && y2 > y3);
}

// Вспомогательная функция проверки точки в прямоугольнике
function point_in_rectangle(px, py, rx1, ry1, rx2, ry2) {
    return (px >= rx1 && px <= rx2 && py >= ry1 && py <= ry2);
}

// Функция отрисовки головоломки
function draw(gui_view = false) {
    if (!gui_view) {
        // Рисуем платформы
        draw_set_color(c_gray);
        var i;
        for (i = 0; i < array_length_1d(platforms); i++) {
            var plat = platforms[i];
            draw_rectangle(plat.x, plat.y, plat.x + plat.w, plat.y + plat.h, true);
            draw_set_color(c_black);
            draw_rectangle(plat.x, plat.y, plat.x + plat.w, plat.y + plat.h, false);
            draw_set_color(c_gray);
        }
        
        // Рисуем препятствия
        for (i = 0; i < array_length_1d(obstacles); i++) {
            draw_set_color(c_orange);
            draw_rectangle(obstacles[i].x, obstacles[i].y, obstacles[i].x + obstacles[i].width, obstacles[i].y + obstacles[i].height, true);
            draw_set_color(c_red);
            draw_rectangle(obstacles[i].x, obstacles[i].y, obstacles[i].x + obstacles[i].width, obstacles[i].y + obstacles[i].height, false);
        }
        
        // Рисуем артефакты
        for (i = 0; i < array_length_1d(artifacts); i++) {
            if (!artifacts[i].collected) {
                draw_set_color(c_purple);
                draw_rectangle(artifacts[i].x, artifacts[i].y, artifacts[i].x + 20, artifacts[i].y + 20, true);
                draw_set_color(c_white);
                draw_rectangle(artifacts[i].x, artifacts[i].y, artifacts[i].x + 20, artifacts[i].y + 20, false);
                
                // Рисуем символ артефакта
                draw_set_color(c_white);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(artifacts[i].x + 10, artifacts[i].y + 10, "🔮");
            }
        }
        
        // Рисуем цель
        draw_set_color(c_lime);
        draw_rectangle(goal.x, goal.y, goal.x + goal.w, goal.y + goal.h, true);
        draw_set_color(c_black);
        draw_rectangle(goal.x, goal.y, goal.x + goal.w, goal.y + goal.h, false);
        
        // Рисуем символ цели
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(goal.x + goal.w/2, goal.y + goal.h/2, "🏆");
        
        // Рисуем игрока
        draw_set_color(c_red);
        draw_rectangle(player.x, player.y, player.x + player.width, player.y + player.height, true);
        draw_set_color(c_black);
        draw_rectangle(player.x, player.y, player.x + player.width, player.y + player.height, false);
        
        // Показываем информацию
        draw_set_color(c_white);
        draw_set_font(fnt_default);
        draw_text(10, 10, "Артефакты: " + string(collected_artifacts) + "/" + string(total_artifacts));
        draw_text(10, 30, "Время: " + string(floor(time_remaining / 60)));
        draw_text(10, 50, "Сложность: " + string(round(difficulty_factor * 100)) + "%");
        
        // Показываем подсказки
        draw_text(10, room_height - 40, "WASD или СТРЕЛКИ - движение");
        draw_text(10, room_height - 20, "ПРОБЕЛ - прыжок");
    }
}

// Функция проверки завершения головоломки
function is_solved() {
    return solved;
}

// Функция завершения головоломки
function solve_puzzle() {
    solved = true;
    
    // Воспроизводим звук успеха
    play_sfx("puzzle_completed");
}

// Функция сброса уровня
function reset_level() {
    // Возвращаем игрока к начальной позиции
    reset_player_position();
    
    // Сбрасываем артефакты
    collected_artifacts = 0;
    difficulty_factor = 1.0;
    var i;
    for (i = 0; i < array_length_1d(artifacts); i++) {
        artifacts[i].collected = false;
    }
    
    // Сбрасываем препятствия в начальные позиции
    for (i = 0; i < array_length_1d(obstacles); i++) {
        obstacles[i].x = obstacles[i].start_x;
        // Направление может быть случайным
        if (irandom(1)) {
            obstacles[i].hspd = abs(obstacles[i].hspd);
        } else {
            obstacles[i].hspd = -abs(obstacles[i].hspd);
        }
    }
    
    // Восстанавливаем таймер
    time_remaining = time_limit;
}

// Функция сброса головоломки
function reset() {
    reset_level();
    solved = false;
    
    return init();
}
