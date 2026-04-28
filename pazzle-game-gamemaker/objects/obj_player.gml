/*
 * Объект игрока
 * Контролирует поведение, движение и взаимодействие игрока
 */

// Инициализация параметров игрока
var player_config = {
    topdown_speed: 220,
    topdown_diagonal_speed: 180,
    topdown_acceleration: 10.0,
    topdown_deceleration: 14.0,
    platformer_move_speed: 260,
    platformer_ground_acceleration: 2200,
    platformer_ground_deceleration: 2600,
    platformer_air_acceleration: 1600,
    platformer_air_deceleration: 1400,
    jump_speed: 560,
    jump_cut_speed: 220,
    gravity_rise_hold: 1350,
    gravity_rise_release: 2500,
    gravity_fall: 2850,
    max_fall_speed: 900,
    coyote_time: 0.5,
    jump_buffer_time: 0.15,
    interaction_distance: 96,
    facing_direction: 0
};

// Состояния игрока
var player_states = {
    NORMAL: "normal",
    INTERACTING: "interacting",
    PUZZLE: "puzzle",
    MENU: "menu",
    DIALOG: "dialog"
};

// Глобальные переменные объекта
current_state = player_states.NORMAL;
movement_mode = "topdown";
facing_direction = player_config.facing_direction;
interaction_enabled = true;

// Сглаживание top-down движения
current_move_x = 0;
current_move_y = 0;
move_target_x = 0;
move_target_y = 0;

// Физика platformer-режима
hspeed = 0;
vspeed = 0;
on_ground = false;
coyote_timer = 0;
jump_buffer_timer = 0;
jump_held = false;

// Create Event
{
    depth = -1;
    solid = true;

    current_state = player_states.NORMAL;
    movement_mode = "topdown";
    facing_direction = player_config.facing_direction;
    interaction_enabled = true;

    if (!is_numeric(x)) x = 100;
    if (!is_numeric(y)) y = 100;

    current_move_x = 0;
    current_move_y = 0;
    move_target_x = 0;
    move_target_y = 0;

    hspeed = 0;
    vspeed = 0;
    on_ground = false;
    coyote_timer = 0;
    jump_buffer_timer = 0;
    jump_held = false;
}

// Step Event
{
    var dt = get_delta_seconds();
    handle_movement(dt);
    handle_interaction();
}

function get_delta_seconds() {
    return clamp(delta_time / 1000000, 0, 0.05);
}

function get_horizontal_input() {
    var input_x = 0;

    if (keyboard_check(vk_left) || keyboard_check(ord("A"))) {
        input_x -= 1;
    }
    if (keyboard_check(vk_right) || keyboard_check(ord("D"))) {
        input_x += 1;
    }

    return input_x;
}

function get_vertical_input() {
    var input_y = 0;

    if (keyboard_check(vk_up) || keyboard_check(ord("W"))) {
        input_y -= 1;
    }
    if (keyboard_check(vk_down) || keyboard_check(ord("S"))) {
        input_y += 1;
    }

    return input_y;
}

function approach(current, target, amount) {
    if (current < target) {
        return min(current + amount, target);
    }

    if (current > target) {
        return max(current - amount, target);
    }

    return target;
}

function get_collision_objects() {
    var objects = [];

    if (object_exists(obj_interactable)) array_push(objects, obj_interactable);
    if (object_exists(obj_lever)) array_push(objects, obj_lever);
    if (object_exists(obj_npc)) array_push(objects, obj_npc);

    return objects;
}

function collides_at(test_x, test_y) {
    if (!place_free(test_x, test_y)) {
        return true;
    }

    var collision_objects = get_collision_objects();

    for (var i = 0; i < array_length(collision_objects); i++) {
        var count = instance_number(collision_objects[i]);

        for (var j = 0; j < count; j++) {
            var inst = instance_find(collision_objects[i], j);
            if (inst != noone && inst != id) {
                var is_solid_instance = variable_instance_exists(inst, "solid") && inst.solid;
                if (is_solid_instance && place_meeting(test_x, test_y, inst)) {
                    return true;
                }
            }
        }
    }

    return false;
}

function get_sprite_width_safe() {
    if (sprite_index != -1 && sprite_exists(sprite_index)) {
        return bbox_right - bbox_left;
    }

    return 16;
}

