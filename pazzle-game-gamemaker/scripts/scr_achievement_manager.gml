/*
 * Achievement Manager
 * Управляет системой достижений
 */

// Глобальная структура достижений
global.achievements = {
    list: [],
    unlocked_count: 0,
    total_count: 0,
    initialized: false
};

// Инициализация системы достижений
function init_achievements() {
    if (global.achievements.initialized) return;
    
    // Определяем все достижения
    global.achievements.list = [
        // Прогресс
        create_achievement("ACH_FIRST_STEPS", "Первые шаги", "Завершите первую пещеру", 
            "progress", 10, [], "spr_ach_first_steps", false),
        create_achievement("ACH_HALFWAY_THERE", "На полпути", "Завершите первые 6 пещер", 
            "progress", 50, [], "spr_ach_halfway", false),
        create_achievement("ACH_EXPEDITION_COMPLETE", "Экспедиция завершена", "Завершите все 12 пещер", 
            "progress", 100, ["special_compass"], "spr_ach_expedition_complete", false),
        create_achievement("ACH_PERFECT_RUN", "Безупречное прохождение", "Завершите все пещеры без единой смерти", 
            "progress", 200, [], "spr_ach_perfect_run", false),
        
        // Мастерство
        create_achievement("ACH_SPEED_DEMON", "Демон скорости", "Завершите любую пещеру менее чем за 2 минуты", 
            "mastery", 30, [], "spr_ach_speed_demon", false),
        create_achievement("ACH_PUZZLE_MASTER", "Мастер головоломок", "Решите головоломку с первой попытки в 5 разных пещерах", 
            "mastery", 50, [], "spr_ach_puzzle_master", false),
        create_achievement("ACH_NO_HINTS", "Без подсказок", "Завершите 3 пещеры без использования подсказок", 
            "mastery", 40, [], "spr_ach_no_hints", false),
        
        // Исследование
        create_achievement("ACH_SOCIAL_BUTTERFLY", "Душа компании", "Поговорите со всеми NPC в городе", 
            "exploration", 20, [], "spr_ach_social", false),
        create_achievement("ACH_TRIAL_MASTER", "Мастер испытаний", "Завершите все мини-игры NPC", 
            "exploration", 60, [], "spr_ach_trial_master", false),
        create_achievement("ACH_LORE_KEEPER", "Хранитель знаний", "Прочитайте все таблички и записи в пещерах", 
            "exploration", 30, [], "spr_ach_lore_keeper", false),
        
        // Коллекционирование
        create_achievement("ACH_TREASURE_HUNTER", "Охотник за сокровищами", "Соберите 100 золота", 
            "collection", 0, ["treasure_map"], "spr_ach_treasure_hunter", false),
        create_achievement("ACH_CRYSTAL_COLLECTOR", "Коллекционер кристаллов", "Соберите все кристаллы в пещерах", 
            "collection", 50, [], "spr_ach_crystal_collector", false),
        create_achievement("ACH_ITEM_HOARDER", "Накопитель", "Соберите 10 различных предметов", 
            "collection", 40, [], "spr_ach_item_hoarder", false),
        
        // Секретные
        create_achievement("ACH_SECRET_PATH", "???", "Найдите секретный путь", 
            "secret", 100, [], "spr_ach_secret_path", true),
        create_achievement("ACH_EASTER_EGG", "???", "Найдите пасхальное яйцо разработчиков", 
            "secret", 0, ["dev_token"], "spr_ach_easter_egg", true),
        create_achievement("ACH_SPEEDRUN_LEGEND", "???", "Завершите всю игру менее чем за 30 минут", 
            "secret", 300, ["speedrun_trophy"], "spr_ach_speedrun_legend", true)
    ];
    
    global.achievements.total_count = array_length(global.achievements.list);
    global.achievements.initialized = true;
    
    // Загружаем сохраненные достижения
    load_achievements();
    
    show_debug_message("Achievement system initialized: " + string(global.achievements.total_count) + " achievements");
}

// Создание структуры достижения
function create_achievement(id, name, description, category, reward_gold, reward_items, icon, hidden) {
    return {
        achievement_id: id,
        name: name,
        description: description,
        category: category,
        unlocked: false,
        unlock_date: undefined,
        progress: 0,
        progress_max: 1,
        reward_gold: reward_gold,
        reward_items: reward_items,
        icon: icon,
        hidden: hidden
    };
}

