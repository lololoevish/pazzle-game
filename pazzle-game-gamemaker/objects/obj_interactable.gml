// Интерактивный объект для GameMaker
// Базовый объект для всех интерактивных элементов

// Create Event
{
    // Свойства объекта
    interaction_distance = 32;
    interaction_text = "";
    interactable = true;
    
    // Флаги состояния
    activated = false;
    can_be_used_once = false;
    use_count = 0;
}

// Step Event
{
    if (interactable) {
        // Проверка, находится ли игрок рядом
        var player_dist = distance_to_object(obj_player);
        if (player_dist <= interaction_distance) {
            // Проверяем нажатие E для взаимодействия
            if (keyboard_check_pressed(ord('E')) || keyboard_check_pressed(vk_enter)) {
                interact();
            }
        }
    }
}

// Draw Event
{
    // Отображение объекта
    draw_self();
    
    // Если объект интерактивен и игрок рядом
    if (interactable && distance_to_object(obj_player) <= interaction_distance) {
        draw_interaction_indicator();
    }
}

// Функция отображения подсказки взаимодействия
function draw_interaction_prompt() {
    if (string_length(interaction_text) > 0) {
        draw_text(x - string_width(interaction_text)/2, y - 30, interaction_text);
    } else {
        draw_sprite_ext(spr_e_key, 0, x, y - 40, 1, 1, 0, c_white, 0.7);
    }
}

// Функция отображения индикатора взаимодействия
function draw_interaction_indicator() {
    // Нарисовать кольцо или подсветку
    draw_circle_color(x, y, interaction_distance, c_yellow, false);
}

// Функция взаимодействия
function interact() {
    if (!activated || !can_be_used_once) {
        // Увеличиваем счетчик использования
        use_count += 1;
        
        // Вызываем специфичную логику взаимодействия
        on_interact();
        
        // Если объект может быть использован только один раз
        if (can_be_used_once) {
            activated = true;
        }
    }
}

// Функция, которую нужно переопределить в наследниках
function on_interact() {
    // Логика взаимодействия определяется в дочерних объектах
    show_debug_message("Interactable object interaction handled");
    
    // Воспроизводим звук взаимодействия
    play_sfx("interaction");
}

// Функция проверки доступности
function is_available() {
    return interactable && (!activated || !can_be_used_once);
}
