// scr_level_transition_platformer.gml
// Скрипт для реализации коротких платформенных переходов между уровнями

#macro TRANSITION_DEFAULT_LEVEL_COUNT 24

// Инициализация системы переходов
function init_level_transitions() {
    if (!variable_global_exists("level_transition_data") || global.level_transition_data == undefined) {
        global.level_transition_data = {
            // Конфигурация переходов между уровнями
            transitions: {
                // Переход от уровня 1 к уровню 2
                "rm_cave_maze_to_rm_cave_archive": {
                    source_room: "rm_cave_maze",
                    destination_room: "rm_cave_archive",
                    transition_type: "platformer",
                    length: 300,  // длина перехода в пикселях
                    obstacles: [{"type": "gap", "position": 100, "size": 50}, {"type": "moving_platform", "position": 200}],
                    collectibles: ["coin", "key"],
                    enemies: []
                },
                // Переход от уровня 2 к уровню 3
                "rm_cave_archive_to_rm_cave_rhythm": {
                    source_room: "rm_cave_archive",
                    destination_room: "rm_cave_rhythm",
                    transition_type: "platformer",
                    length: 400,
                    obstacles: [{"type": "gap", "position": 120, "size": 60}, {"type": "spikes", "position": 250}],
                    collectibles: ["power_up"],
                    enemies: [{"type": "walker", "position": 180}]
                },
                // Переход от уровня 3 к уровню 4
                "rm_cave_rhythm_to_rm_cave_pairs": {
                    source_room: "rm_cave_rhythm",
                    destination_room: "rm_cave_pairs",
                    transition_type: "platformer",
                    length: 250,
                    obstacles: [{"type": "gap", "position": 80, "size": 40}, {"type": "gap", "position": 160, "size": 40}],
                    collectibles: ["extra_life", "coin"],
                    enemies: []
                },
                // Переход от уровня 4 к уровню 5
                "rm_cave_pairs_to_rm_cave_platformer": {
                    source_room: "rm_cave_pairs",
                    destination_room: "rm_cave_platformer",
                    transition_type: "platformer",
                    length: 350,
                    obstacles: [{"type": "gap", "position": 100, "size": 50}, {"type": "moving_platform", "position": 200}, {"type": "spikes", "position": 280}],
                    collectibles: ["power_up", "coin", "gem"],
                    enemies: [{"type": "flyer", "position": 150}]
                },
                // Переход от уровня 5 к уровню 6
                "rm_cave_platformer_to_rm_cave_final": {
                    source_room: "rm_cave_platformer",
                    destination_room: "rm_cave_final",
                    transition_type: "platformer",
                    length: 500,
                    obstacles: [{"type": "gap", "position": 100, "size": 60}, {"type": "gap", "position": 220, "size": 40}, 
                              {"type": "moving_platform", "position": 300}, {"type": "gap", "position": 400, "size": 60}],
                    collectibles: ["gem", "trophy", "power_up"],
                    enemies: [{"type": "walker", "position": 150}, {"type": "flyer", "position": 350}]
                },
                // Переход от уровня 6 к уровню 7
                "rm_cave_final_to_rm_cave_7_config": {
                    source_room: "rm_cave_final",
                    destination_room: "rm_cave_7_config",
                    transition_type: "platformer",
                    length: 300,
                    obstacles: [{"type": "gap", "position": 100, "size": 50}, {"type": "gap", "position": 200, "size": 50}],
                    collectibles: ["key", "coin"],
                    enemies: []
                },
                // Переход от уровня 7 к уровню 8
                "rm_cave_7_config_to_rm_cave_8_config": {
                    source_room: "rm_cave_7_config",
                    destination_room: "rm_cave_8_config",
                    transition_type: "platformer",
                    length: 280,
                    obstacles: [{"type": "gap", "position": 80, "size": 40}, {"type": "spikes", "position": 180}],
                    collectibles: ["power_up"],
                    enemies: [{"type": "walker", "position": 200}]
                },
                // Переход от уровня 8 к уровню 9
                "rm_cave_8_config_to_rm_cave_9_config": {
                    source_room: "rm_cave_8_config",
                    destination_room: "rm_cave_9_config",
                    transition_type: "platformer",
                    length: 320,
                    obstacles: [{"type": "gap", "position": 100, "size": 50}, {"type": "moving_platform", "position": 200}],
                    collectibles: ["gem", "coin"],
                    enemies: []
                },
                // Переход от уровня 9 к уровню 10
                "rm_cave_9_config_to_rm_cave_10_config": {
                    source_room: "rm_cave_9_config",
                    destination_room: "rm_cave_10_config",
                    transition_type: "platformer",
                    length: 360,
                    obstacles: [{"type": "gap", "position": 80, "size": 60}, {"type": "spikes", "position": 180}, 
                              {"type": "gap", "position": 280, "size": 50}],
                    collectibles: ["extra_life", "power_up"],
                    enemies: [{"type": "flyer", "position": 220}]
                },
                // Переход от уровня 10 к уровню 11
                "rm_cave_10_config_to_rm_cave_11_config": {
                    source_room: "rm_cave_10_config",
                    destination_room: "rm_cave_11_config",
                    transition_type: "platformer",
                    length: 290,
                    obstacles: [{"type": "gap", "position": 100, "size": 40}, {"type": "gap", "position": 200, "size": 40}],
                    collectibles: ["coin", "gem"],
                    enemies: []
                },
                // Переход от уровня 11 к уровню 12
                "rm_cave_11_config_to_rm_cave_12_config": {
                    source_room: "rm_cave_11_config",
                    destination_room: "rm_cave_12_config",
                    transition_type: "platformer",
                    length: 400,
                    obstacles: [{"type": "gap", "position": 100, "size": 50}, {"type": "spikes", "position": 200}, 
                              {"type": "moving_platform", "position": 280}, {"type": "gap", "position": 340, "size": 50}],
                    collectibles: ["trophy", "gem", "power_up"],
                    enemies: [{"type": "walker", "position": 150}, {"type": "flyer", "position": 300}]
                },
                // Переходы уровней 12-24
                "rm_cave_12_config_to_rm_cave_13_config": {source_room: "rm_cave_12_config", destination_room: "rm_cave_13_config", transition_type: "platformer", length: 420, obstacles: [{"type": "gap", "position": 120, "size": 50}], collectibles: ["gem"], enemies: []},
                "rm_cave_13_config_to_rm_cave_14_config": {source_room: "rm_cave_13_config", destination_room: "rm_cave_14_config", transition_type: "platformer", length: 430, obstacles: [{"type": "moving_platform", "position": 180}], collectibles: ["coin", "key"], enemies: [{"type": "walker", "position": 240}]},
                "rm_cave_14_config_to_rm_cave_15_config": {source_room: "rm_cave_14_config", destination_room: "rm_cave_15_config", transition_type: "platformer", length: 440, obstacles: [{"type": "spikes", "position": 210}], collectibles: ["power_up"], enemies: []},
                "rm_cave_15_config_to_rm_cave_16_config": {source_room: "rm_cave_15_config", destination_room: "rm_cave_16_config", transition_type: "platformer", length: 450, obstacles: [{"type": "gap", "position": 130, "size": 60}, {"type": "moving_platform", "position": 280}], collectibles: ["gem", "coin"], enemies: [{"type": "flyer", "position": 320}]},
                "rm_cave_16_config_to_rm_cave_17_config": {source_room: "rm_cave_16_config", destination_room: "rm_cave_17_config", transition_type: "platformer", length: 460, obstacles: [{"type": "gap", "position": 160, "size": 50}], collectibles: ["key"], enemies: []},
                "rm_cave_17_config_to_rm_cave_18_config": {source_room: "rm_cave_17_config", destination_room: "rm_cave_18_config", transition_type: "platformer", length: 470, obstacles: [{"type": "spikes", "position": 220}, {"type": "gap", "position": 340, "size": 50}], collectibles: ["power_up", "coin"], enemies: [{"type": "walker", "position": 260}]},
                "rm_cave_18_config_to_rm_cave_19_config": {source_room: "rm_cave_18_config", destination_room: "rm_cave_19_config", transition_type: "platformer", length: 480, obstacles: [{"type": "moving_platform", "position": 240}], collectibles: ["gem"], enemies: []},
                "rm_cave_19_config_to_rm_cave_20_config": {source_room: "rm_cave_19_config", destination_room: "rm_cave_20_config", transition_type: "platformer", length: 490, obstacles: [{"type": "gap", "position": 180, "size": 70}], collectibles: ["coin", "trophy"], enemies: [{"type": "flyer", "position": 360}]},
                "rm_cave_20_config_to_rm_cave_21_config": {source_room: "rm_cave_20_config", destination_room: "rm_cave_21_config", transition_type: "platformer", length: 500, obstacles: [{"type": "spikes", "position": 240}], collectibles: ["power_up"], enemies: []},
                "rm_cave_21_config_to_rm_cave_22_config": {source_room: "rm_cave_21_config", destination_room: "rm_cave_22_config", transition_type: "platformer", length: 510, obstacles: [{"type": "gap", "position": 150, "size": 60}, {"type": "moving_platform", "position": 330}], collectibles: ["gem", "key"], enemies: [{"type": "walker", "position": 280}]},
                "rm_cave_22_config_to_rm_cave_23_config": {source_room: "rm_cave_22_config", destination_room: "rm_cave_23_config", transition_type: "platformer", length: 520, obstacles: [{"type": "spikes", "position": 260}], collectibles: ["coin", "gem"], enemies: []},
                "rm_cave_23_config_to_rm_cave_24_config": {source_room: "rm_cave_23_config", destination_room: "rm_cave_24_config", transition_type: "platformer", length: 540, obstacles: [{"type": "gap", "position": 160, "size": 80}, {"type": "spikes", "position": 300}, {"type": "moving_platform", "position": 420}], collectibles: ["trophy", "gem", "power_up"], enemies: [{"type": "walker", "position": 220}, {"type": "flyer", "position": 390}]}
                }
            },
            // Обратные переходы (из уровней в город)
            reverse_transitions: {
                // Из любого уровня обратно в город
                "any_level_to_rm_town": {
                    source_room_pattern: "rm_cave_",
                    destination_room: "rm_town",
                    transition_type: "platformer_short",
                    length: 200,
                    obstacles: [{"type": "gap", "position": 100, "size": 50}],
                    collectibles: ["coin"],
                    enemies: []
                }
            },
            current_transition: null,
            transition_in_progress: false
        };
    }
}

