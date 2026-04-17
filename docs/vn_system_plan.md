# План реализации VN-подачи с портретами для NPC

**Дата создания**: 16.04.2026  
**Статус**: В разработке

## Цель
Создать систему визуальной новеллы (VN) с портретами персонажей для диалогов NPC, чтобы улучшить повествование и эмоциональную связь с персонажами.

## Текущее состояние

### Существующая система диалогов
- Базовая текстовая система диалогов
- Три ключевых NPC с собственными активностями
- Реактивность диалогов по наградам и финалу
- State-machine для мини-игр
- Отсутствуют портреты и визуальная подача

### Проблемы
- Диалоги выглядят плоско без визуального представления
- Нет эмоциональной выразительности персонажей
- Отсутствует ветвление диалогов с выбором
- Нет системы портретов с разными эмоциями

## Архитектура VN-системы

### Компоненты

#### 1. Система портретов (Portrait System)
```gml
// Структура портрета
portrait = {
    character_id: "npc_mechanic",
    emotion: "neutral",
    sprite: spr_portrait_mechanic_neutral,
    position: "left",  // left, center, right
    scale: 1.0,
    alpha: 1.0,
    flip: false
}

// Эмоции для каждого персонажа
emotions = ["neutral", "happy", "sad", "angry", "surprised", "thinking", "worried"]
```

#### 2. Диалоговая система (Dialogue System)
```gml
// Структура диалогового узла
dialogue_node = {
    id: "town_mechanic_intro_01",
    speaker: "npc_mechanic",
    emotion: "neutral",
    text: "Приветствую, путник! Я Роан, местный механик.",
    choices: [
        {text: "Расскажи о себе", next: "town_mechanic_about"},
        {text: "Что ты можешь предложить?", next: "town_mechanic_services"},
        {text: "До встречи", next: "end"}
    ],
    auto_advance: false,
    delay: 0
}
```

#### 3. Текстовый движок (Text Engine)
```gml
// Печатающийся текст
text_engine = {
    current_text: "",
    target_text: "",
    char_index: 0,
    speed: 2,  // символов за фрейм
    finished: false,
    skip_enabled: true
}
```

#### 4. VN UI Manager
```gml
// Управление VN интерфейсом
vn_ui = {
    dialogue_box: {x: 50, y: 400, width: 700, height: 150},
    portrait_left: {x: 50, y: 150, width: 200, height: 250},
    portrait_right: {x: 550, y: 150, width: 200, height: 250},
    name_box: {x: 50, y: 370, width: 150, height: 30},
    choice_box: {x: 100, y: 300, width: 600, height: 200}
}
```

## Необходимые ассеты

### Портреты NPC

#### NPC 1: Роан (Механик)
**Базовая информация:**
- Возраст: ~40 лет
- Внешность: Седые волосы, борода, рабочая одежда
- Характер: Дружелюбный, опытный, немного ворчливый

**Эмоции (7 портретов):**
1. **neutral** - нейтральное выражение, спокойное
2. **happy** - улыбка, довольный
3. **thinking** - задумчивый, рука у подбородка
4. **worried** - обеспокоенный, нахмуренный
5. **surprised** - удивленный, широко открытые глаза
6. **proud** - гордый, уверенный
7. **tired** - уставший, вытирает пот

#### NPC 2: Тель (Архивариус)
**Базовая информация:**
- Возраст: ~60 лет
- Внешность: Длинная седая борода, очки, мантия
- Характер: Мудрый, спокойный, загадочный

**Эмоции (7 портретов):**
1. **neutral** - спокойное мудрое выражение
2. **happy** - добрая улыбка
3. **thinking** - глубокая задумчивость
4. **serious** - серьезный, строгий
5. **surprised** - удивленный (редко)
6. **knowing** - знающая улыбка
7. **concerned** - обеспокоенный

#### NPC 3: Иар (Староста)
**Базовая информация:**
- Возраст: ~50 лет
- Внешность: Представительный, борода, официальная одежда
- Характер: Авторитетный, справедливый, строгий но добрый

**Эмоции (7 портретов):**
1. **neutral** - спокойное авторитетное выражение
2. **happy** - довольная улыбка
3. **stern** - строгий, серьезный
4. **proud** - гордый за деревню
5. **worried** - обеспокоенный за жителей
6. **approving** - одобряющий
7. **thoughtful** - задумчивый

