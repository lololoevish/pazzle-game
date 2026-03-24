// Player Object для GameMaker
// Контролируемый персонаж игрока

// Create Event
{
    // Начальная позиция
    x = room_width / 2;
    y = room_height / 2;
    
    // Скорость движения
    speed = 0;
    move_speed = 4;
    
    // Направление
    direction = 0;
    image_xscale = 1; // Для анимации направления
    
    // Состояния
    moving = false;
    interacting = false;
}

// Step Event
{
    moving = false;
    
    // Обработка движения (стрелки или WASD)
    if (keyboard_check(vk_right) || keyboard_check(ord('D'))) {
        x += move_speed;
        moving = true;
        image_xscale = 1; // Поворот вправо
    }
    if (keyboard_check(vk_left) || keyboard_check(ord('A'))) {
        x -= move_speed;
        moving = true;
        image_xscale = -1; // Поворот влево
    }
    if (keyboard_check(vk_down) || keyboard_check(ord('S'))) {
        y += move_speed;
        moving = true;
    }
    if (keyboard_check(vk_up) || keyboard_check(ord('W'))) {
        y -= move_speed;
        moving = true;
    }
    
    // Проверка коллизий (будет реализовано в зависимости от комнаты)
    handle_collisions();
    
    // Обработка взаимодействия
    if (keyboard_check_pressed(ord('E')) || keyboard_check_pressed(vk_enter)) {
        interact();
    }
}

// Функция взаимодействия
function interact() {
    // Проверка на пересечение с интерактивными объектами
    var inst = instance_place(x, y, obj_interactable);
    if (inst != noone) {
        inst.on_interact();
    }
}

// Функция обработки коллизий
function handle_collisions() {
    // Базовая обработка ограничения по границам комнаты
    x = clamp(x, bbox_left, room_width - bbox_right);
    y = clamp(y, bbox_top, room_height - bbox_bottom);
}

// Draw Event - если используется стандартная отрисовка, можно не заполнять