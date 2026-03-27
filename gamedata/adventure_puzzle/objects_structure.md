# Структура объектов GameMaker Studio 2 проекта

## Обзор

Этот документ описывает базовую структуру объектов для GameMaker Studio 2 версии "Adventure Puzzle Game". Объекты организованы в соответствии с архитектурным планом, разработанным ранее.

## Базовые объекты

### `obj_base`
- **Назначение**: Базовый объект для всех игровых объектов
- **Свойства**:
  - `id`: уникальный идентификатор объекта
  - `enabled`: состояние активности объекта
  - `visible`: состояние видимости объекта
- **Методы**:
  - `init()`: инициализация объекта
  - `destroy()`: уничтожение объекта
  - `update()`: обновление логики
  - `draw()`: отрисовка

### `obj_entity_base`
- **Наследует**: `obj_base`
- **Назначение**: Базовый класс для всех сущностей с позицией
- **Свойства**:
  - `x`, `y`: позиция в мире
  - `width`, `height`: размеры объекта
  - `sprite_index`: текущий спрайт
  - `image_xscale`, `image_yscale`: масштаб спрайта
  - `image_angle`: угол поворота спрайта
- **Методы**:
  - `set_position(x, y)`: установка позиции
  - `move_to(x, y)`: перемещение к позиции
  - `collides_with(other_obj)`: проверка коллизии

## Менеджеры

### `obj_game_manager`
- **Наследует**: `obj_base`
- **Назначение**: Главный менеджер игры, отвечает за состояние и управление
- **Свойства**:
  - `game_state`: текущее состояние игры (menu, town, playing, victory)
  - `game_progress`: структура прогресса игры
  - `save_data`: данные сохранения
- **Методы**:
  - `set_state(new_state)`: установить состояние игры
  - `save_game()`: сохранить игру
  - `load_game()`: загрузить игру
  - `reset_game()`: сбросить игру
  - `apply_progress_update(update_type, params)`: применить обновление прогресса

### `obj_scene_manager`
- **Наследует**: `obj_base`
- **Назначение**: Управление сценами и комнатами
- **Свойства**:
  - `current_scene`: текущая сцена
  - `scene_params`: параметры сцены
  - `transition_active`: активность перехода
  - `transition_alpha`: альфа-значение перехода
- **Методы**:
  - `change_scene(scene_name, params)`: сменить сцену
  - `start_transition()`: начать переход
  - `update_transition()`: обновить переход
  - `draw_transition()`: отрисовать переход

### `obj_audio_manager`
- **Наследует**: `obj_base`
- **Назначение**: Управление аудио
- **Свойства**:
  - `master_volume`: общая громкость
  - `music_volume`: громкость музыки
  - `sfx_volume`: громкость звуков
  - `current_music`: текущая проигрываемая музыка
- **Методы**:
  - `play_music(sound_index)`: проиграть музыку
  - `stop_music()`: остановить музыку
  - `play_sound(sound_index)`: проиграть звук
  - `set_volume(volume_type, value)`: установить громкость

### `obj_ui_manager`
- **Наследует**: `obj_base`
- **Назначение**: Управление интерфейсом
- **Свойства**:
  - `ui_elements`: список UI элементов
  - `font_default`: стандартный шрифт
  - `ui_scale`: масштаб интерфейса
- **Методы**:
  - `show_message(text)`: показать сообщение
  - `draw_ui_element(element)`: отрисовать UI элемент
  - `handle_input()`: обработать ввод пользователя

## Игровой мир

### `obj_player`
- **Наследует**: `obj_entity_base`
- **Назначение**: Объект игрока
- **Свойства**:
  - `speed`: скорость движения
  - `facing_direction`: направление взгляда
  - `interaction_distance`: дистанция взаимодействия
- **Методы**:
  - `handle_movement()`: обработка движения
  - `interact()`: взаимодействие с объектами
  - `update_animation()`: обновление анимации

