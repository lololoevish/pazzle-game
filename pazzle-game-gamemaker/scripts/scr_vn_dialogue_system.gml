/*
 * VN Dialogue System
 * Система управления диалогами для визуальной новеллы
 */

// Инициализация диалоговой системы
function vn_dialogue_init() {
    global.vn_dialogue = {
        active: false,
        current_node: undefined,
        current_node_id: "",
        dialogue_tree: {},
        history: [],
        current_speaker_position: "left",
        character_id: "",
        choices_visible: false,
        current_choices: []
    };
}

// Загрузить дерево диалогов
function vn_load_dialogue_tree(tree_id) {
    // Получаем дерево диалогов по ID
    global.vn_dialogue.dialogue_tree = vn_get_dialogue_data(tree_id);
}

// Получить данные диалога (заглушка для примера)
function vn_get_dialogue_data(tree_id) {
    // В реальной реализации это будет загрузка из JSON
    // Пока возвращаем пример
    
    switch (tree_id) {
        case "mechanic_greeting":
            return {
                start: {
                    speaker: "mechanic",
                    emotion: "neutral",
                    text: "Приветствую, путник! Я Роан, местный механик.",
                    next: "intro_2"
                },
                intro_2: {
                    speaker: "mechanic",
                    emotion: "happy",
                    text: "Если нужна помощь с механизмами в пещерах, обращайся!",
                    next: "end"
                }
            };
        
        case "archivist_greeting":
            return {
                start: {
                    speaker: "archivist",
                    emotion: "neutral",
                    text: "Добро пожаловать в архив древних знаний.",
                    choices: [
                        {text: "Расскажи об архиве", next: "about"},
                        {text: "Хочу пройти викторину", next: "quiz"},
                        {text: "До встречи", next: "end"}
                    ]
                },
                about: {
                    speaker: "archivist",
                    emotion: "thinking",
                    text: "Этот архив хранит знания многих поколений...",
                    next: "start"
                },
                quiz: {
                    speaker: "archivist",
                    emotion: "happy",
                    text: "Отлично! Начнем викторину.",
                    next: "end"
                }
            };
        
        case "elder_greeting":
            return {
                start: {
                    speaker: "elder",
                    emotion: "neutral",
                    text: "Приветствую тебя, путник. Я староста этой деревни.",
                    next: "intro_2"
                },
                intro_2: {
                    speaker: "elder",
                    emotion: "proud",
                    text: "Если готов к испытанию, дай знать.",
                    next: "end"
                }
            };
        
        default:
            return {
                start: {
                    speaker: "unknown",
                    emotion: "neutral",
                    text: "...",
                    next: "end"
                }
            };
    }
}

// Начать диалог
function vn_start_dialogue(node_id, character_id, position) {
    global.vn_dialogue.active = true;
    global.vn_dialogue.character_id = character_id;
    global.vn_dialogue.current_speaker_position = position;
    global.vn_dialogue.current_node_id = node_id;
    global.vn_dialogue.current_node = global.vn_dialogue.dialogue_tree[$ node_id];
    global.vn_dialogue.choices_visible = false;
    
    if (global.vn_dialogue.current_node == undefined) {
        show_debug_message("ERROR: Dialogue node '" + node_id + "' not found");
        vn_end_dialogue();
        return;
    }
    
    var node = global.vn_dialogue.current_node;
    
    // Показать портрет
    vn_show_portrait(character_id, node.emotion, position);
    vn_set_active_speaker(position);
    
    // Начать печать текста
    vn_text_start(node.text);
    
    // Применить аудио-контекст
    if (script_exists(apply_audio_context)) {
        apply_audio_context("dialogue");
    }
}

// Продолжить диалог
function vn_advance_dialogue() {
    if (!global.vn_dialogue.active) return;
    
    var node = global.vn_dialogue.current_node;
    
    if (!vn_text_is_finished()) {
        // Пропустить печать текста
        vn_text_skip();
    } else {
        // Если есть выборы, показываем их
        if (variable_struct_exists(node, "choices") && array_length(node.choices) > 0) {
            if (!global.vn_dialogue.choices_visible) {
                vn_show_choices(node.choices);
            }
        } 
        // Иначе переходим к следующему узлу
        else if (variable_struct_exists(node, "next")) {
            vn_goto_node(node.next);
        } 
        // Или завершаем диалог
        else {
            vn_end_dialogue();
        }
    }
}

// Показать выборы
function vn_show_choices(choices) {
    global.vn_dialogue.choices_visible = true;
    global.vn_dialogue.current_choices = choices;
}

// Выбрать вариант
function vn_select_choice(choice_index) {
    if (choice_index < 0 || choice_index >= array_length(global.vn_dialogue.current_choices)) {
        return;
    }
    
    var choice = global.vn_dialogue.current_choices[choice_index];
    global.vn_dialogue.choices_visible = false;
    
    if (script_exists(play_event_sound)) {
        play_event_sound("ui_confirm");
    }
    
    vn_goto_node(choice.next);
}

// Перейти к узлу
function vn_goto_node(node_id) {
    if (node_id == "end") {
        vn_end_dialogue();
        return;
    }
    
    if (!variable_struct_exists(global.vn_dialogue.dialogue_tree, node_id)) {
        show_debug_message("ERROR: Dialogue node '" + node_id + "' not found");
        vn_end_dialogue();
        return;
    }
    
    var node = global.vn_dialogue.dialogue_tree[$ node_id];
    global.vn_dialogue.current_node = node;
    global.vn_dialogue.current_node_id = node_id;
    
    // Изменить эмоцию если нужно
    if (variable_struct_exists(node, "emotion")) {
        vn_change_emotion(global.vn_dialogue.current_speaker_position, node.emotion);
    }
    
    // Начать печать нового текста
    vn_text_start(node.text);
    
    // Добавить в историю
    array_push(global.vn_dialogue.history, node_id);
}

// Завершить диалог
function vn_end_dialogue() {
    global.vn_dialogue.active = false;
    global.vn_dialogue.choices_visible = false;
    
    vn_hide_all_portraits();
    
    // Вернуть нормальный аудио-контекст
    if (script_exists(apply_audio_context)) {
        apply_audio_context("town");
    }
}

// Проверка активности диалога
function vn_is_dialogue_active() {
    return global.vn_dialogue.active;
}

// Получить текущие выборы
function vn_get_current_choices() {
    return global.vn_dialogue.current_choices;
}

// Проверка видимости выборов
function vn_are_choices_visible() {
    return global.vn_dialogue.choices_visible;
}

// Очистка диалоговой системы
function vn_dialogue_cleanup() {
    vn_end_dialogue();
    global.vn_dialogue = {
        active: false,
        current_node: undefined,
        current_node_id: "",
        dialogue_tree: {},
        history: [],
        current_speaker_position: "left",
        character_id: "",
        choices_visible: false,
        current_choices: []
    };
}