function get_sprite_height_safe() {
    if (sprite_index != -1 && sprite_exists(sprite_index)) {
        return bbox_bottom - bbox_top;
    }

    return 16;
}

function move_axis(amount, is_horizontal) {
    var remaining = amount;

    while (abs(remaining) > 0) {
        var step = clamp(remaining, -1, 1);

        if (is_horizontal) {
            if (!collides_at(x + step, y)) {
                x += step;
            } else {
                hspeed = 0;
                break;
            }
        } else {
            if (!collides_at(x, y + step)) {
                y += step;
            } else {
                if (movement_mode == "platformer" && step > 0) {
                    on_ground = true;
                    coyote_timer = player_config.coyote_time;
                }
                vspeed = 0;
                break;
            }
        }

        remaining -= step;
    }
}

function handle_movement(dt) {
    if (current_state != player_states.NORMAL) {
        return;
    }

    if (movement_mode == "platformer") {
        handle_platformer_movement(dt);
    } else {
        handle_topdown_movement(dt);
    }
}

function handle_topdown_movement(dt) {
    var input_x = get_horizontal_input();
    var input_y = get_vertical_input();

    if (abs(input_x) > abs(input_y) && input_x != 0) {
        facing_direction = (input_x > 0) ? 2 : 1;
    } else if (input_y != 0) {
        facing_direction = (input_y > 0) ? 0 : 3;
    }

    move_target_x = input_x;
    move_target_y = input_y;

    var accel = player_config.topdown_acceleration * dt;
    var decel = player_config.topdown_deceleration * dt;

    if (move_target_x != 0) {
        current_move_x = approach(current_move_x, move_target_x, accel);
    } else {
        current_move_x = approach(current_move_x, 0, decel);
    }

    if (move_target_y != 0) {
        current_move_y = approach(current_move_y, move_target_y, accel);
    } else {
        current_move_y = approach(current_move_y, 0, decel);
    }

    var speed_scale = 1.0;
    if (current_move_x != 0 && current_move_y != 0) {
        speed_scale = player_config.topdown_diagonal_speed / player_config.topdown_speed;
    }

    var move_x = current_move_x * player_config.topdown_speed * speed_scale * dt;
    var move_y = current_move_y * player_config.topdown_speed * speed_scale * dt;

    hspeed = move_x / max(dt, 0.0001);
    vspeed = 0;
    on_ground = false;
    coyote_timer = 0;
    jump_buffer_timer = 0;
    jump_held = false;

    move_axis(move_x, true);
    move_axis(move_y, false);

    keep_inside_room();
    update_animation();
}

function handle_platformer_movement(dt) {
    var input_x = get_horizontal_input();
    var jump_pressed = keyboard_check_pressed(vk_space)
        || keyboard_check_pressed(vk_up)
        || keyboard_check_pressed(ord("W"));
    var jump_down = keyboard_check(vk_space)
        || keyboard_check(vk_up)
        || keyboard_check(ord("W"));
    var jump_released = keyboard_check_released(vk_space)
        || keyboard_check_released(vk_up)
        || keyboard_check_released(ord("W"));

    if (input_x != 0) {
        facing_direction = (input_x > 0) ? 2 : 1;
    }

    if (jump_pressed) {
        jump_buffer_timer = player_config.jump_buffer_time;
    } else {
        jump_buffer_timer = max(0, jump_buffer_timer - dt);
    }

    if (on_ground) {
        coyote_timer = player_config.coyote_time;
    } else {
        coyote_timer = max(0, coyote_timer - dt);
    }

    var target_hspeed = input_x * player_config.platformer_move_speed;
    var accel = player_config.platformer_air_acceleration;
    var decel = player_config.platformer_air_deceleration;
    
    // Увеличиваем ускорение при начале движения для большей отзывчивости
    var initial_accel_multiplier = 1.0;
    if (sign(input_x) != sign(hspeed) && input_x != 0) {
        initial_accel_multiplier = 1.5;  // Более резкий старт при смене направления
    }

    if (on_ground) {
        accel = player_config.platformer_ground_acceleration;
        decel = player_config.platformer_ground_deceleration;
    }

    if (input_x != 0) {
        hspeed = approach(hspeed, target_hspeed, accel * initial_accel_multiplier * dt);
    } else {
        hspeed = approach(hspeed, 0, decel * dt);
    }

    if (jump_buffer_timer > 0 && (on_ground || coyote_timer > 0)) {
        vspeed = -player_config.jump_speed;
        on_ground = false;
        coyote_timer = 0;
        jump_buffer_timer = 0;
        jump_held = true;
        create_jump_effect();
    }

    if (jump_released && vspeed < -player_config.jump_cut_speed) {
        vspeed = -player_config.jump_cut_speed;
    }

    var gravity_value = player_config.gravity_fall;
    if (vspeed < 0) {
        gravity_value = jump_down
            ? player_config.gravity_rise_hold
            : player_config.gravity_rise_release;
    }

    jump_held = jump_down;
    vspeed = min(vspeed + gravity_value * dt, player_config.max_fall_speed);

    on_ground = false;
    move_axis(hspeed * dt, true);
    move_axis(vspeed * dt, false);

    keep_inside_room();
    update_animation();
}