### Технические требования портретов
- **Размер**: 200x250 пикселей
- **Формат**: PNG с прозрачностью
- **Стиль**: Пиксель-арт или стилизованный 2D
- **Кадрирование**: Бюст (голова + плечи)
- **Фон**: Прозрачный
- **Цветовая палитра**: Соответствует общему стилю игры

### UI элементы

#### Диалоговое окно
- **spr_dialogue_box** - основное окно диалога (700x150)
- **spr_dialogue_box_corner** - угловые декорации
- **spr_name_box** - окно с именем говорящего (150x30)

#### Индикаторы
- **spr_text_continue_arrow** - стрелка "продолжить" (16x16, анимация)
- **spr_choice_cursor** - курсор выбора (24x24)
- **spr_choice_box** - фон для вариантов выбора

#### Эффекты
- **spr_portrait_frame** - рамка вокруг портрета (опционально)
- **spr_dialogue_fade** - эффект затемнения фона

## Структура файлов

```
pazzle-game-gamemaker/
├── assets/
│   └── sprites/
│       ├── portraits/
│       │   ├── mechanic/
│       │   │   ├── spr_portrait_mechanic_neutral.txt
│       │   │   ├── spr_portrait_mechanic_happy.txt
│       │   │   ├── spr_portrait_mechanic_thinking.txt
│       │   │   ├── spr_portrait_mechanic_worried.txt
│       │   │   ├── spr_portrait_mechanic_surprised.txt
│       │   │   ├── spr_portrait_mechanic_proud.txt
│       │   │   └── spr_portrait_mechanic_tired.txt
│       │   ├── archivist/
│       │   │   ├── spr_portrait_archivist_neutral.txt
│       │   │   ├── spr_portrait_archivist_happy.txt
│       │   │   ├── spr_portrait_archivist_thinking.txt
│       │   │   ├── spr_portrait_archivist_serious.txt
│       │   │   ├── spr_portrait_archivist_surprised.txt
│       │   │   ├── spr_portrait_archivist_knowing.txt
│       │   │   └── spr_portrait_archivist_concerned.txt
│       │   └── elder/
│       │       ├── spr_portrait_elder_neutral.txt
│       │       ├── spr_portrait_elder_happy.txt
│       │       ├── spr_portrait_elder_stern.txt
│       │       ├── spr_portrait_elder_proud.txt
│       │       ├── spr_portrait_elder_worried.txt
│       │       ├── spr_portrait_elder_approving.txt
│       │       └── spr_portrait_elder_thoughtful.txt
│       └── vn_ui/
│           ├── spr_dialogue_box.txt
│           ├── spr_name_box.txt
│           ├── spr_text_continue_arrow.txt
│           ├── spr_choice_cursor.txt
│           └── spr_choice_box.txt
├── scripts/
│   ├── scr_vn_portrait_manager.gml
│   ├── scr_vn_dialogue_system.gml
│   ├── scr_vn_text_engine.gml
│   ├── scr_vn_ui_manager.gml
│   └── scr_vn_choice_handler.gml
└── objects/
    ├── obj_vn_controller.gml
    └── obj_npc.gml (обновленный)
```

## Реализация

### Этап 1: Система портретов

