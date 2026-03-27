# План интеграции механик из Deltarune в "Adventure Puzzle Game"

## Обзор

Этот документ описывает возможные доработки "Adventure Puzzle Game" с внедрением механик из серии игр Deltarune/Deltarune. Цель - улучшить геймплей за счет добавления новых элементов, таких как время K.O., запоминание команд, управляемый прыжок и другие особенности Deltarune.

## 1. Время K.O. (Knock Out Time)

### Описание
Введение временной механики, при которой игроку дается ограниченное время для выполнения определенных действий в головоломках, особенно в мини-играх у NPC.

### Техническая реализация
- Добавить таймер в `obj_npc_mechanic_game`, `obj_npc_archivist_quiz`, и `obj_npc_elder_trial`
- Ввести систему "стресса" на основе оставшегося времени
- Реализовать визуальный индикатор таймера (красная полоса, мигающие элементы)

### Влияние на геймплей
- Повышает напряжение и драматизм в мини-играх
- Может влиять на награды (лучшие награды за быстрое выполнение)
- Введение "режима тренировки" без таймера для новичков

### Кодовая реализация
```gml
// В скриптах мини-игр
var ko_timer_active = false;
var ko_time_limit = 30; // секунд
var ko_current_time = 0;

function start_ko_timer(limit) {
    ko_timer_active = true;
    ko_time_limit = limit;
    ko_current_time = 0;
}

function update_ko_timer(dt) {
    if (ko_timer_active) {
        ko_current_time += dt;
        if (ko_current_time >= ko_time_limit) {
            trigger_ko_event(); // Вызов специального события при исчерпании времени
        }
    }
}

function draw_ko_timer() {
    if (ko_timer_active) {
        var remaining = ko_time_limit - ko_current_time;
        var percentage = remaining / ko_time_limit;
        
        // Рисуем красную полосу таймера
        draw_set_color(make_color_rgb(255, min(255, percentage * 255), min(255, percentage * 255)));
        draw_rectangle(10, 10, 10 + 200 * percentage, 30);
        draw_set_color(c_white);
        draw_text(15, 15, "ВРЕМЯ: " + string(floor(remaining)));
    }
}
```

## 2. Система запоминания команд

### Описание
Введение системы, при которой игрок может "записывать" последовательности своих действий и воспроизводить их позже в головоломках.

### Техническая реализация
- Создать глобальную систему команд (команды движения, взаимодействия, специальных действий)
- Добавить возможность записи и воспроизведения последовательностей
- Реализовать систему хранения команд (в инвентаре или отдельной вкладке)

### Влияние на геймплей
- Комплексные головоломки, требующие многократного выполнения одних и тех же действий
- Возможность "тренировки" последовательности
- Логические головоломки на основе повторения паттернов

### Кодовая реализация
```gml
// Глобальная система команд
var command_system = {
    recording: false,
    replaying: false,
    current_sequence: [],
    recorded_sequences: [],
    current_command_index: 0
};

function start_recording_sequence() {
    command_system.recording = true;
    command_system.current_sequence = [];
}

function record_command(command_type, params) {
    if (command_system.recording) {
        var command = {
            type: command_type,
            params: params,
            timestamp: game_time
        };
        array_push(command_system.current_sequence, command);
    }
}

function finish_recording() {
    if (command_system.recording) {
        command_system.recording = false;
        // Сохраняем последовательность
        var sequence_id = array_length(command_system.recorded_sequences);
        array_push(command_system.recorded_sequences, command_system.current_sequence);
        return sequence_id;
    }
    return -1;
}

function replay_sequence(sequence_id) {
    if (sequence_id >= 0 && sequence_id < array_length(command_system.recorded_sequences)) {
        command_system.replaying = true;
        command_system.current_sequence = command_system.recorded_sequences[sequence_id];
        command_system.current_command_index = 0;
    }
}

function update_replay() {
    if (command_system.replaying && array_length(command_system.current_sequence) > 0) {
        // Выполняем команду
        var command = command_system.current_sequence[command_system.current_command_index];
        execute_command(command.type, command.params);
        
        command_system.current_command_index++;
        if (command_system.current_command_index >= array_length(command_system.current_sequence)) {
            command_system.replaying = false;
        }
    }
}
```

## 3. Управляемый прыжок

### Описание
Добавление управления прыжком игрока в головоломках, особенно в платформерной головоломке (уровень 5). Позволяет игроку контролировать высоту и направление прыжка.

### Техническая реализация
- Добавить физику прыжков в `obj_player`
- Реализовать плавное управление прыжком
- Добавить систему "воздушного контроля" и "подруливания в прыжке"

### Влияние на геймплей
- Более точное управление в платформерной головоломке
- Введение новых элементов дизайна уровней
- Требует больше навыков и практики