### `obj_npc_base`
- **Наследует**: `obj_entity_base`
- **Назначение**: Базовый класс для NPC
- **Свойства**:
  - `npc_name`: имя NPC
  - `npc_role`: роль NPC
  - `has_quest`: наличие активного задания
  - `quest_completed`: статус выполнения задания
- **Методы**:
  - `start_dialogue()`: начать диалог
  - `update_quest_status()`: обновить статус задания
  - `trigger_activity()`: запустить активность NPC

### `obj_interactable`
- **Наследует**: `obj_entity_base`
- **Назначение**: Базовый класс для интерактивных объектов
- **Свойства**:
  - `interaction_prompt`: приглашение к взаимодействию
  - `can_interact`: возможность взаимодействия
- **Методы**:
  - `on_interact()`: действие при взаимодействии
  - `get_interaction_text()`: получить текст взаимодействия

## Специфичные объекты

### `obj_lever`
- **Наследует**: `obj_interactable`
- **Назначение**: Рычаг для открытия дверей
- **Свойства**:
  - `lever_state`: состояние (вкл/выкл)
  - `target_level`: уровень, к которому относится
  - `associated_door`: связанная дверь
- **Методы**:
  - `pull_lever()`: активировать рычаг
  - `toggle_state()`: переключить состояние

### `obj_altar`
- **Назначение**: Объект для запуска головоломок
- **Наследует**: `obj_interactable`
- **Свойства**:
  - `puzzle_type`: тип головоломки
  - `level_number`: номер уровня
  - `puzzle_completed`: статус завершения головоломки
- **Методы**:
  - `activate_puzzle()`: активировать головоломку
  - `complete_puzzle()`: завершить головоломку

### `obj_exit_door`
- **Назначение**: Выходная дверь
- **Наследует**: `obj_interactable`
- **Свойства**:
  - `door_state`: состояние (открыта/закрыта)
  - `target_room`: комната назначения
  - `require_activation`: требует активации рычага
- **Методы**:
  - `open_door()`: открыть дверь
  - `can_enter()`: можно ли войти

## Головоломки

### `obj_puzzle_controller`
- **Наследует**: `obj_base`
- **Назначение**: Контроллер головоломок
- **Свойства**:
  - `puzzle_type`: тип головоломки
  - `puzzle_state`: состояние головоломки
  - `solution_found`: найдено решение
- **Методы**:
  - `initialize()`: инициализация головоломки
  - `handle_input()`: обработка ввода
  - `check_solution()`: проверка решения
  - `solve_puzzle()`: решение головоломки

### `obj_maze_puzzle`
- **Наследует**: `obj_puzzle_controller`
- **Назначение**: Головоломка лабиринта
- **Свойства**:
  - `maze_width`: ширина лабиринта
  - `maze_height`: высота лабиринта
  - `grid`: сетка лабиринта
  - `start_pos`: стартовая позиция
  - `exit_pos`: позиция выхода
  - `player_pos`: позиция игрока в лабиринте
- **Методы**:
  - `generate_maze()`: генерация лабиринта
  - `slide_player(dx, dy)`: скольжение игрока
  - `check_win_condition()`: проверка условия победы

### `obj_word_search_puzzle`
- **Наследует**: `obj_puzzle_controller`
- **Назначение**: Головоломка поиска слов
- **Свойства**:
  - `grid`: сетка букв
  - `words_to_find`: слова для поиска
  - `found_words`: найденные слова
  - `grid_width`, `grid_height`: размеры сетки
- **Методы**:
  - `generate_grid()`: генерация сетки
  - `find_word(start_x, start_y, end_x, end_y)`: поиск слова
  - `highlight_word(word)`: подсветка слова

### `obj_memory_match_puzzle`
- **Наследует**: `obj_puzzle_controller`
- **Назначение**: Головоломка на память (пары)
- **Свойства**:
  - `cards`: массив карточек
  - `card_count`: количество карточек
  - `cards_matched`: количество найденных пар
  - `flipped_cards`: открытые карточки
