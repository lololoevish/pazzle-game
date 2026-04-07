/*
 * Объект игрока
 * Контролирует поведение, движение и взаимодействие игрока
 */

// Инициализация параметров игрока
var player_config = {
    speed_normal: 150,        // Обычная скорость движения
    speed_diagonal: 100,      // Скорость при диагональном движении
    jump_strength: -10,       // Сила прыжка (отрицательное значение, т.к. координаты растут вниз)
    gravity: 0.5,             // Гравитация
    max_fall_speed: 12,       // Максимальная скорость падения
    interaction_distance: 96, // Дистанция взаимодействия
    facing_direction: 0       // Направление взгляда: 0-вниз, 1-влево, 2-вправо, 3-вверх
};

// Состояния игрока
var player_states = {
    NORMAL: "normal",         // Обычное состояние
    INTERACTING: "interacting", // Взаимодействие
    PUZZLE: "puzzle",        // Состояние головоломки
    MENU: "menu",            // Меню
    DIALOG: "dialog"         // Диалог
};

// Глобальные переменные объекта
current_state = player_states.NORMAL;
speed = player_config.speed_normal;
facing_direction = player_config.facing_direction;
interaction_enabled = true;

// Переменные для плавного движения
current_move_x = 0;
current_move_y = 0;
move_target_x = 0;
move_target_y = 0;

// Переменные для физики прыжков
hspeed = 0;                      // Горизонтальная скорость
vspeed = 0;                      // Вертикальная скорость
gravity = player_config.gravity; // Гравитация
on_ground = false;               // На земле ли игрок
can_double_jump = false;         // Можно ли сделать второй прыжок
jumps_remaining = 1;             // Оставшиеся прыжки (0 - нельзя прыгать, 1 - основной прыжок, 2 - двойной прыжок)
max_fall_speed = player_config.max_fall_speed; // Максимальная скорость падения

// Create Event
{
    // Инициализация в Create событии
    depth = -1;  // Игрок должен быть поверх других объектов
    solid = true;  // Игрок может сталкиваться с другими объектами
    
    // Устанавливаем начальное состояние
    current_state = player_states.NORMAL;
    
    // Устанавливаем начальную позицию, если не задана
    if (!is_numeric(x)) x = 100;
    if (!is_numeric(y)) y = 100;
    
    // Инициализируем переменные для плавного движения
    current_move_x = 0;
    current_move_y = 0;
    move_target_x = 0;
    move_target_y = 0;
    
    // Инициализируем переменные для физики
    hspeed = 0;
    vspeed = 0;
    gravity = player_config.gravity;
    on_ground = false;
    
    // Настройка прыжков: 1 означает только одиночный прыжок, 2 - разрешает двойной прыжок
    // В текущей реализации двойной прыжок отключен
    jumps_remaining = 1; // Максимум прыжков разрешено
    current_jumps_used = 0; // Сколько прыжков уже использовано
    max_fall_speed = player_config.max_fall_speed;
}

// Step Event
{
    handle_movement();
    handle_interaction();
    check_collisions();
}