**scr_vn_portrait_manager.gml**
```gml
// Инициализация менеджера портретов
function vn_portrait_init() {
    global.vn_portraits = {
        left: undefined,
        center: undefined,
        right: undefined
    };
}

// Показать портрет
function vn_show_portrait(character_id, emotion, position) {
    var sprite = vn_get_portrait_sprite(character_id, emotion);
    
    global.vn_portraits[$ position] = {
        character: character_id,
        emotion: emotion,
        sprite: sprite,
        alpha: 0,
        target_alpha: 1.0,
        scale: 1.0
    };
}

// Скрыть портрет
function vn_hide_portrait(position) {
    if (global.vn_portraits[$ position] != undefined) {
        global.vn_portraits[$ position].target_alpha = 0;
    }
}

// Изменить эмоцию
function vn_change_emotion(position, new_emotion) {
    var portrait = global.vn_portraits[$ position];
    if (portrait != undefined) {
        portrait.emotion = new_emotion;
        portrait.sprite = vn_get_portrait_sprite(portrait.character, new_emotion);
    }
}

// Получить спрайт портрета
function vn_get_portrait_sprite(character_id, emotion) {
    var sprite_name = "spr_portrait_" + character_id + "_" + emotion;
    return get_sprite_resource(sprite_name);
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
            
            // Удалить если полностью прозрачный
            if (portrait.alpha <= 0 && portrait.target_alpha <= 0) {
                global.vn_portraits[$ pos] = undefined;
            }
        }
    }
}

// Отрисовка портретов
function vn_draw_portraits() {
    // Левый портрет
    if (global.vn_portraits.left != undefined) {
        var p = global.vn_portraits.left;
        draw_sprite_ext(p.sprite, 0, 50, 150, p.scale, p.scale, 0, c_white, p.alpha);
    }
    
    // Центральный портрет
    if (global.vn_portraits.center != undefined) {
        var p = global.vn_portraits.center;
        draw_sprite_ext(p.sprite, 0, 300, 150, p.scale, p.scale, 0, c_white, p.alpha);
    }
    
    // Правый портрет
    if (global.vn_portraits.right != undefined) {
        var p = global.vn_portraits.right;
        draw_sprite_ext(p.sprite, 0, 550, 150, p.scale, p.scale, 0, c_white, p.alpha);
    }
}
```

### Этап 2: Диалоговая система

**scr_vn_dialogue_system.gml**
```gml
// Инициализация диалоговой системы
function vn_dialogue_init() {
    global.vn_dialogue = {
        active: false,
        current_node: undefined,
        dialogue_tree: {},
        history: []
    };
}

// Загрузить дерево диалогов
function vn_load_dialogue_tree(tree_id) {
    // Загрузка из JSON или встроенных данных
    global.vn_dialogue.dialogue_tree = vn_get_dialogue_data(tree_id);
}

// Начать диалог
function vn_start_dialogue(node_id, character_id, position) {
    global.vn_dialogue.active = true;
    global.vn_dialogue.current_node = global.vn_dialogue.dialogue_tree[$ node_id];
    
    // Показать портрет
    var node = global.vn_dialogue.current_node;
    vn_show_portrait(character_id, node.emotion, position);
    
    // Начать печать текста
    vn_text_start(node.text);
    
    // Применить аудио-контекст
    apply_audio_context("dialogue");
}

// Продолжить диалог
function vn_advance_dialogue() {
    var node = global.vn_dialogue.current_node;
    
    if (!vn_text_is_finished()) {
        // Пропустить печать текста
        vn_text_skip();
    } else {
        // Перейти к следующему узлу или показать выборы
        if (array_length(node.choices) > 0) {
            vn_show_choices(node.choices);
        } else if (node.next != undefined) {
            vn_goto_node(node.next);
        } else {
            vn_end_dialogue();
        }
    }
}

// Перейти к узлу
function vn_goto_node(node_id) {
    if (node_id == "end") {
        vn_end_dialogue();
        return;
    }
    
    var node = global.vn_dialogue.dialogue_tree[$ node_id];
    global.vn_dialogue.current_node = node;
    
    // Изменить эмоцию если нужно
    vn_change_emotion("left", node.emotion);
    
    // Начать печать нового текста
    vn_text_start(node.text);
    
    // Добавить в историю
    array_push(global.vn_dialogue.history, node_id);
}

// Завершить диалог
function vn_end_dialogue() {
    global.vn_dialogue.active = false;
    vn_hide_portrait("left");
    vn_hide_portrait("center");
    vn_hide_portrait("right");
    
    // Вернуть нормальный аудио-контекст
    apply_audio_context("town");
}
```

### Этап 3: Текстовый движок

