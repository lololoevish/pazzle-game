// Main Room
// Главная комната запуска игры

// Инициализация комнаты
function room_initialize() {
    // Устанавливаем размеры комнаты
    width = 800;
    height = 600;
    
    // Устанавливаем цвет фона
    background_color = c_black;
    
    // Устанавливаем позицию камеры
    view_xview[0] = 0;
    view_yview[0] = 0;
    view_wview[0] = 800;
    view_hview[0] = 600;
    view_visible[0] = true;
    
    // Создаем объекты
    instance_create(0, 0, obj_game_manager);
}

// Событие Create комнаты
{
    room_initialize();
}