// Обработка движения в Step событии
function handle_movement() {
    if (current_state != player_states.NORMAL) {
        return;  // Не двигаемся если не в нормальном состоянии
    }
    
    // Плавное управление с ускорением и замедлением
    var target_move_x = 0;
    var target_move_y = 0;
    
    // Проверяем нажатия клавиш
    if (keyboard_check(vk_left) || keyboard_check(ord('A'))) {
        target_move_x = -1;
        facing_direction = 1;  // Влево
    }
    if (keyboard_check(vk_right) || keyboard_check(ord('D'))) {
        target_move_x = 1;
        facing_direction = 2;  // Вправо
    }
    
    // Обработка прыжка
    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord('W'))) {
        jump();
    }
    
    // Параметры для плавного ускорения/замедления
    var acceleration = 0.2;    // Ускорение
    var deceleration = 0.15;   // Замедление
    
    // Получаем текущую цель движения по X
    if (target_move_x != move_target_x) {
        move_target_x = target_move_x;
    }
    
    // Плавное изменение горизонтальной скорости к целевому значению
    if (current_move_x != move_target_x) {
        if (abs(current_move_x - move_target_x) < acceleration) {
            current_move_x = move_target_x;
        } else if (current_move_x < move_target_x) {
            current_move_x += acceleration;
        } else {
            current_move_x -= acceleration;
        }
    }
    
    // Применяем замедление, когда не движемся горизонтально
    if (move_target_x == 0 && abs(current_move_x) > 0) {
        if (current_move_x > 0) {
            current_move_x = max(0, current_move_x - deceleration);
        } else {
            current_move_x = min(0, current_move_x + deceleration);
        }
    }
    
    // Устанавливаем горизонтальную скорость
    hspeed = current_move_x * speed * delta_time;
    
    // Применяем гравитацию
    if (!on_ground) {
        vspeed += gravity;
        if (vspeed > max_fall_speed) {
            vspeed = max_fall_speed;
        }
    } else {
        // Когда на земле, сбрасываем счетчик использованных прыжков
        current_jumps_used = 0;
    }
    
    // Вычисляем вектор движения с учетом гравитации
    var move_vector_x = hspeed;
    var move_vector_y = vspeed * delta_time;
    
    // Двигаем игрока (учитываем коллизии если solid=true)
    x += move_vector_x;
    y += move_vector_y;
    
    // Ограничиваем движения в пределах комнаты
    // bbox_left, bbox_right, bbox_top, bbox_bottom - это границы спрайта
    // если спрайт не назначен, используем размеры объекта
    var left_bound = (sprite_index != -1) ? bbox_left : 0;
    var right_bound = (sprite_index != -1) ? bbox_right : 1;
    var top_bound = (sprite_index != -1) ? bbox_top : 0;
    var bottom_bound = (sprite_index != -1) ? bbox_bottom : 1;
    
    if (is_numeric(left_bound) && is_numeric(room_width) && is_numeric(right_bound)) {
        x = clamp(x, left_bound, room_width - right_bound);
    }
    if (is_numeric(top_bound) && is_numeric(room_height) && is_numeric(bottom_bound)) {
        y = clamp(y, top_bound, room_height - bottom_bound);
    }
    
    // Обновляем анимацию
    update_animation(hspeed, vspeed);
}

// Функция прыжка
function jump() {
    // Прыжок возможен только если на земле или если разрешен двойной прыжок
    if (on_ground) {
        // Обычный прыжок
        vspeed = player_config.jump_strength;
        on_ground = false;
        current_jumps_used = 1; // Засчитываем первый прыжок
    }
    // В текущей реализации двойной прыжок отключен
    // Для включения двойного прыжка раскомментируйте следующую часть:
    /*
    else if (current_jumps_used < jumps_remaining) {
        // Второй прыжок (если разрешен)
        vspeed = player_config.jump_strength * 0.8; // Чуть слабее основного прыжка
        current_jumps_used++;
    }
    */
}
    // Двойной прыжок отключен в текущей реализации.
    // Для включения двойного прыжка раскомментируйте следующую часть:
    /*
    else if (jumps_remaining > 0) {
        // Второй прыжок (если разрешен)
        vspeed = player_config.jump_strength * 0.8; // Чуть слабее основного прыжка
        jumps_remaining--;
    }
    */
}

// Обновление анимации
function update_animation(move_x, move_y) {
    // В зависимости от направления и движения выбираем спрайт
    // move_x и move_y теперь соответствуют hspeed и vspeed
    if (abs(hspeed) > 0.1 || abs(vspeed) > 0.1) { // Пороговое значение чтобы отличать движение от нуля
        // Игрок двигается
        if (global.spr_player_walk != undefined && global.spr_player_walk != -1) {
            sprite_index = global.spr_player_walk;
        }
    } else {
        // Игрок стоит
        if (global.spr_player_idle != undefined && global.spr_player_idle != -1) {
            sprite_index = global.spr_player_idle;
        }
    }
    
    // Выбираем кадр анимации в зависимости от направления
    switch (facing_direction) {
        case 0: image_index = 0; break;  // Вниз
        case 1: image_index = 1; break;  // Влево
        case 2: image_index = 2; break;  // Вправо
        case 3: image_index = 3; break;  // Вверх
    }
}