function keep_inside_room() {
    var left_bound = (sprite_index != -1 && sprite_exists(sprite_index)) ? bbox_left : 0;
    var right_bound = (sprite_index != -1 && sprite_exists(sprite_index)) ? bbox_right : 1;
    var top_bound = (sprite_index != -1 && sprite_exists(sprite_index)) ? bbox_top : 0;
    var bottom_bound = (sprite_index != -1 && sprite_exists(sprite_index)) ? bbox_bottom : 1;

    x = clamp(x, left_bound, room_width - right_bound);

    if (movement_mode == "platformer") {
        if (y <= top_bound) {
            y = top_bound;
            vspeed = max(0, vspeed);
        }

        if (y >= room_height - bottom_bound) {
            y = room_height - bottom_bound;
            vspeed = 0;
            on_ground = true;
            coyote_timer = player_config.coyote_time;
        }
    } else {
        y = clamp(y, top_bound, room_height - bottom_bound);
    }
}

function update_animation() {
    var is_moving = false;

    if (movement_mode == "platformer") {
        is_moving = abs(hspeed) > 8 || abs(vspeed) > 8;
    } else {
        is_moving = abs(current_move_x) > 0.05 || abs(current_move_y) > 0.05;
    }

    if (is_moving) {
        if (global.spr_player_walk != undefined && global.spr_player_walk != -1) {
            sprite_index = global.spr_player_walk;
        }
    } else {
        if (global.spr_player_idle != undefined && global.spr_player_idle != -1) {
            sprite_index = global.spr_player_idle;
        }
    }

    switch (facing_direction) {
        case 0: image_index = 0; break;
        case 1: image_index = 1; break;
        case 2: image_index = 2; break;
        case 3: image_index = 3; break;
    }
}

// Обработка взаимодействия
function handle_interaction() {
    if (!interaction_enabled || current_state != player_states.NORMAL) {
        return;
    }

    if (keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_enter)) {
        check_and_interact();
    }
}

// Проверка и выполнение взаимодействия
function check_and_interact() {
    var closest_interactable = undefined;
    var closest_distance = player_config.interaction_distance;
    var interactables = [obj_interactable, obj_lever, obj_npc];

    for (var i = 0; i < array_length(interactables); i++) {
        var count = instance_number(interactables[i]);

        for (var j = 0; j < count; j++) {
            var inst = instance_find(interactables[i], j);
            if (inst != noone) {
                var dist = point_distance(x, y, inst.x, inst.y);
                if (dist < closest_distance) {
                    closest_distance = dist;
                    closest_interactable = inst;
                }
            }
        }
    }

    if (closest_interactable != undefined) {
        var can_use = true;

        if (variable_instance_exists(closest_interactable, "can_interact")) {
            can_use = closest_interactable.can_interact;
        } else if (variable_instance_exists(closest_interactable, "interactable")) {
            can_use = closest_interactable.interactable;
        }

        // Проверяем, является ли объект порталом для перехода между уровнями
        if (variable_instance_exists(closest_interactable, "destination_room")) {
            // Это портал - осуществляем переход между уровнями
            handle_level_transition(closest_interactable);
        }
        // Проверяем, является ли объект NPC и можно ли с ним проявить "милосердие"
        else if (closest_interactable.object_index == obj_npc) {
            // Вместо стандартного взаимодействия можем предложить выбор: обычное взаимодействие или "дружба"
            show_interaction_choice(closest_interactable);
        } else {
            if (can_use) {
                if (variable_instance_exists(closest_interactable, "on_interact")) {
                    closest_interactable.on_interact();
                }
                safe_play_event_sound("ui_confirm");
            } else {
                safe_play_event_sound("ui_cancel");
            }
        }
    } else {
        safe_show_message("Здесь не с чем взаимодействовать");
        safe_play_event_sound("ui_cancel");
    }
}