// Проверка условий достижений
function check_achievement_condition(achievement_id) {
    switch (achievement_id) {
        case "ACH_FIRST_STEPS":
            return global.game_progress.levels[0].lever_pulled;
        
        case "ACH_HALFWAY_THERE":
            var count = 0;
            for (var i = 0; i < 6; i++) {
                if (global.game_progress.levels[i].lever_pulled) count++;
            }
            return count >= 6;
        
        case "ACH_EXPEDITION_COMPLETE":
            var count = 0;
            for (var i = 0; i < 12; i++) {
                if (global.game_progress.levels[i].lever_pulled) count++;
            }
            return count >= 12;
        
        case "ACH_PERFECT_RUN":
            if (!variable_global_exists("death_count")) global.death_count = 0;
            var all_completed = true;
            for (var i = 0; i < 12; i++) {
                if (!global.game_progress.levels[i].lever_pulled) {
                    all_completed = false;
                    break;
                }
            }
            return all_completed && global.death_count == 0;
        
        case "ACH_SPEED_DEMON":
            if (!variable_global_exists("fastest_level_time")) return false;
            return global.fastest_level_time < 120; // 2 минуты
        
        case "ACH_PUZZLE_MASTER":
            if (!variable_global_exists("perfect_puzzles")) global.perfect_puzzles = 0;
            return global.perfect_puzzles >= 5;
        
        case "ACH_NO_HINTS":
            if (!variable_global_exists("no_hint_levels")) global.no_hint_levels = 0;
            return global.no_hint_levels >= 3;
        
        case "ACH_SOCIAL_BUTTERFLY":
            if (!variable_global_exists("npcs_talked")) global.npcs_talked = [];
            return array_length(global.npcs_talked) >= 3; // Elder, Mechanic, Archivist
        
        case "ACH_TRIAL_MASTER":
            return global.game_progress.elder_trial_completed &&
                   global.game_progress.mechanic_training_completed &&
                   global.game_progress.archivist_quiz_completed;
        
        case "ACH_LORE_KEEPER":
            if (!variable_global_exists("lore_items_read")) global.lore_items_read = 0;
            if (!variable_global_exists("total_lore_items")) global.total_lore_items = 20;
            return global.lore_items_read >= global.total_lore_items;
        
        case "ACH_TREASURE_HUNTER":
            return global.game_progress.gold >= 100;
        
        case "ACH_CRYSTAL_COLLECTOR":
            if (!variable_global_exists("crystals_collected")) global.crystals_collected = 0;
            if (!variable_global_exists("total_crystals")) global.total_crystals = 50;
            return global.crystals_collected >= global.total_crystals;
        
        case "ACH_ITEM_HOARDER":
            return array_length(global.game_progress.items) >= 10;
        
        case "ACH_SECRET_PATH":
            if (!variable_global_exists("secret_room_found")) global.secret_room_found = false;
            return global.secret_room_found;
        
        case "ACH_EASTER_EGG":
            if (!variable_global_exists("easter_egg_found")) global.easter_egg_found = false;
            return global.easter_egg_found;
        
        case "ACH_SPEEDRUN_LEGEND":
            if (!variable_global_exists("total_game_time")) return false;
            var all_completed = true;
            for (var i = 0; i < 12; i++) {
                if (!global.game_progress.levels[i].lever_pulled) {
                    all_completed = false;
                    break;
                }
            }
            return all_completed && global.total_game_time < 1800; // 30 минут
    }
    
    return false;
}

// Разблокировка достижения
function unlock_achievement(achievement_id) {
    var achievement = get_achievement_by_id(achievement_id);
    
    if (achievement == undefined) {
        show_debug_message("Achievement not found: " + achievement_id);
        return false;
    }
    
    if (achievement.unlocked) {
        return false; // Уже разблокировано
    }
    
    // Разблокируем
    achievement.unlocked = true;
    achievement.unlock_date = date_current_datetime();
    global.achievements.unlocked_count++;
    
    // Выдаем награды
    if (achievement.reward_gold > 0) {
        global.game_progress.gold += achievement.reward_gold;
    }
    
    for (var i = 0; i < array_length(achievement.reward_items); i++) {
        array_push(global.game_progress.items, achievement.reward_items[i]);
    }
    
    // Показываем уведомление
    show_achievement_notification(achievement);
    
    // Воспроизводим звук
    if (script_exists(play_sfx)) {
        play_sfx("achievement_unlock");
    }
    
    // Сохраняем
    save_achievements();
    
    show_debug_message("Achievement unlocked: " + achievement_id);
    return true;
}