// Обработка взаимодействия
function handle_interaction() {
    if (!interaction_enabled || current_state != player_states.NORMAL) {
        return;
    }
    
    // Проверяем нажатие кнопки взаимодействия
    if (keyboard_check_pressed(ord('E')) || keyboard_check_pressed(vk_enter)) {
        check_and_interact();
    }
}

// Проверка и выполнение взаимодействия
function check_and_interact() {
    // Находим ближайший интерактивный объект
    var closest_interactable = undefined;
    var closest_distance = player_config.interaction_distance;
    
    // Проверяем все интерактивные объекты в комнате
    var interactables = [obj_interactable, obj_lever, obj_altar, obj_exit_door, obj_npc];
    
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
    
    // Если нашли объект для взаимодействия
    if (closest_interactable != undefined) {
        // Проверяем, может ли объект взаимодействовать
        if (closest_interactable.can_interact) {
            // Запускаем взаимодействие
            if (closest_interactable.on_interact != undefined) {
                closest_interactable.on_interact();
            }
            
            // Играем звук взаимодействия
            if (script_exists(scr_audio_manager) && scr_audio_manager.play_event_sound != undefined) {
                scr_audio_manager.play_event_sound("ui_confirm");
            }
        } else {
            // Объект не может взаимодействовать
            if (script_exists(scr_audio_manager) && scr_audio_manager.play_event_sound != undefined) {
                scr_audio_manager.play_event_sound("ui_cancel");
            }
        }
    } else {
        // Нет доступных объектов для взаимодействия
        if (script_exists(scr_ui_manager) && scr_ui_manager.show_message != undefined) {
            scr_ui_manager.show_message("Здесь не с чем взаимодействовать");
        }
        if (script_exists(scr_audio_manager) && scr_audio_manager.play_event_sound != undefined) {
            scr_audio_manager.play_event_sound("ui_cancel");
        }
    }
}

// Функция проверки столкновений
function check_collisions() {
    // Проверяем столкновения с платформами/объектами
    // Здесь будет основная логика коллизий
    
    // Сбрасываем состояние на земле
    var was_on_ground = on_ground;
    on_ground = false;
    
    // Находим все платформы или твердые объекты в комнате
    // Пока что просто проверяем, касается ли игрок "земли" (нижней части комнаты)
    // или других твердых объектов
    
    // Упрощенная проверка коллизии с "землей" и платформами
    // Для полноценной реализации нужна проверка столкновений с конкретными объектами
    
    // Проверяем, не уперся ли игрок в платформу снизу (при падении)
    var test_x = x + bbox_left;
    var test_y = y + bbox_top;
    var test_width = bbox_right - bbox_left;
    var test_height = bbox_bottom - bbox_top;
    
    // Проверяем столкновение с полом комнаты
    if (test_y + test_height >= room_height) {
        y = room_height - test_height;
        vspeed = 0;
        on_ground = true;
    }
    
    // Проверяем столкновение с потолком
    if (test_y <= 0) {
        y = 1; // чуть ниже нуля, чтобы не застрять
        vspeed = 0;
    }
    
    // Проверяем столкновение со стенами
    if (test_x <= 0) {
        x = 1;
        hspeed = 0;
    } else if (test_x + test_width >= room_width) {
        x = room_width - test_width - 1;
        hspeed = 0;
    }
    
        // Проверяем столкновения с любыми твердыми объектами в комнате
    // Для примера проверим столкновения с объектами типа obj_interactable (включая платформы)
    // Это упрощенная проверка, в реальном проекте нужно использовать конкретные объекты платформ
    var solid_objects = [obj_interactable, obj_lever, obj_altar, obj_exit_door, obj_npc]; // Пример
    
    // Получаем размеры спрайта для расчетов столкновений
    var player_width = (sprite_index != -1 && sprite_exists(sprite_index)) ? bbox_right - bbox_left : 16;
    var player_height = (sprite_index != -1 && sprite_exists(sprite_index)) ? bbox_bottom - bbox_top : 16;
    
    for (var i = 0; i < array_length(solid_objects); i++) {
        var count = instance_number(solid_objects[i]);
        
        for (var j = 0; j < count; j++) {
            var inst = instance_find(solid_objects[i], j);
            if (inst != noone) {
                // Проверяем пересечение - используем bbox если спрайт существует
                if (place_meeting(x + hspeed, y, inst) || place_meeting(x + hspeed, y + player_height, inst)) {
                    // Столкновение по горизонтали
                    hspeed = 0;
                }
                
                if (place_meeting(x, y + vspeed, inst)) {
                    // Столкновение сверху или снизу
                    if (vspeed > 0) { // Падение вниз
                        // Вычисляем корректную позицию, чтобы игрок не заходил внутрь объекта
                        y = inst.y - player_height;
                        vspeed = 0;
                        on_ground = true;
                    } else if (vspeed < 0) { // Движение вверх (удар головой)
                        y = inst.y + (inst.bbox_bottom - inst.bbox_top);
                        vspeed = 0;
                    }
                }
            }
        }
    }
    
    // Если игрок был на земле, а теперь нет - значит оторвался
    if (was_on_ground && !on_ground) {
        // Возможно, нужна дополнительная логика
    }
}