// Обработка перехода между уровнями через портал
function handle_level_transition(portal_object) {
    if (portal_object.destination_room != undefined) {
        // Проверяем, доступен ли уровень для перехода
        var dest_room_name = portal_object.destination_room;
        var level_num = extract_level_number_from_room(dest_room_name);
        
        if (level_num > 0) {
            // Проверяем, разблокирован ли уровень
            if (is_level_accessible(level_num)) {
                // Осуществляем переход
                var room_index = room_get_name_index(dest_room_name);
                
                if (room_index != -1) {
                    if (dest_room_name == "rm_town") {
                        global.game_state = "town";
                    } else if (string_pos("rm_cave_", dest_room_name) == 1) {
                        global.game_state = "playing_level_" + string(level_num);
                    }
                    
                    room_goto(room_index);
                    
                    // После перехода перемещаем игрока в начальную позицию уровня
                    with (obj_player) {
                        x = 50;  // Начальная позиция
                        y = 550;
                    }
                    
                    safe_play_event_sound("teleport");
                    safe_show_message("Переход к " + (portal_object.portal_name || "уровню"));
                } else {
                    safe_show_message("Уровень недоступен: " + dest_room_name);
                    safe_play_event_sound("ui_cancel");
                }
            } else {
                safe_show_message("Уровень заблокирован. Пройдите предыдущие уровни.");
                safe_play_event_sound("ui_cancel");
            }
        } else {
            // Это не уровень, а другая комната
            var room_index = room_get_name_index(dest_room_name);
            if (room_index != -1) {
                room_goto(room_index);
                safe_play_event_sound("teleport");
            }
        }
    }
}

// Извлечь номер уровня из названия комнаты
function extract_level_number_from_room(room_name) {
    var prefixes = ["rm_cave_", "rm_level_", "rm_"];
    var suffixes = ["_config", "_scene", "_room", ""];
    
    for (var i = 0; i < array_length(prefixes); i++) {
        var prefix = prefixes[i];
        if (string_pos(prefix, room_name) == 1) {
            var remaining = string_delete(room_name, 1, string_length(prefix));
            
            for (var j = 0; j < array_length(suffixes); j++) {
                var suffix = suffixes[j];
                if (string_pos(suffix, remaining) == string_length(remaining) - string_length(suffix) + 1) {
                    remaining = string_delete(remaining, string_length(remaining) - string_length(suffix) + 1, string_length(suffix));
                    break;
                }
            }
            
            // Попробовать извлечь число из оставшейся строки
            var num_str = "";
            for (var k = 1; k <= string_length(remaining); k++) {
                var char = string_char_at(remaining, k);
                if (char >= "0" && char <= "9") {
                    num_str += char;
                } else if (num_str != "") {
                    // Если уже начали собирать число, но встречаем букву, останавливаемся
                    break;
                }
            }
            
            if (num_str != "") {
                return int(num_str);
            }
        }
    }
    
    return 0;
}

// Проверить, доступен ли уровень
function is_level_accessible(level_num) {
    if (level_num <= 0 || level_num > array_length(global.game_progress.levels)) return false;
    if (level_num == 1) return true;  // Первый уровень всегда доступен
    
    // Проверяем, разблокирован ли уровень в глобальных данных
    if (global.game_progress.levels[level_num - 1] != undefined) {
        return true; // Если данные для уровня существуют, он разблокирован
    }
    
    // Проверяем через систему прогресса
    if (script_exists(scr_game_state)) {
        var status = get_level_status(get_current_game_state(), level_num);
        return (status != "locked");
    }
    
    return false;
}

// Получить текущее состояние игры (временная реализация)
function get_current_game_state() {
    return {
        current_state: global.game_state,
        current_level: 1,
        progress: global.game_progress.levels  // Используем существующую структуру
    };
}