- **Методы**:
  - `shuffle_cards()`: перемешать карточки
  - `flip_card(card_index)`: перевернуть карточку
  - `check_pair(card1, card2)`: проверить пару

### `obj_platformer_puzzle`
- **Наследует**: `obj_puzzle_controller`
- **Назначение**: Платформенная головоломка
- **Свойства**:
  - `player_x`, `player_y`: позиция игрока
  - `gravity`: гравитация
  - `ground_level`: уровень земли
  - `collectibles`: собирательские объекты
- **Методы**:
  - `handle_physics()`: обработка физики
  - `jump()`: прыжок
  - `collect_item(item)`: сбор предмета

## Мини-игры NPC

### `obj_npc_mechanic_game`
- **Назначение**: Мини-игра механика (калибровка)
- **Наследует**: `obj_base`
- **Свойства**:
  - `sequence`: последовательность клавиш
  - `current_round`: текущий раунд
  - `player_input`: ввод игрока
  - `game_state`: состояние игры
- **Методы**:
  - `start_game()`: начать игру
  - `show_sequence()`: показать последовательность
  - `process_input(key)`: обработать ввод
  - `check_progress()`: проверить прогресс

### `obj_npc_archivist_quiz`
- **Назначение**: Викторина архивариуса
- **Наследует**: `obj_base`
- **Свойства**:
  - `questions`: список вопросов
  - `current_question`: текущий вопрос
  - `score`: текущий счёт
  - `selected_option`: выбранный вариант
- **Методы**:
  - `get_current_question()`: получить текущий вопрос
  - `submit_answer(option)`: отправить ответ
  - `evaluate_answer()`: оценить ответ

### `obj_npc_elder_trial`
- **Назначение**: Испытание старосты (угадай число)
- **Наследует**: `obj_base`
- **Свойства**:
  - `secret_number`: загаданное число
  - `attempts_left`: оставшиеся попытки
  - `last_guess`: последнее предположение
  - `game_won`: выиграна ли игра
- **Методы**:
  - `start_trial()`: начать испытание
  - `make_guess(number)`: сделать предположение
  - `provide_hint(guess)`: предоставить подсказку

## Системные объекты

### `obj_save_system`
- **Назначение**: Система сохранений
- **Наследует**: `obj_base`
- **Свойства**:
  - `save_slot`: слот сохранения
  - `auto_save`: автосохранение
  - `last_saved`: время последнего сохранения
- **Методы**:
  - `save_to_slot(slot)`: сохранить в слот
  - `load_from_slot(slot)`: загрузить из слота
  - `quick_save()`: быстрое сохранение
  - `convert_rust_save(rust_data)`: конвертация Rust-сохранения

## Структура комнат

### `rm_template_base`
- **Назначение**: Базовый шаблон комнаты
- **Объекты**:
  - `obj_scene_manager` (1 экземпляр)
  - `obj_ui_manager` (1 экземпляр)
  - `obj_audio_manager` (1 экземпляр)

### `rm_menu`
- **Назначение**: Главное меню
- **Объекты**:
  - `rm_template_base`
  - `obj_game_manager`
  - `obj_menu_elements` (UI элементы меню)

### `rm_hub_city`
- **Назначение**: Город-хаб
- **Объекты**:
  - `rm_template_base`
  - `obj_game_manager`
  - `obj_player`
  - `obj_npc_*` (все NPC в городе)
  - `obj_ui_manager`

### `rm_level_*`
- **Назначение**: Уровни игры (1-6)
- **Объекты**:
  - `rm_template_base`
  - `obj_game_manager`
  - `obj_player`
  - `obj_altar`
  - `obj_lever`
  - `obj_exit_door`
  - `obj_puzzle_controller` (зависимо от типа уровня)
  - `obj_ui_manager`

### `rm_victory`
- **Назначение**: Финальная сцена
- **Объекты**:
  - `rm_template_base`
  - `obj_game_manager`
  - `obj_ui_manager`