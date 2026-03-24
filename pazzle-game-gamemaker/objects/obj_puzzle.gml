// Базовый объект головоломки для GameMaker
// Все конкретные головоломки будут наследоваться от него

// Create Event
{
    puzzle_initialized = false;
    puzzle_solved = false;
    puzzle_active = false;
    puzzle_timer = 0;
}

// Step Event
{
    if (puzzle_active) {
        puzzle_timer += 1;
        puzzle_update();
    }
}

// Draw Event
{
    if (puzzle_active) {
        puzzle_draw();
    }
}

// Функции интерфейса головоломки
function puzzle_start() {
    puzzle_active = true;
    puzzle_initialized = true;
    puzzle_init();
}

function puzzle_update() {
    // Переопределяется в конкретных реализациях
}

function puzzle_draw() {
    // Переопределяется в конкретных реализациях
}

function puzzle_init() {
    // Инициализация головоломки
    // Переопределяется в конкретных реализациях
}

function puzzle_is_solved() {
    // Проверка решения головоломки
    // Переопределяется в конкретных реализациях
    return puzzle_solved;
}

function puzzle_complete() {
    puzzle_solved = true;
    puzzle_active = false;
    
    // Сообщение менеджеру об успешном прохождении
    var instance_id = instance_nearest(x, y, obj_game_manager);
    if (instance_id != noone) {
        instance_id.on_puzzle_solved();
    }
}