// Показать выбор взаимодействия с NPC
function show_interaction_choice(npc_obj) {
    if (script_exists(scr_ui_manager) && script_exists(show_dialog)) {
        var options = ["Поговорить", "Проявить дружбу"];
        var callback = function(selected_option) {
            switch(selected_option) {
                case 0:  // Поговорить
                    if (variable_instance_exists(npc_obj, "on_interact")) {
                        npc_obj.on_interact();
                    }
                    safe_play_event_sound("ui_confirm");
                    break;
                case 1:  // Проявить дружбу
                    attempt_mercy_interaction(npc_obj);
                    break;
            }
        };
        scr_ui_manager.show_dialog("Как вы хотите взаимодействовать?", options, callback);
    } else {
        // Если UI недоступен, просто выполнить стандартное взаимодействие
        if (variable_instance_exists(npc_obj, "on_interact")) {
            npc_obj.on_interact();
        }
        safe_play_event_sound("ui_confirm");
    }
}

function safe_play_event_sound(event_name) {
    if (script_exists(scr_audio_manager) && script_exists(play_event_sound)) {
        play_event_sound(event_name);
    }
}

function safe_show_message(text) {
    if (script_exists(scr_ui_manager) && script_exists(show_message)) {
        show_message(text);
    }
}

// Создание визуального эффекта при прыжке
function create_jump_effect() {
    // Временная визуальная обратная связь при прыжке
    // В будущем можно заменить на частицы или анимацию
    if (script_exists(scr_audio_manager) && script_exists(play_event_sound)) {
        // Играть звук прыжка
        if (variable_instance_exists(global, "snd_player_jump") && global.snd_player_jump != -1) {
            play_event_sound("snd_player_jump");
        } else {
            audio_play_sound(global.snd_player_jump, 1, false);
        }
    }
}

// Функция проверки столкновений
function check_collisions() {
    // Коллизии обрабатываются в move_axis().
}

// Функция перехода в состояние головоломки
function enter_puzzle_state(puzzle_type) {
    current_state = player_states.PUZZLE;
    visible = false;
    solid = false;
    hspeed = 0;
    vspeed = 0;
    current_move_x = 0;
    current_move_y = 0;
    move_target_x = 0;
    move_target_y = 0;
    jump_buffer_timer = 0;
    coyote_timer = 0;
    jump_held = false;
    safe_show_message("Вход в головоломку " + string(puzzle_type));
}

// Функция выхода из состояния головоломки
function exit_puzzle_state() {
    current_state = player_states.NORMAL;
    visible = true;
    solid = true;
    hspeed = 0;
    vspeed = 0;
    current_move_x = 0;
    current_move_y = 0;
    move_target_x = 0;
    move_target_y = 0;
    on_ground = false;
    jump_buffer_timer = 0;
    coyote_timer = 0;
    jump_held = false;
    safe_show_message("Выход из головоломки");
}

// Функция проверки расстояния до объекта
function distance_to_object(other_object) {
    var inst = instance_nearest(x, y, other_object);
    if (inst != noone) {
        return point_distance(x, y, inst.x, inst.y);
    }
    return -1;
}

// Функция поворота к объекту
function face_object(target_x, target_y) {
    var angle_to_target = point_direction(x, y, target_x, target_y);

    if (angle_to_target >= 315 || angle_to_target < 45) {
        facing_direction = 3;
    } else if (angle_to_target >= 45 && angle_to_target < 135) {
        facing_direction = 2;
    } else if (angle_to_target >= 135 && angle_to_target < 225) {
        facing_direction = 0;
    } else if (angle_to_target >= 225 && angle_to_target < 315) {
        facing_direction = 1;
    }
}

// Функция получения текущего состояния игрока
function get_current_state() {
    return current_state;
}

function set_movement_mode(new_mode) {
    if (new_mode != "topdown" && new_mode != "platformer") {
        return;
    }

    movement_mode = new_mode;
    hspeed = 0;
    vspeed = 0;
    current_move_x = 0;
    current_move_y = 0;
    move_target_x = 0;
    move_target_y = 0;
    on_ground = false;
    coyote_timer = 0;
    jump_buffer_timer = 0;
    jump_held = false;
}

// Функция установки состояния игрока
function set_state(new_state) {
    current_state = new_state;
    hspeed = 0;
    vspeed = 0;
    current_move_x = 0;
    current_move_y = 0;
    move_target_x = 0;
    move_target_y = 0;
    jump_buffer_timer = 0;
    coyote_timer = 0;
    jump_held = false;

    switch (new_state) {
        case player_states.NORMAL:
            interaction_enabled = true;
            visible = true;
            solid = true;
            on_ground = false;
            break;
        case player_states.INTERACTING:
        case player_states.DIALOG:
            interaction_enabled = false;
            on_ground = false;
            break;
        case player_states.PUZZLE:
            interaction_enabled = false;
            visible = false;
            solid = false;
            on_ground = false;
            break;
    }
}