// Получение достижения по ID
function get_achievement_by_id(achievement_id) {
    for (var i = 0; i < array_length(global.achievements.list); i++) {
        if (global.achievements.list[i].achievement_id == achievement_id) {
            return global.achievements.list[i];
        }
    }
    return undefined;
}

// Проверка всех достижений
function check_all_achievements() {
    if (!global.achievements.initialized) return;
    
    for (var i = 0; i < array_length(global.achievements.list); i++) {
        var achievement = global.achievements.list[i];
        
        if (!achievement.unlocked && check_achievement_condition(achievement.achievement_id)) {
            unlock_achievement(achievement.achievement_id);
        }
    }
}

// Показ уведомления о достижении
function show_achievement_notification(achievement) {
    var text = "Достижение разблокировано!\n" + achievement.name;
    
    if (achievement.reward_gold > 0) {
        text += "\n+" + string(achievement.reward_gold) + " золота";
    }
    
    if (array_length(achievement.reward_items) > 0) {
        text += "\nПолучен предмет!";
    }
    
    if (script_exists(show_notification)) {
        show_notification(text, 5, c_yellow);
    } else {
        show_debug_message(text);
    }
}

// Сохранение достижений
function save_achievements() {
    var save_data = {
        achievements: [],
        unlocked_count: global.achievements.unlocked_count
    };
    
    for (var i = 0; i < array_length(global.achievements.list); i++) {
        var ach = global.achievements.list[i];
        if (ach.unlocked) {
            array_push(save_data.achievements, {
                id: ach.achievement_id,
                unlock_date: ach.unlock_date
            });
        }
    }
    
    var json_string = json_stringify(save_data);
    var file = file_text_open_write("achievements_save.json");
    if (file != -1) {
        file_text_write_string(file, json_string);
        file_text_close(file);
    }
}

// Загрузка достижений
function load_achievements() {
    if (!file_exists("achievements_save.json")) return;
    
    var file = file_text_open_read("achievements_save.json");
    if (file == -1) return;
    
    var json_string = "";
    while (!file_text_eof(file)) {
        json_string += file_text_read_string(file);
        file_text_readln(file);
    }
    file_text_close(file);
    
    if (json_string == "") return;
    
    var save_data = json_parse(json_string);
    
    for (var i = 0; i < array_length(save_data.achievements); i++) {
        var saved_ach = save_data.achievements[i];
        var achievement = get_achievement_by_id(saved_ach.id);
        
        if (achievement != undefined) {
            achievement.unlocked = true;
            achievement.unlock_date = saved_ach.unlock_date;
        }
    }
    
    global.achievements.unlocked_count = save_data.unlocked_count;
}

// Получение прогресса достижений
function get_achievement_progress() {
    return {
        unlocked: global.achievements.unlocked_count,
        total: global.achievements.total_count,
        percentage: (global.achievements.unlocked_count / global.achievements.total_count) * 100
    };
}

// Получение достижений по категории
function get_achievements_by_category(category) {
    var result = [];
    
    for (var i = 0; i < array_length(global.achievements.list); i++) {
        var ach = global.achievements.list[i];
        if (ach.category == category) {
            array_push(result, ach);
        }
    }
    
    return result;
}

// Сброс всех достижений (для тестирования)
function reset_all_achievements() {
    for (var i = 0; i < array_length(global.achievements.list); i++) {
        global.achievements.list[i].unlocked = false;
        global.achievements.list[i].unlock_date = undefined;
    }
    
    global.achievements.unlocked_count = 0;
    
    if (file_exists("achievements_save.json")) {
        file_delete("achievements_save.json");
    }
    
    show_debug_message("All achievements reset");
}