// Функция проверки завершения уровня и начала перехода
function find_room_by_name(room_name) {
    var room_asset = asset_get_index(room_name);
    if (room_asset != -1 && asset_get_type(room_asset) == asset_room) {
        return room_asset;
    }

    return -1;
}

function get_transition_level_count() {
    if (variable_global_exists("game_progress") && variable_struct_exists(global.game_progress, "levels")) {
        return max(1, array_length(global.game_progress.levels));
    }

    return TRANSITION_DEFAULT_LEVEL_COUNT;
}

function check_level_completion_for_transition(current_room) {
    init_level_transitions();
    
    // Получаем номер текущего уровня
    var current_level_num = extract_level_number_from_room(current_room);
    
    var total_levels = get_transition_level_count();
    if (current_level_num > 0 && current_level_num < total_levels) {
        var next_level_num = current_level_num + 1;
        var next_room = get_room_name_for_level(next_level_num);
        var transition_key = current_room + "_to_" + next_room;
        
        if (variable_struct_exists(global.level_transition_data.transitions, transition_key)) {
            return global.level_transition_data.transitions[$ transition_key];
        }
    }
    
    return null;
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

// Получить имя комнаты для уровня
function get_room_name_for_level(level_num) {
    switch(level_num) {
        case 1: return "rm_cave_maze";
        case 2: return "rm_cave_archive";
        case 3: return "rm_cave_rhythm";
        case 4: return "rm_cave_pairs";
        case 5: return "rm_cave_platformer";
        case 6: return "rm_cave_final";
        case 7: return "rm_cave_7_config";
        case 8: return "rm_cave_8_config";
        case 9: return "rm_cave_9_config";
        case 10: return "rm_cave_10_config";
        case 11: return "rm_cave_11_config";
        case 12: return "rm_cave_12_config";
        case 13: return "rm_cave_13_config";
        case 14: return "rm_cave_14_config";
        case 15: return "rm_cave_15_config";
        case 16: return "rm_cave_16_config";
        case 17: return "rm_cave_17_config";
        case 18: return "rm_cave_18_config";
        case 19: return "rm_cave_19_config";
        case 20: return "rm_cave_20_config";
        case 21: return "rm_cave_21_config";
        case 22: return "rm_cave_22_config";
        case 23: return "rm_cave_23_config";
        case 24: return "rm_cave_24_config";
        default: return "";
    }
}

// Инициировать переход между уровнями
function initiate_level_transition(transition_data) {
    if (transition_data == null) return;
    
    global.level_transition_data.current_transition = transition_data;
    global.level_transition_data.transition_in_progress = true;
    
    // Временно переходим к комнате перехода (в будущем будет специальная комната)
    // Пока что сразу переходим к следующему уровню
    var dest_room_index = find_room_by_name(transition_data.destination_room);
    if (dest_room_index != -1) {
        room_goto(dest_room_index);
        
        // После перехода перемещаем игрока в начальную позицию уровня
        with (obj_player) {
            x = 50;
            y = 550;
        }
    }
}

// Завершить переход
function complete_level_transition() {
    global.level_transition_data.current_transition = null;
    global.level_transition_data.transition_in_progress = false;
}

// Создать комнату перехода
function create_transition_room(transition_data) {
    // Эта функция будет создавать временную комнату для перехода
    // Пока не реализована полностью, так как зависит от GameMaker Editor
    // Вместо этого мы будем использовать прямой переход
    return true;
}

// Проверить, идет ли сейчас переход
function is_transition_in_progress() {
    if (!variable_global_exists("level_transition_data") || global.level_transition_data == undefined) {
        init_level_transitions();
    }
    return global.level_transition_data.transition_in_progress;
}

// Получить текущий переход
function get_current_transition() {
    if (!variable_global_exists("level_transition_data") || global.level_transition_data == undefined) {
        init_level_transitions();
    }
    return global.level_transition_data.current_transition;
}

// Обработка завершения уровня с переходом
function handle_level_complete_with_transition(level_num, current_room_name) {
    // Отмечаем уровень как завершенный
    if (array_length(global.game_progress.levels) > level_num - 1) {
        global.game_progress.levels[level_num - 1].completed = true;
    } else {
        // Если массив еще мал, расширяем его
        while (array_length(global.game_progress.levels) <= level_num - 1) {
            var new_level_data = {completed: false, lever_pulled: false};
            array_push(global.game_progress.levels, new_level_data);
        }
        global.game_progress.levels[level_num - 1].completed = true;
    }
    
    // Проверяем, есть ли переход к следующему уровню
    var transition_data = check_level_completion_for_transition(current_room_name);
    
    if (transition_data != null) {
        // Инициируем переход к следующему уровню
        initiate_level_transition(transition_data);
    } else {
        // Если нет перехода, возвращаем в город
        var town_room_index = find_room_by_name("rm_town");
        if (town_room_index != -1) {
            room_goto(town_room_index);
            
            // Перемещаем игрока в центр города
            with (obj_player) {
                x = 400;
                y = 400;
            }
            
            global.game_state = "town";
        }
    }
    
    if (script_exists(play_event_sound)) {
        play_event_sound("level_complete");
    }
}