**scr_vn_text_engine.gml**
```gml
// Инициализация текстового движка
function vn_text_init() {
    global.vn_text = {
        current_text: "",
        target_text: "",
        char_index: 0,
        speed: 2,
        finished: false,
        skip_enabled: true
    };
}

// Начать печать текста
function vn_text_start(text) {
    global.vn_text.target_text = text;
    global.vn_text.current_text = "";
    global.vn_text.char_index = 0;
    global.vn_text.finished = false;
}

// Обновление текста
function vn_text_update() {
    if (global.vn_text.finished) return;
    
    var target_len = string_length(global.vn_text.target_text);
    
    if (global.vn_text.char_index < target_len) {
        global.vn_text.char_index += global.vn_text.speed;
        global.vn_text.char_index = min(global.vn_text.char_index, target_len);
        
        global.vn_text.current_text = string_copy(
            global.vn_text.target_text, 
            1, 
            global.vn_text.char_index
        );
        
        // Звук печати (каждые 3 символа)
        if (global.vn_text.char_index % 3 == 0) {
            play_event_sound("ui_move");
        }
    } else {
        global.vn_text.finished = true;
    }
}

// Пропустить печать
function vn_text_skip() {
    if (global.vn_text.skip_enabled) {
        global.vn_text.current_text = global.vn_text.target_text;
        global.vn_text.char_index = string_length(global.vn_text.target_text);
        global.vn_text.finished = true;
    }
}

// Проверка завершения
function vn_text_is_finished() {
    return global.vn_text.finished;
}

// Получить текущий текст
function vn_text_get_current() {
    return global.vn_text.current_text;
}
```

## Примеры диалогов

### Пример 1: Простой линейный диалог
```gml
dialogue_mechanic_greeting = {
    "start": {
        speaker: "mechanic",
        emotion: "neutral",
        text: "Приветствую, путник! Я Роан, местный механик.",
        next: "intro_2"
    },
    "intro_2": {
        speaker: "mechanic",
        emotion: "happy",
        text: "Если тебе нужна помощь с механизмами в пещерах, обращайся!",
        next: "end"
    }
}
```

### Пример 2: Диалог с выбором
```gml
dialogue_archivist_quiz = {
    "start": {
        speaker: "archivist",
        emotion: "neutral",
        text: "Добро пожаловать в архив. Хочешь проверить свои знания?",
        choices: [
            {text: "Да, давай викторину!", next: "quiz_start"},
            {text: "Расскажи об архиве", next: "about_archive"},
            {text: "Может позже", next: "end"}
        ]
    },
    "quiz_start": {
        speaker: "archivist",
        emotion: "happy",
        text: "Отлично! Начнем с простого вопроса...",
        next: "quiz_question_1"
    },
    "about_archive": {
        speaker: "archivist",
        emotion: "thinking",
        text: "Этот архив хранит знания многих поколений...",
        next: "start"
    }
}
```

## Интеграция с существующей системой

### Обновление obj_npc.gml
```gml
// В Create event
vn_character_id = "mechanic"; // или "archivist", "elder"
vn_dialogue_tree_id = "mechanic_main";
vn_portrait_position = "left";

// В Step event при взаимодействии
if (player_interacting && !global.vn_dialogue.active) {
    vn_load_dialogue_tree(vn_dialogue_tree_id);
    vn_start_dialogue("start", vn_character_id, vn_portrait_position);
}

// Обработка ввода во время диалога
if (global.vn_dialogue.active) {
    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) {
        vn_advance_dialogue();
    }
}

// В Draw GUI event
if (global.vn_dialogue.active) {
    vn_draw_portraits();
    vn_draw_dialogue_box();
    vn_draw_text();
    if (vn_text_is_finished()) {
        vn_draw_continue_arrow();
    }
}
```

## Приоритеты реализации

### Высокий приоритет:
1. Создать базовые портреты для 3 NPC (по 3-4 эмоции на старте)
2. Реализовать систему отображения портретов
3. Создать UI диалогового окна
4. Реализовать печатающийся текст

### Средний приоритет:
5. Добавить систему выбора
6. Расширить портреты до полного набора эмоций
7. Добавить анимации появления/исчезновения

### Низкий приоритет:
8. Добавить эффекты (тряска, zoom)
9. Система истории диалогов
10. Сохранение прогресса диалогов

## Следующие шаги

1. Создать конфигурационные файлы портретов для 3 NPC
2. Реализовать scr_vn_portrait_manager.gml
3. Реализовать scr_vn_text_engine.gml
4. Создать UI элементы диалогового окна
5. Интегрировать с obj_npc.gml
6. Протестировать базовый диалог
7. Расширить функционал
