// Скрипт головоломки "Платформер" для GameMaker

// Функция инициализации головоломки
function init() {
    // Параметры игрока
    player = {
        x: 50,
        y: 400,
        width: 20,
        height: 20,
        speed: 4,
        hspeed: 0,
        vspeed: 0,
        gravity: 0.5,
        jump_strength: -10,
        on_ground: false
    };
    
    // Платформы
    platforms = [
        {x: 0, y: 580, w: 800, h: 20},     // Пол
        {x: 100, y: 500, w: 100, h: 20},   // Платформа 1
        {x: 300, y: 450, w: 100, h: 20},   // Платформа 2
        {x: 500, y: 400, w: 100, h: 20},   // Платформа 3
        {x: 200, y: 350, w: 100, h: 20},   // Платформа 4
        {x: 400, y: 300, w: 100, h: 20},   // Платформа 5
        {x: 600, y: 250, w: 100, h: 20},   // Платформа 6
        {x: 350, y: 200, w: 100, h: 20}    // Платформа 7 (к цели)
    ];
    
    // Кристаллы для сбора
    crystals = [
        {x: 130, y: 470, collected: false},
        {x: 330, y: 420, collected: false},
        {x: 530, y: 370, collected: false},
        {x: 230, y: 320, collected: false},
        {x: 430, y: 270, collected: false},
        {x: 630, y: 220, collected: false}
    ];
    
    // Цель
    goal = {x: 380, y: 170, w: 40, h: 40};
    
    // Состояние
    collected_crystals = 0;
    total_crystals = array_length_1d(crystals);
    solved = false;
    
    // Таймер
    time_limit = 1800; // 30 секунд
    time_remaining = time_limit;
    
    return {
        player: player,
        platforms: platforms,
        crystals: crystals,
        goal: goal,
        collected: collected_crystals,
        total: total_crystals,
        time: time_remaining
    };
}

// Функция обновления логики головоломки
function update() {
    if (!solved) {
        // Обновляем таймер
        time_remaining--;
        if (time_remaining <= 0) {
            // Время вышло, сбрасываем головоломку
            reset_level();
            return;
        }
        
        // Обработка движения игрока
        handle_player_movement();
        
        // Обновление физики игрока
        update_player_physics();
        
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
        player.hspeed = player.speed;
    }
    if (keyboard_check(vk_left) || keyboard_check(ord('A'))) {
        player.hspeed = -player.speed;
    }
    
    // Прыжок
    if ((keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord('W'))) && player.on_ground) {
        player.vspeed = player.jump_strength;
        player.on_ground = false;
        scr_audio_manager.play_sfx("interaction");
    }
}

// Функция обновления физики игрока
function update_player_physics() {
    // Применяем гравитацию
    player.vspeed += player.gravity;
    
    // Обновляем позицию
    player.x += player.hspeed;
    player.y += player.vspeed;
    
    // Проверяем границы комнаты
    if (player.x < 0) player.x = 0;
    if (player.x + player.width > room_width) player.x = room_width - player.width;
    if (player.y < 0) player.y = 0;
    // Не проверяем верхнюю границу, так как игрок может выпрыгнуть
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
    
    // Проверяем столкновения с кристаллами
    for (i = 0; i < array_length_1d(crystals); i++) {
        if (!crystals[i].collected) {
            if (point_in_rectangle(player.x + player.width/2, player.y + player.height/2,
                                  crystals[i].x, crystals[i].y, 
                                  crystals[i].x + 20, crystals[i].y + 20)) {
                // Собрали кристалл
                crystals[i].collected = true;
                collected_crystals++;
                scr_audio_manager.play_sfx("puzzle_success");
            }
        }
    }
}

// Функция проверки завершения уровня
function check_completion() {
    // Проверяем, достиг ли игрок цели и собрал ли все кристаллы
    if (rectangle_in_rectangle(player.x, player.y, player.x + player.width, player.y + player.height,
                              goal.x, goal.y, goal.x + goal.w, goal.y + goal.h) &&
        collected_crystals >= total_crystals) {
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
        draw_set_color(c_brown);
        var i;
        for (i = 0; i < array_length_1d(platforms); i++) {
            var plat = platforms[i];
            draw_rectangle(plat.x, plat.y, plat.x + plat.w, plat.y + plat.h, true);
            draw_set_color(c_black);
            draw_rectangle(plat.x, plat.y, plat.x + plat.w, plat.y + plat.h, false);
            draw_set_color(c_brown);
        }
        
        // Рисуем кристаллы
        for (i = 0; i < array_length_1d(crystals); i++) {
            if (!crystals[i].collected) {
                draw_set_color(c_aqua);
                draw_rectangle(crystals[i].x, crystals[i].y, crystals[i].x + 20, crystals[i].y + 20, true);
                draw_set_color(c_white);
                draw_rectangle(crystals[i].x, crystals[i].y, crystals[i].x + 20, crystals[i].y + 20, false);
                
                // Рисуем символ кристалла
                draw_set_color(c_white);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(crystals[i].x + 10, crystals[i].y + 10, "💎");
            }
        }
        
        // Рисуем цель
        draw_set_color(c_gold);
        draw_rectangle(goal.x, goal.y, goal.x + goal.w, goal.y + goal.h, true);
        draw_set_color(c_black);
        draw_rectangle(goal.x, goal.y, goal.x + goal.w, goal.y + goal.h, false);
        
        // Рисуем символ цели
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(goal.x + goal.w/2, goal.y + goal.h/2, "🏁");
        
        // Рисуем игрока
        draw_set_color(c_red);
        draw_rectangle(player.x, player.y, player.x + player.width, player.y + player.height, true);
        draw_set_color(c_black);
        draw_rectangle(player.x, player.y, player.x + player.width, player.y + player.height, false);
        
        // Показываем информацию
        draw_set_color(c_white);
        draw_set_font(fnt_default);
        draw_text(10, 10, "Кристаллы: " + string(collected_crystals) + "/" + string(total_crystals));
        draw_text(10, 30, "Время: " + string(floor(time_remaining / 60)));
        
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
    scr_audio_manager.play_sfx("puzzle_completed");
}

// Функция сброса уровня
function reset_level() {
    // Возвращаем игрока к начальной позиции
    player.x = 50;
    player.y = 400;
    player.hspeed = 0;
    player.vspeed = 0;
    
    // Сбрасываем кристаллы
    collected_crystals = 0;
    var i;
    for (i = 0; i < array_length_1d(crystals); i++) {
        crystals[i].collected = false;
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