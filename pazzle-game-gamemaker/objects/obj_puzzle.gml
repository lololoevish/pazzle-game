// Базовый объект головоломки для GameMaker
// Все конкретные головоломки будут наследоваться от него

// Create Event
{
    puzzle_initialized = false;
    puzzle_solved = false;
    puzzle_active = false;
    puzzle_timer = 0;
    puzzle_level = 1;
    
    // Тип головоломки (определяется в наследниках)
    puzzle_type = "";
    
    // Ссылка на скрипт головоломки
    puzzle_script = undefined;
    
    // Данные головоломки
    puzzle_data = undefined;
}

// Step Event
{
    if (puzzle_active) {
        puzzle_timer += 1;
        
        // Обновляем логику головоломки
        if (puzzle_script != undefined) {
            update_puzzle(puzzle_type);
        }
        
        // Проверяем, решена ли головоломка
        if (is_puzzle_solved(puzzle_type)) {
            puzzle_complete();
        }
    }
}

// Draw Event
{
    if (puzzle_active) {
        // Отрисовываем головоломку
        if (puzzle_script != undefined) {
            draw_puzzle(puzzle_type, false);
        }
    }
}

// Функции интерфейса головоломки
function puzzle_start() {
    puzzle_active = true;
    
    if (!puzzle_initialized) {
        puzzle_init();
        puzzle_initialized = true;
    }
}

function puzzle_update() {
    // Обновление логики головоломки происходит в скриптах
}

function puzzle_draw() {
    // Отрисовка головоломки происходит в скриптах
}

function puzzle_init() {
    // Инициализация головоломки
    if (puzzle_type != "" && puzzle_script == undefined) {
        // Инициализируем puzzle manager если он еще не инициализирован
        if (!variable_instance_exists(global, "puzzle_manager_initialized")) {
            init_puzzle_manager();
            global.puzzle_manager_initialized = true;
        }
        
        // Создаем экземпляр головоломки
        puzzle_data = create_puzzle(puzzle_type);
    }
}

function puzzle_is_solved() {
    // Проверка решения головоломки
    if (puzzle_script != undefined) {
        return is_puzzle_solved(puzzle_type);
    }
    return puzzle_solved;
}

function puzzle_complete() {
    puzzle_solved = true;
    puzzle_active = false;
    
    // Сообщение менеджеру об успешном прохождении
    var instance_id = instance_nearest(x, y, obj_game_manager);
    if (instance_id != noone) {
        instance_id.on_puzzle_solved(puzzle_level);
    }
}

// Функция установки типа головоломки
function set_puzzle_type(type) {
    puzzle_type = type;
}
