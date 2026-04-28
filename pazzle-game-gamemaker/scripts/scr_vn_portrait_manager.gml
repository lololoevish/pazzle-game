/*
 * VN Portrait Manager
 * Управление портретами персонажей для визуальной новеллы
 */

// Инициализация менеджера портретов
function vn_portrait_init() {
    global.vn_portraits = {
        left: undefined,
        center: undefined,
        right: undefined
    };
    
    global.vn_portrait_positions = {
        left: {x: 50, y: 150},
        center: {x: 300, y: 150},
        right: {x: 550, y: 150}
    };
}

// Показать портрет
function vn_show_portrait(character_id, emotion, position) {
    if (!variable_struct_exists(global.vn_portrait_positions, position)) {
        show_debug_message("WARNING: Invalid portrait position '" + position + "'");
        return;
    }
    
    var sprite = vn_get_portrait_sprite(character_id, emotion);
    
    if (sprite == -1) {
        show_debug_message("WARNING: Portrait sprite not found for " + character_id + "_" + emotion);
        return;
    }
    
    global.vn_portraits[$ position] = {
        character: character_id,
        emotion: emotion,
        sprite: sprite,
        alpha: 0,
        target_alpha: 1.0,
        scale: 1.0,
        offset_y: 0,
        bounce: false
    };
}

// Скрыть портрет
function vn_hide_portrait(position) {
    if (global.vn_portraits[$ position] != undefined) {
        global.vn_portraits[$ position].target_alpha = 0;
    }
}

// Скрыть все портреты
function vn_hide_all_portraits() {
    vn_hide_portrait("left");
    vn_hide_portrait("center");
    vn_hide_portrait("right");
}

// Изменить эмоцию
function vn_change_emotion(position, new_emotion) {
    var portrait = global.vn_portraits[$ position];
    if (portrait != undefined) {
        portrait.emotion = new_emotion;
        portrait.sprite = vn_get_portrait_sprite(portrait.character, new_emotion);
        portrait.bounce = true; // Небольшой эффект при смене эмоции
    }
}

// Получить спрайт портрета
function vn_get_global_sprite_resource(variable_name) {
    if (variable_global_exists(variable_name)) {
        return variable_global_get(variable_name);
    }

    return -1;
}

function vn_get_portrait_sprite(character_id, emotion) {
    var sprite_name = "spr_portrait_" + character_id + "_" + emotion;
    
    // Проверяем существование через глобальные переменные
    switch (sprite_name) {
        case "spr_portrait_mechanic_neutral":
            return vn_get_global_sprite_resource("spr_portrait_mechanic_neutral");
        case "spr_portrait_mechanic_happy":
            return vn_get_global_sprite_resource("spr_portrait_mechanic_happy");
        case "spr_portrait_mechanic_thinking":
            return vn_get_global_sprite_resource("spr_portrait_mechanic_thinking");
        case "spr_portrait_mechanic_worried":
            return vn_get_global_sprite_resource("spr_portrait_mechanic_worried");
        
        case "spr_portrait_archivist_neutral":
            return vn_get_global_sprite_resource("spr_portrait_archivist_neutral");
        case "spr_portrait_archivist_happy":
            return vn_get_global_sprite_resource("spr_portrait_archivist_happy");
        case "spr_portrait_archivist_thinking":
            return vn_get_global_sprite_resource("spr_portrait_archivist_thinking");
        case "spr_portrait_archivist_serious":
            return vn_get_global_sprite_resource("spr_portrait_archivist_serious");
        
        case "spr_portrait_elder_neutral":
            return vn_get_global_sprite_resource("spr_portrait_elder_neutral");
        case "spr_portrait_elder_happy":
            return vn_get_global_sprite_resource("spr_portrait_elder_happy");
        case "spr_portrait_elder_stern":
            return vn_get_global_sprite_resource("spr_portrait_elder_stern");
        case "spr_portrait_elder_proud":
            return vn_get_global_sprite_resource("spr_portrait_elder_proud");
        
        default:
            return -1;
    }
}

// Обновление портретов (плавное появление/исчезновение)
function vn_update_portraits() {
    var positions = ["left", "center", "right"];
    
    for (var i = 0; i < array_length(positions); i++) {
        var pos = positions[i];
        var portrait = global.vn_portraits[$ pos];
        
        if (portrait != undefined) {
            // Плавное изменение прозрачности
            if (portrait.alpha < portrait.target_alpha) {
                portrait.alpha = min(portrait.alpha + 0.05, portrait.target_alpha);
            } else if (portrait.alpha > portrait.target_alpha) {
                portrait.alpha = max(portrait.alpha - 0.05, portrait.target_alpha);
            }
            
            // Эффект bounce при смене эмоции
            if (portrait.bounce) {
                portrait.offset_y = sin(current_time / 100) * 5;
                if (abs(portrait.offset_y) < 0.5) {
                    portrait.bounce = false;
                    portrait.offset_y = 0;
                }
            }
            
            // Удалить если полностью прозрачный
            if (portrait.alpha <= 0 && portrait.target_alpha <= 0) {
                global.vn_portraits[$ pos] = undefined;
            }
        }
    }
}

// Отрисовка портретов
function vn_draw_portraits() {
    var positions = ["left", "center", "right"];
    
    for (var i = 0; i < array_length(positions); i++) {
        var pos = positions[i];
        var portrait = global.vn_portraits[$ pos];
        
        if (portrait != undefined && portrait.alpha > 0) {
            var pos_data = global.vn_portrait_positions[$ pos];
            var draw_x = pos_data.x;
            var draw_y = pos_data.y + portrait.offset_y;
            
            // Затемнение неактивных портретов
            var color = c_white;
            var alpha = portrait.alpha;
            
            // Если это не говорящий персонаж, затемняем
            if (variable_global_exists("vn_dialogue") && global.vn_dialogue != undefined &&
                global.vn_dialogue.active && 
                global.vn_dialogue.current_speaker_position != pos) {
                alpha *= 0.5;
            }
            
            draw_sprite_ext(portrait.sprite, 0, draw_x, draw_y, 
                          portrait.scale, portrait.scale, 0, color, alpha);
        }
    }
}

// Установить активного говорящего (подсветка)
function vn_set_active_speaker(position) {
    if (variable_global_exists("vn_dialogue") && global.vn_dialogue != undefined) {
        global.vn_dialogue.current_speaker_position = position;
    }
}

// Очистка системы портретов
function vn_portrait_cleanup() {
    global.vn_portraits = {
        left: undefined,
        center: undefined,
        right: undefined
    };
}
