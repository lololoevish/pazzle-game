/*
 * Объект игрока
 * Контролирует поведение, движение и взаимодействие игрока
 */

// Инициализация параметров игрока
var player_config = {
    speed_normal: 150,        // Обычная скорость движения
    speed_diagonal: 100,      // Скорость при диагональном движении
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
    if (keyboard_check(vk_up) || keyboard_check(ord('W'))) {
        target_move_y = -1;
        facing_direction = 3;  // Вверх
    }
    if (keyboard_check(vk_down) || keyboard_check(ord('S'))) {
        target_move_y = 1;
        facing_direction = 0;  // Вниз
    }
    
    // Параметры для плавного ускорения/замедления
    var acceleration = 0.2;    // Ускорение
    var deceleration = 0.15;   // Замедление
    
    // Получаем текущую цель движения
    if (target_move_x != move_target_x || target_move_y != move_target_y) {
        move_target_x = target_move_x;
        move_target_y = target_move_y;
    }
    
    // Плавное изменение скорости к целевому значению
    if (current_move_x != move_target_x) {
        if (abs(current_move_x - move_target_x) < acceleration) {
            current_move_x = move_target_x;
        } else if (current_move_x < move_target_x) {
            current_move_x += acceleration;
        } else {
            current_move_x -= acceleration;
        }
    }
    
    if (current_move_y != move_target_y) {
        if (abs(current_move_y - move_target_y) < acceleration) {
            current_move_y = move_target_y;
        } else if (current_move_y < move_target_y) {
            current_move_y += acceleration;
        } else {
            current_move_y -= acceleration;
        }
    }
    
    // Применяем замедление, когда не движемся
    if (move_target_x == 0 && abs(current_move_x) > 0) {
        if (current_move_x > 0) {
            current_move_x = max(0, current_move_x - deceleration);
        } else {
            current_move_x = min(0, current_move_x + deceleration);
        }
    }
    
    if (move_target_y == 0 && abs(current_move_y) > 0) {
        if (current_move_y > 0) {
            current_move_y = max(0, current_move_y - deceleration);
        } else {
            current_move_y = min(0, current_move_y + deceleration);
        }
    }
    
    // Нормализуем диагональное движение
    var effective_move_x = current_move_x;
    var effective_move_y = current_move_y;
    var speed_factor = 1.0;  // Фактор скорости
    
    if (effective_move_x != 0 && effective_move_y != 0) {
        effective_move_x *= 0.7071;  // cos(45°)
        effective_move_y *= 0.7071;  // sin(45°)
        speed_factor = player_config.speed_diagonal / player_config.speed_normal;
    }
    
    // Вычисляем вектор движения
    var move_vector_x = effective_move_x * speed * speed_factor * delta_time;
    var move_vector_y = effective_move_y * speed * speed_factor * delta_time;
    
    // Двигаем игрока (учитываем коллизии если solid=true)
    x += move_vector_x;
    y += move_vector_y;
    
    // Ограничиваем движения в пределах комнаты
    if (is_numeric(bbox_left) && is_numeric(room_width) && is_numeric(bbox_right)) {
        x = clamp(x, bbox_left, room_width - bbox_right);
    }
    if (is_numeric(bbox_top) && is_numeric(room_height) && is_numeric(bbox_bottom)) {
        y = clamp(y, bbox_top, room_height - bbox_bottom);
    }
    
    // Обновляем анимацию
    update_animation(current_move_x, current_move_y);
}

// Обновление анимации
function update_animation(move_x, move_y) {
    // В зависимости от направления и движения выбираем спрайт
    if (move_x != 0 || move_y != 0) {
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
    // Здесь можно реализовать проверку столкновений с другими объектами
    // Пока что оставим пустой
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