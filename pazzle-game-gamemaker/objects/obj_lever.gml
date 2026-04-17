// Объект рычага для GameMaker
// Используется в конце уровней для открытия следующей пещеры

// Create Event
{
    sprite_index = spr_lever;
    solid = true;
    lever_pulled = false;
    lever_interaction_distance = 32;
    puzzle_level = 1;
}

// Step Event
{
    // Взаимодействие инициируется централизованно через `obj_player`.
}

// Draw Event
{
    // Отображение рычага
    draw_self();
    
    // Если рычаг уже потянут, можно изменить спрайт
    if (lever_pulled) {
        sprite_index = spr_lever_pulled;
    }
}

// Функция отображения подсказки взаимодействия
function draw_interaction_prompt() {
    // Рисуем символ E над рычагом как подсказку
    draw_sprite_ext(spr_e_key, 0, x, y - 40, 1, 1, 0, c_white, 0.7);
}

// Функция нажатия рычага
function pull_lever() {
    if (!lever_pulled) {
        lever_pulled = true;
        
        // Воспроизводим звук
        play_sfx("lever");
        
        // Обновляем состояние уровня
        var gm = instance_nearest(x, y, obj_game_manager);
        if (gm != noone && variable_instance_exists(gm, "on_lever_pulled")) {
            gm.on_lever_pulled(puzzle_level);
        }
        
        // Открываем путь к следующему уровню
        open_exit();
    }
}

// Функция открытия выхода
function open_exit() {
    // Находим выход и открываем его
    if (object_exists(obj_exit)) {
        var exit_inst = instance_nearest(x, y, obj_exit);
        if (exit_inst != noone) {
        exit_inst.open_door();
        }
    }
}

// Функция взаимодействия (для универсального интерфейса)
function on_interact() {
    pull_lever();
}