// Функция перехода в состояние головоломки
function enter_puzzle_state(puzzle_type) {
    current_state = player_states.PUZZLE;
    
    // Скрываем игрока или делаем неактивным
    visible = false;
    solid = false;
    
    // Уведомляем систему о начале головоломки
    if (script_exists(scr_ui_manager) && scr_ui_manager.show_message != undefined) {
        scr_ui_manager.show_message("Вход в головоломку " + string(puzzle_type));
    }
}

// Функция выхода из состояния головоломки
function exit_puzzle_state() {
    current_state = player_states.NORMAL;
    
    // Возвращаем видимость и коллизии игрока
    visible = true;
    solid = true;
    
    // Сбрасываем физические параметры при выходе из головоломки
    vspeed = 0;
    hspeed = 0;
    on_ground = false;
    current_jumps_used = 0;
    
    if (script_exists(scr_ui_manager) && scr_ui_manager.show_message != undefined) {
        scr_ui_manager.show_message("Выход из головоломки");
    }
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
    
    // Определяем ближайшее направление
    if (angle_to_target >= 315 || angle_to_target < 45) {
        facing_direction = 3;  // Вверх
    } else if (angle_to_target >= 45 && angle_to_target < 135) {
        facing_direction = 2;  // Вправо
    } else if (angle_to_target >= 135 && angle_to_target < 225) {
        facing_direction = 0;  // Вниз
    } else if (angle_to_target >= 225 && angle_to_target < 315) {
        facing_direction = 1;  // Влево
    }
}

// Функция получения текущего состояния игрока
function get_current_state() {
    return current_state;
}

// Функция установки состояния игрока
function set_state(new_state) {
    if (player_states[new_state] != undefined) {
        current_state = new_state;
        
        // В зависимости от состояния выполняем действия
        switch (new_state) {
            case player_states.NORMAL:
                interaction_enabled = true;
                visible = true;
                solid = true;
                break;
            case player_states.INTERACTING:
                interaction_enabled = false;
                break;
            case player_states.PUZZLE:
                interaction_enabled = false;
                visible = false;
                solid = false;
                break;
            case player_states.DIALOG:
                interaction_enabled = false;
                break;
        }
    }
}

// Функция получения информации о игроке
function get_player_info() {
    var info = {
        x: x,
        y: y,
        state: current_state,
        facing_direction: facing_direction,
        interaction_enabled: interaction_enabled,
        speed: speed
    };
    
    return info;
}