// scr_interlevel_platformer.gml
// Скрипт для реализации платформера, соединяющего уровни между собой

// Инициализация системы межуровневого перемещения
function init_interlevel_system() {
    if (!variable_global_exists("interlevel_data") || global.interlevel_data == undefined) {
        global.interlevel_data = {
            // Конфигурация точек перехода между уровнями
            transition_points: [
                // Меню -> Город
                {start_room: "rm_menu", exit_point: {x: 400, y: 550}, destination: "rm_town", entry_point: {x: 400, y: 550}},
                // Город -> Уровни 1-12
                {start_room: "rm_town", exit_point: {x: 100, y: 300}, destination: "rm_cave_maze", entry_point: {x: 50, y: 550}},       // Уровень 1 - Лабиринт
                {start_room: "rm_town", exit_point: {x: 200, y: 300}, destination: "rm_cave_archive", entry_point: {x: 50, y: 550}},   // Уровень 2 - Поиск слов
                {start_room: "rm_town", exit_point: {x: 300, y: 300}, destination: "rm_cave_rhythm", entry_point: {x: 50, y: 550}},    // Уровень 3 - Память/Паттерны
                {start_room: "rm_town", exit_point: {x: 400, y: 300}, destination: "rm_cave_pairs", entry_point: {x: 50, y: 550}},     // Уровень 4 - Головоломка на память
                {start_room: "rm_town", exit_point: {x: 500, y: 300}, destination: "rm_cave_platformer", entry_point: {x: 50, y: 550}}, // Уровень 5 - Платформер
                {start_room: "rm_town", exit_point: {x: 600, y: 300}, destination: "rm_cave_final", entry_point: {x: 50, y: 550}},      // Уровень 6 - Финальный уровень
                {start_room: "rm_town", exit_point: {x: 100, y: 100}, destination: "rm_cave_7_config", entry_point: {x: 50, y: 550}},  // Уровень 7 - Загадки Сфинкса
                {start_room: "rm_town", exit_point: {x: 200, y: 100}, destination: "rm_cave_8_config", entry_point: {x: 50, y: 550}},  // Уровень 8 - Звуковые Ловушки
                {start_room: "rm_town", exit_point: {x: 300, y: 100}, destination: "rm_cave_9_config", entry_point: {x: 50, y: 550}},  // Уровень 9 - Прыгающий Путь
                {start_room: "rm_town", exit_point: {x: 400, y: 100}, destination: "rm_cave_10_config", entry_point: {x: 50, y: 550}}, // Уровень 10 - Запоминалка
                {start_room: "rm_town", exit_point: {x: 500, y: 100}, destination: "rm_cave_11_config", entry_point: {x: 50, y: 550}}, // Уровень 11 - Песнь Пещер
                {start_room: "rm_town", exit_point: {x: 600, y: 100}, destination: "rm_cave_12_config", entry_point: {x: 50, y: 550}},  // Уровень 12 - Двенадцатый Подвиг
                // Уровни -> Город (возврат через рычаги)
                {start_room: "rm_cave_maze", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_archive", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_rhythm", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_pairs", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_platformer", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_final", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_7_config", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_8_config", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_9_config", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_10_config", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_11_config", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"},
                {start_room: "rm_cave_12_config", exit_point: {x: 700, y: 100}, destination: "rm_town", entry_point: {x: 400, y: 400}, trigger_type: "lever"}
            ],
            
            // Данные о текущем состоянии перемещения
            current_path: [],
            current_waypoint: 0,
            player_on_transition: false,
            
            // Параметры межуровневого платформера
            platformer_params: {
                gravity: 0.6,
                jump_strength: -12,
                move_speed: 4,
                friction: 0.85,
                max_fall_speed: 12
            }
        };
    }
}

// Функция проверки точки перехода
function check_transition_point(player_x, player_y, current_room) {
    init_interlevel_system();
    
    var transition_range = 32; // Диапазон срабатывания точки перехода
    
    for (var i = 0; i < array_length(global.interlevel_data.transition_points); i++) {
        var point = global.interlevel_data.transition_points[i];
        
        if (point.start_room == current_room) {
            var dx = abs(point.exit_point.x - player_x);
            var dy = abs(point.exit_point.y - player_y);
            
            if (dx < transition_range && dy < transition_range) {
                // Проверяем условия перехода (например, уровень должен быть разблокирован)
                if (can_transition_to(point.destination)) {
                    return point;
                }
            }
        }
    }
    
    return undefined;
}

// Функция проверки возможности перехода к уровню
function can_transition_to(destination_room) {
    // Получаем номер уровня из названия комнаты
    var level_num = extract_level_number(destination_room);
    
    if (level_num <= 0) {
        // Это не уровень, а другая комната (например, город)
        return true;
    }
    
    // Проверяем, доступен ли уровень для перехода
    // Уровень доступен, если он первый, или если предыдущий уровень был завершен
    if (level_num == 1) {
        return true;
    }
    
    // Проверяем, разблокирован ли уровень в системе прогресса
    var prev_level_completed = true;
    if (array_length(global.game_progress.levels) >= level_num - 1) {
        if (global.game_progress.levels[level_num - 2] != undefined) {
            prev_level_completed = global.game_progress.levels[level_num - 2].lever_pulled; // или completed
        }
    }
    
    return prev_level_completed;
}

// Извлечь номер уровня из названия комнаты
function extract_level_number(room_name) {
    var prefixes = ["rm_cave_", "rm_level_", "rm_"];
    var suffixes = ["_config", "_scene", ""];
    
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

// Функция запуска перехода между комнатами
function find_interlevel_room_by_name(room_name) {
    var room_asset = asset_get_index(room_name);
    if (room_asset != -1 && asset_get_type(room_asset) == asset_room) {
        return room_asset;
    }

    return -1;
}

function initiate_interlevel_transition(transition_data) {
    if (transition_data == undefined) return;
    if (!instance_exists(obj_player)) return;

    var player_inst = instance_find(obj_player, 0);
    
    // Сохраняем текущую позицию игрока
    global.last_player_position = {x: player_inst.x, y: player_inst.y};
    
    // Переходим в новую комнату
    var room_index = find_interlevel_room_by_name(transition_data.destination);
    if (room_index != -1) {
        room_goto(room_index);
        
        // После перехода перемещаем игрока в точку входа
        with (obj_player) {
            x = transition_data.entry_point.x;
            y = transition_data.entry_point.y;
        }
        
        // Воспроизводим звук перехода
        if (script_exists(scr_audio_manager) && script_exists(play_event_sound)) {
            play_event_sound("teleport");
        }
    } else {
        show_debug_message("Ошибка: комната " + transition_data.destination + " не найдена");
    }
}

// Функция обновления межуровневого перемещения (вызывается каждый кадр)
function update_interlevel_system() {
    init_interlevel_system();
    if (!instance_exists(obj_player)) return;
    
    // Проверяем, находится ли игрок на точке перехода
    var current_room = room_get_name(room);
    var player_inst = instance_find(obj_player, 0);
    var transition_point = check_transition_point(player_inst.x, player_inst.y, current_room);
    
    if (transition_point != undefined) {
        // Проверяем нажатие клавиши взаимодействия для перехода
        if (keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_enter)) {
            initiate_interlevel_transition(transition_point);
        }
    }
}

// Функция создания межуровневого платформера (улучшенная механика перемещения между уровнями)
function create_interlevel_platformer() {
    // Инициализация системы
    init_interlevel_system();
    
    // Устанавливаем режим движения игрока как платформер в межуровневом пространстве
    with (obj_player) {
        set_movement_mode("platformer");
    }
    
    // Создаем точки перехода в текущей комнате (если применимо)
    setup_room_transitions(room_get_name(room));
}

// Функция настройки точек перехода в комнате
function setup_room_transitions(current_room_name) {
    // Эта функция может в будущем добавлять визуальные элементы перехода в комнате
    // Например, порталы или специальные платформы
}

// Функция получения описания уровня
function get_level_description(room_name) {
    var level_num = extract_level_number(room_name);
    if (level_num <= 0) return "Неизвестный уровень";
    
    switch(level_num) {
        case 1: return "Лабиринт";
        case 2: return "Поиск слов";
        case 3: return "Паттерн-память";
        case 4: return "Поиск пар карточек";
        case 5: return "Платформер";
        case 6: return "Финальное испытание";
        case 7: return "Загадки Сфинкса";
        case 8: return "Звуковые Ловушки";
        case 9: return "Прыгающий Путь";
        case 10: return "Запоминалка";
        case 11: return "Песнь Пещер";
        case 12: return "Финальный Подвиг";
        default: return "Уровень " + string(level_num);
    }
}
