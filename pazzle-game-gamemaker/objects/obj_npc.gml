// Объект NPC для GameMaker
// Используется для взаимодействия с персонажами в городе-хабе

// Create Event
{
    // Начальная позиция и спрайт
    sprite_index = spr_npc_default;
    
    // Свойства NPC
    npc_name = "";
    npc_dialogue = [];
    interaction_distance = 48;
    
    // Тип NPC (для определения мини-игры)
    npc_type = "generic"; // "elder", "mechanic", "archivist"
    
    // Состояние взаимодействия
    in_dialogue = false;
}

// Step Event
{
    if (in_dialogue) {
        if (keyboard_check_pressed(vk_escape)) {
            end_interaction();
        }
    }
}

// Draw Event
{
    // Отображение NPC
    draw_self();
    
    // Если игрок рядом, показываем индикатор взаимодействия
    if (distance_to_object(obj_player) <= interaction_distance && !in_dialogue) {
        draw_interaction_indicator();
    }
}

// Функция отображения подсказки взаимодействия
function draw_interaction_prompt() {
    draw_sprite_ext(spr_e_key, 0, x, y - 40, 1, 1, 0, c_white, 0.7);
}

// Функция отображения индикатора взаимодействия
function draw_interaction_indicator() {
    // Маленькая иконка или кольцо вокруг NPC
    draw_circle_color(x, y, interaction_distance, c_gray, false);
}

// Функция начала взаимодействия
function start_interaction() {
    in_dialogue = true;
    npc_set_player_state("dialog");
    
    // Воспроизводим звук
    play_sfx("dialogue_start");
    
    // Открываем диалог в зависимости от типа NPC
    switch(npc_type) {
        case "elder":
            start_elder_trial();
            break;
        case "mechanic":
            start_mechanic_minigame();
            break;
        case "archivist":
            start_archivist_quiz();
            break;
        default:
            start_generic_dialogue();
    }
}

// Функция завершения взаимодействия
function end_interaction() {
    in_dialogue = false;
    if (script_exists(scr_ui_manager) && script_exists(hide_mini_game)) {
        hide_mini_game();
    }
    hide_npc_dialogue();
    npc_set_player_state("normal");
}

function npc_set_player_state(state_name) {
    var player = instance_nearest(x, y, obj_player);
    if (player != noone && variable_instance_exists(player, "set_state")) {
        player.set_state(state_name);
    }
}

// Специфичные функции для разных NPC
function start_elder_trial() {
    // Испытание старосты Иара на угадывание числа
    show_npc_dialogue("Староста Иара", "Хочешь испытать свою удачу? Угадай число от 1 до 10 за 3 попытки!");
    show_mini_game("elder_trial");
}

function start_mechanic_minigame() {
    // Калибровка механика Роана
    show_npc_dialogue("Механик Роан", "Помоги мне откалибровать мои приборы!");
    show_mini_game("mechanic_calibration");
}

function start_archivist_quiz() {
    // Викторина архивариуса Теля
    show_npc_dialogue("Архивариус Тель", "Проверим, хорошо ли ты знаешь правила экспедиции?");
    show_mini_game("archivist_quiz");
}

function start_generic_dialogue() {
    // Обычный диалог
    var first_line = "...";
    if (array_length(npc_dialogue) > 0) {
        first_line = string(npc_dialogue[0]);
    }
    show_npc_dialogue(npc_name, first_line);
}

// Функция взаимодействия (для универсального интерфейса)
function on_interact() {
    start_interaction();
}