### Кодовая реализация
```gml
// В объекте игрока
var jump_control = {
    air_control: true,
    air_control_strength: 0.7,
    jump_height_multiplier: 1.0,
    max_air_jumps: 1,
    current_air_jumps: 0
};

function handle_jump_controls() {
    if (kbd_check_pressed(vk_space) || kbd_check_pressed(ord('Z'))) {
        if (on_ground || jump_control.current_air_jumps < jump_control.max_air_jumps) {
            velocity_y = -jump_power;
            if (!on_ground) jump_control.current_air_jumps++;
        }
    }
    
    // Воздушное управление
    if (!on_ground && jump_control.air_control) {
        if (kbd_check(vk_left)) {
            velocity_x -= jump_control.air_control_strength;
        }
        if (kbd_check(vk_right)) {
            velocity_x += jump_control.air_control_strength;
        }
        
        // Ограничение горизонтальной скорости
        velocity_x = clamp(velocity_x, -max_h_speed, max_h_speed);
    }
}

function reset_air_jumps() {
    jump_control.current_air_jumps = 0;
}
```

## 4. Дополнительные механики Deltarune

### 4.1. Система "Дружбы" (Friendship System)
- Механика взаимодействия с NPC на основе отношений
- Разные диалоги и награды в зависимости от "уровня дружбы"
- Возможность "уважительного" преодоления конфликтов

### 4.2. Система "Пощады" (Mercy System)
- Возможность "пощадить" врагов в бою (если будет добавлена боевая система)
- Награды за ненасильственное прохождение
- Моральные выборы в геймплее

### 4.3. Система "Паттернов"
- Повторяющиеся визуальные/аудио паттерны в головоломках
- Механика распознавания и предсказания паттернов
- Активное внимание к деталям

### 4.4. "Скрытые" элементы
- Секретные головоломки или комнаты
- Элементы, видимые только при определенных условиях
- Вознаграждение за исследование

## 5. Интеграция с существующими системами

### 5.1. Совместимость с головоломками
- Каждая головоломка может иметь "режим Deltarune" с дополнительными механиками
- Новые головоломки, использующие комбинации механик (таймер + команды + прыжки)
- Сложность регулируется на основе уровня игрока

### 5.2. Интерфейсные улучшения
- Интерфейс для показа активных "режимов"
- Панель управления записью команд
- Визуальный таймер для режима K.O.
- Индикатор "дружбы" у NPC

### 5.3. Сохранение баланса
- Не перегружать существующие головоломки новыми механиками
- Введение "режимов" (классический vs. Deltarune-режим)
- Постепенное открытие новых механик по мере прохождения

## 6. Техническая интеграция

### 6.1. Глобальные переменные
```gml
global.deltarune_features = {
    ko_mode_enabled: false,
    command_recording_enabled: false,
    jump_control_enabled: false,
    friendship_system_enabled: false,
    mercy_system_enabled: false
};
```

### 6.2. Система настроек
- Меню настроек с включением/выключением новых механик
- Система "режимов" для разных стилей игры
- Возможность переключения между "классическим" и "Deltarune" режимами

### 6.3. Обратная совместимость
- Сохранение оригинальных головоломок
- Добавление новых версий с новыми механиками
- Проверка настроек при запуске головоломок

## 7. План реализации

### Этап 1: Время K.O. (Неделя 1-2)
- Добавление таймеров в существующие мини-игры
- Создание визуальных эффектов для таймера
- Тестирование влияния на геймплей

### Этап 2: Система команд (Неделя 3-4)
- Реализация базовой системы записи команд
- Добавление в головоломку лабиринта
- Тестирование сценариев использования

### Этап 3: Управляемый прыжок (Неделя 5-6)
- Улучшение физики платформера
- Добавление воздушного управления
- Балансировка сложности

### Этап 4: Интеграция и тестирование (Неделя 7-8)
- Объединение всех механик
- Тестирование обратной совместимости
- Балансировка новой сложности

### Этап 5: Дополнительные механики (Неделя 9-10)
- Системы дружбы и пощады
- Паттерн-распознавание
- Скрытые элементы и секреты

## 8. Влияние на существующий баланс

### 8.1. Плюсы
- Более глубокий и интересный геймплей
- Возможность для повторного прохождения
- Разнообразие стилей игры (расслабленный vs. напряженный)
- Увеличение времени в игре

### 8.2. Риски
- Сложность для новых игроков
- Потенциальное усложнение существующих головоломок
- Необходимость балансировки

### 8.3. Меры предосторожности
- Введение системы настроек для выбора сложности
- Сохранение оригинальных версий головоломок
- Добавление учебных режимов для новых механик

Этот план позволяет постепенно внедрить элементы Deltarune в "Adventure Puzzle Game", не нарушая существующий баланс, но добавляя новые уровни глубины и сложности для опытных игроков.