// Проверка наличия элемента в массиве
function array_contains(arr, element) {
    if (arr == undefined) return false;
    for (var i = 0; i < array_length(arr); i++) {
        if (arr[i] == element) {
            return true;
        }
    }
    return false;
}

// Функция получения информации о игроке
function get_player_info() {
    return {
        x: x,
        y: y,
        state: current_state,
        movement_mode: movement_mode,
        facing_direction: facing_direction,
        interaction_enabled: interaction_enabled,
        hspeed: hspeed,
        vspeed: vspeed,
        on_ground: on_ground,
        coyote_timer: coyote_timer,
        jump_buffer_timer: jump_buffer_timer
    };
}

// Функция взаимодействия с NPC в стиле "дружбы" (механики из Deltarune)
function attempt_mercy_interaction(npc_obj) {
    // Проверяем, возможно ли проявить "милосердие" к NPC
    if (npc_obj != noone && variable_instance_exists(npc_obj, "can_show_mercy")) {
        if (npc_obj.can_show_mercy) {
            // Игрок выбирает действие милосердия
            var mercy_actions = ["помочь", "улыбнуться", "подарить вещь"];
            
            // Временно показываем выбор действия милосердия
            safe_show_message("Вы можете проявить милосердие к " + string(npc_obj.npc_name));
            
            // При успешном действии милосердия
            if (script_exists(scr_ui_manager) && script_exists(show_dialog)) {
                // Показать диалог выбора действия
                show_mercy_dialog(npc_obj);
            }
            
            return true;
        }
    }
    return false;
}

// Функция показа диалога выбора действия милосердия
function show_mercy_dialog(npc_obj) {
    if (script_exists(scr_ui_manager) && script_exists(show_dialog)) {
        var options = ["Подарить улыбку", "Предложить помощь", "Проявить сочувствие"];
        var callback = function(selected_option) {
            handle_mercy_action(selected_option, npc_obj);
        };
        scr_ui_manager.show_dialog("Как вы хотите проявить доброту?", options, callback);
    }
}

// Обработка действия милосердия
function handle_mercy_action(action_idx, npc_obj) {
    switch(action_idx) {
        case 0:
            safe_show_message("Вы подарили " + npc_obj.npc_name + " свою улыбку");
            safe_play_event_sound("friendship_gained");
            break;
        case 1:
            safe_show_message("Вы предложили помощь " + npc_obj.npc_name);
            safe_play_event_sound("mercy_action");
            break;
        case 2:
            safe_show_message("Вы проявили сочувствие к " + npc_obj.npc_name);
            safe_play_event_sound("npc_friendly_response");
            break;
    }
    
    // Обновление состояния NPC
    if (variable_instance_exists(npc_obj, "on_player_mercy")) {
        npc_obj.on_player_mercy(action_idx);
    }
    
    // В будущем это может повлиять на отношения с NPC или разблокировать особые события
    global.player_mercy_points = (global.player_mercy_points != undefined) ? global.player_mercy_points + 1 : 1;
    
    // Возможно обновление прогресса дружбы
    if (!array_contains(global.player_friends_rescued, string(npc_obj.id))) {
        if (global.player_friends_rescued == undefined) {
            global.player_friends_rescued = [];
        }
        array_push(global.player_friends_rescued, string(npc_obj.id));
    }
}

// Функция обработки завершения головоломки с переходом
function complete_level_with_transition(level_num) {
    var current_room_name = room_get_name(room);
    
    // Вызываем обработчик завершения уровня с переходом
    if (script_exists(scr_level_transition_platformer) && 
        script_exists(handle_level_complete_with_transition)) {
        handle_level_complete_with_transition(level_num, current_room_name);
    } else {
        // Если новой системы нет, используем старую
        if (script_exists(complete_level)) {
            complete_level(level_num);
        }
        
        // Возвращаем в город
        var town_room_index = room_get_name_index("rm_town");
        if (town_room_index != -1) {
            room_goto(town_room_index);
            
            // Перемещаем игрока в центр города
            x = 400;
            y = 400;
        }
    }
}
