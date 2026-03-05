import pygame
import random
import math
from entities import Player, Item

# Типы головоломок
PUZZLE_TYPE_COLLECT = "collect"  # Сбор предметов
PUZZLE_TYPE_SWITCHES = "switches"  # Переключатели в последовательности
PUZZLE_TYPE_MOVING_OBSTACLES = "moving_obstacles"  # Движущиеся препятствия
PUZZLE_TYPE_TIMED = "timed"  # Головоломка на время
PUZZLE_TYPE_MEMORY = "memory"  # Головоломка на память
PUZZLE_TYPE_PLATFORM = "platform"  # Платформер с прыжками


class Switch:
    """Класс переключателя для головоломки"""
    def __init__(self, x, y, switch_id, correct_order):
        self.x = x
        self.y = y
        self.width = 40
        self.height = 40
        self.rect = pygame.Rect(x, y, self.width, self.height)
        self.switch_id = switch_id
        self.correct_order = correct_order
        self.activated = False
        self.hovered = False
        
        # Анимация
        self.pulse_phase = random.uniform(0, math.pi * 2)
        
    def draw(self, screen, is_active_sequence):
        """Отрисовка переключателя"""
        # Цвет зависит от состояния
        if self.activated:
            base_color = (100, 255, 100)  # Зеленый - активирован
            glow_color = (150, 255, 150)
        elif is_active_sequence:
            base_color = (255, 200, 50)  # Желтый - следующий в очереди
            glow_color = (255, 255, 100)
        else:
            base_color = (150, 150, 150)  # Серый - неактивный
            glow_color = (200, 200, 200)
        
        # Пульсация
        pulse = math.sin(self.pulse_phase) * 0.2 + 0.8
        self.pulse_phase += 0.1
        
        # Свечение
        glow_size = int(25 * pulse)
        center_x = self.x + self.width // 2
        center_y = self.y + self.height // 2
        
        glow_surf = pygame.Surface((self.width + glow_size * 2, self.height + glow_size * 2), pygame.SRCALPHA)
        pygame.draw.circle(glow_surf, (*glow_color, 50), 
                         (self.width // 2 + glow_size, self.height // 2 + glow_size), 
                         self.width // 2 + glow_size // 2)
        screen.blit(glow_surf, (self.x - glow_size, self.y - glow_size), special_flags=pygame.BLEND_ADD)
        
        # Основной прямоугольник
        pygame.draw.rect(screen, base_color, (self.x, self.y, self.width, self.height), border_radius=5)
        
        # Обводка
        border_color = (255, 255, 255) if self.activated else (100, 100, 100)
        pygame.draw.rect(screen, border_color, (self.x, self.y, self.width, self.height), 2, border_radius=5)
        
        # Номер переключателя
        font = pygame.font.SysFont('arial', 18, bold=True)
        text = font.render(str(self.switch_id), True, (0, 0, 0) if self.activated else (255, 255, 255))
        text_rect = text.get_rect(center=(self.x + self.width // 2, self.y + self.height // 2))
        screen.blit(text, text_rect)
        
    def contains_point(self, px, py):
        """Проверка, находится ли точка над переключателем"""
        return self.rect.collidepoint(px, py)


class MovingObstacle:
    """Класс движущегося препятствия"""
    def __init__(self, x, y, width, height, move_range, axis='x', speed=2):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.rect = pygame.Rect(x, y, width, height)
        
        # Движение
        self.start_x = x
        self.start_y = y
        self.move_range = move_range
        self.axis = axis  # 'x' или 'y'
        self.speed = speed
        self.direction = 1
        self.phase = random.uniform(0, math.pi * 2)
        
    def update(self):
        """Обновление позиции препятствия"""
        self.phase += self.speed * 0.05
        
        if self.axis == 'x':
            self.x = self.start_x + math.sin(self.phase) * self.move_range
        else:
            self.y = self.start_y + math.sin(self.phase) * self.move_range
            
        self.rect.x = int(self.x)
        self.rect.y = int(self.y)
        
    def draw(self, screen):
        """Отрисовка препятствия"""
        # Красный цвет с пульсацией
        pulse = math.sin(self.phase) * 0.3 + 0.7
        color = (int(200 * pulse), 50, 50)
        
        # Свечение
        glow_surf = pygame.Surface((self.width + 20, self.height + 20), pygame.SRCALPHA)
        pygame.draw.rect(glow_surf, (255, 50, 50, 80), 
                       (10, 10, self.width, self.height), border_radius=5)
        screen.blit(glow_surf, (self.x - 10, self.y - 10), special_flags=pygame.BLEND_ADD)
        
        # Основное тело
        pygame.draw.rect(screen, color, (self.x, self.y, self.width, self.height), border_radius=5)
        
        # Предупреждающие полосы
        stripe_color = (255, 100, 100)
        for i in range(0, self.width, 15):
            pygame.draw.line(screen, stripe_color, 
                           (self.x + i, self.y), 
                           (self.x + i, self.y + self.height), 3)
        
        # Обводка
        pygame.draw.rect(screen, (255, 50, 50), (self.x, self.y, self.width, self.height), 2, border_radius=5)


class GameplayScene:
    def __init__(self, screen_width, screen_height, level=1):
        self.screen_width = screen_width
        self.screen_height = screen_height
        self.level = level
        
        # Текущий уровень (1-3)
        self.current_level = level
        
        # Прогресс игры (инициализируем пустым, будет установлен из main.py)
        self.progress = {}
        
        # Создаем градиентный фон
        self.background = self.create_gradient_background()
        
        # Система частиц для эффектов сбора
        self.particle_system = ParticleSystem()
        
        # Эффект перехода
        self.transition = TransitionEffect(screen_width, screen_height)
        
        # Игрок
        self.player = Player(50, 300, 30, 30)
        
        # Система здоровья
        self.max_health = 100
        self.current_health = 100
        self.invulnerable = False
        self.invulnerable_timer = 0
        self.damage_flash = 0
        
        # Предметы для сбора
        self.items = []
        
        # Переключатели для головоломки с последовательностью
        self.switches = []
        
        # Движущиеся препятствия
        self.moving_obstacles = []
        
        # Настройка уровня
        self.setup_level(level)
        
        # Состояние головоломки
        self.collected_items = []
        self.activated_switches = []  # Список активированных переключателей в порядке
        self.puzzle_solved = False
        self.puzzle_type = PUZZLE_TYPE_COLLECT
        
        # Таймер для уровня 3
        self.time_limit = 0
        self.time_remaining = 0
        self.timer_active = False
        self.timer_flash = False
        
        # Система подсказок
        self.show_hint = False
        self.hint_text = ""
        self.hint_timer = 0
        
        # Визуальные подсказки
        self.hints = []  # Подсказки, отображаемые около объектов
        
        # Прогресс уровня (передаётся из main)
        self.progress = {1: {'completed': False, 'lever_pulled': False},
                         2: {'completed': False, 'lever_pulled': False},
                         3: {'completed': False, 'lever_pulled': False}}
        
        # Рычаг для отключения головоломки
        self.lever_pulled = False
        self.lever_rect = None
        self.lever_activated = False  # Рычаг активирован (головоломка отключена)
        
        # Облака для фона
        self.clouds = []
        for _ in range(5):
            self.clouds.append({
                'x': random.randint(0, screen_width),
                'y': random.randint(50, 200),
                'speed': random.uniform(0.2, 0.5),
                'size': random.randint(30, 60)
            })
        
        # Анимация при победе
        self.win_animation = False
        self.win_particles = []
        
        # Анимация проигрыша (время вышло)
        self.lose_animation = False
        
        # Визуальный стиль
        self.ui_colors = {
            'text': (255, 255, 255),
            'shadow': (0, 0, 0),
            'success': (100, 255, 100),
            'gold': (255, 215, 0),
            'warning': (255, 100, 100),
            'hint': (100, 200, 255)
        }

    def setup_level(self, level):
        """Настройка уровня в зависимости от сложности"""
        self.current_level = level
        self.items = []
        self.switches = []
        self.moving_obstacles = []
        self.collected_items = []
        self.activated_switches = []
        self.puzzle_solved = False
        self.timer_active = False
        self.time_remaining = 0
        
        # Рычаг (появляется после решения головоломки)
        self.lever_rect = pygame.Rect(self.screen_width - 80, self.screen_height - 150, 40, 60)
        self.lever_pulled = False
        self.lever_activated = self.progress.get(level, {}).get('lever_pulled', False)
        
        # Если рычаг уже активирован - головоломка отключена
        if self.lever_activated:
            self.puzzle_solved = True
        
        # Дополнительные параметры для уровней памяти
        self.memory_buttons = []
        self.memory_sequence = []
        self.memory_input = []
        self.memory_round = 1
        self.memory_showing_sequence = False
        self.memory_display_timer = 0
        
        # Дополнительные параметры для платформера
        self.platforms = []
        self.player_on_ground = False
        
        # Атрибуты для новых головоломок
        self.maze_puzzle = None
        self.wordsearch_puzzle = None
        self.pattern_puzzle = None
        
        if level == 1:
            # Уровень 1: Лабиринт
            from scenes.puzzle_types import MazePuzzle
            self.puzzle_type = "maze"
            self.maze_puzzle = MazePuzzle(self.screen_width, self.screen_height)
            self.items = []
            self.hint_text = "Пройдите лабиринт от старта до финиша (WASD)"
            
        elif level == 2:
            # Уровень 2: Поиск слов
            from scenes.puzzle_types import WordSearchPuzzle
            self.puzzle_type = "wordsearch"
            self.wordsearch_puzzle = WordSearchPuzzle(self.screen_width, self.screen_height)
            self.items = []
            self.hint_text = "Найдите все слова в сетке (кликайте на буквы)"
            
        elif level == 3:
            # Уровень 3: Головоломка с паттернами (память)
            from scenes.puzzle_types import PatternPuzzle
            self.puzzle_type = "pattern"
            self.pattern_puzzle = PatternPuzzle(self.screen_width, self.screen_height)
            self.items = []
            self.hint_text = "Запомните и повторите последовательность (кликайте на кнопки)"
            
        elif level == 4:
            # Уровень 4: Головоломка на память
            self.puzzle_type = PUZZLE_TYPE_MEMORY
            self.memory_sequence = []
            self.memory_input = []
            self.memory_round = 1
            self.memory_max_rounds = 3
            self.memory_display_timer = 0
            self.memory_showing_sequence = False
            self.memory_items = []
            
            # Создаём 4 кнопки для памяти
            self.memory_buttons = [
                {'x': 200, 'y': 200, 'color': (255, 100, 100), 'id': 1},
                {'x': 400, 'y': 200, 'color': (100, 255, 100), 'id': 2},
                {'x': 200, 'y': 350, 'color': (100, 100, 255), 'id': 3},
                {'x': 400, 'y': 350, 'color': (255, 255, 100), 'id': 4}
            ]
            self.generate_memory_sequence()
            
            # Предметы появятся после прохождения
            self.items = [
                Item(350, 450, 25, 25, "Свиток", "Древний свиток мудрости")
            ]
            self.hint_text = f"Запомните последовательность цветов (раунд {self.memory_round}/{self.memory_max_rounds})"
            
        elif level == 5:
            # Уровень 5: Платформер - собери кристаллы на платформах
            self.puzzle_type = PUZZLE_TYPE_PLATFORM
            self.platforms = [
                {'x': 50, 'y': 450, 'w': 150, 'h': 20},
                {'x': 250, 'y': 380, 'w': 120, 'h': 20},
                {'x': 420, 'y': 320, 'w': 120, 'h': 20},
                {'x': 580, 'y': 250, 'w': 100, 'h': 20},
                {'x': 300, 'y': 200, 'w': 150, 'h': 20},
                {'x': 100, 'y': 150, 'w': 100, 'h': 20}
            ]
            
            # Предметы на разных высотах
            self.items = [
                Item(300, 420, 25, 25, "Рубин", "Огненный рубин"),
                Item(500, 280, 25, 25, "Изумруд", "Изумруд удачи"),
                Item(180, 120, 25, 25, "Сапфир", "Сапфир мудрости"),
                Item(400, 170, 25, 25, "Алмаз", "Бриллиант силы")
            ]
            self.hint_text = "Прыгайте по платформам и соберите все кристаллы!"
            
        elif level >= 6:
            # Уровень 6: Финальный - комбинированная головоломка
            self.puzzle_type = PUZZLE_TYPE_TIMED
            self.time_limit = 60  # 60 секунд
            self.time_remaining = self.time_limit
            self.timer_active = True
            
            # Множество движущихся препятствий - АДСКАЯ СЛОЖНОСТЬ!
            self.moving_obstacles = [
                # Первый слой - горизонтальные
                MovingObstacle(50, 80, 70, 70, 180, 'x', 7),
                MovingObstacle(150, 150, 70, 70, 200, 'x', 6.5),
                MovingObstacle(100, 220, 70, 70, 220, 'x', 7.2),
                MovingObstacle(200, 290, 70, 70, 190, 'x', 6.8),
                MovingObstacle(50, 360, 70, 70, 210, 'x', 7.5),
                MovingObstacle(150, 430, 70, 70, 180, 'x', 6.3),
                MovingObstacle(100, 500, 70, 70, 200, 'x', 7),
                # Второй слой - вертикальные
                MovingObstacle(250, 50, 70, 70, 200, 'y', 6.5),
                MovingObstacle(350, 100, 70, 70, 180, 'y', 7),
                MovingObstacle(450, 80, 70, 70, 220, 'y', 6.8),
                MovingObstacle(550, 120, 70, 70, 190, 'y', 7.2),
                MovingObstacle(650, 90, 70, 70, 210, 'y', 6.6),
                # Третий слой - диагональные (чередование)
                MovingObstacle(300, 250, 70, 70, 160, 'x', 8),
                MovingObstacle(400, 300, 70, 70, 140, 'y', 7.8),
                MovingObstacle(500, 350, 70, 70, 150, 'x', 8.2)
            ]
            
            # Множество предметов
            self.items = [
                Item(100, 500, 25, 25, "Часть Артефакта I", "Первая часть Артефакта Вечности"),
                Item(700, 100, 25, 25, "Часть Артефакта II", "Вторая часть Артефакта Вечности"),
                Item(400, 550, 25, 25, "Часть Артефакта III", "Третья часть Артефакта Вечности"),
                Item(400, 50, 25, 25, "Финальный Ключ", "Ключ к силе артефактов")
            ]
            self.hint_text = "ФИНАЛ! Соберите все 4 части Артефакта Вечности за 60 секунд!"

    def create_gradient_background(self):
        """Создание красивого градиентного фона"""
        # Цвета зависят от уровня
        if self.current_level == 1:
            colors = [
                (45, 85, 145),    # Темно-синий верх
                (70, 130, 180),   # Стальной синий
                (135, 206, 235),  # Небесно-голубой
                (175, 238, 238),  # Светло-бирюзовый
                (144, 238, 144)   # Светло-зеленый (земля)
            ]
        elif self.current_level == 2:
            colors = [
                (80, 40, 100),    # Темно-фиолетовый
                (120, 60, 150),   # Фиолетовый
                (160, 100, 180),  # Сиреневый
                (200, 150, 200),  # Светло-сиреневый
                (100, 80, 120)    # Темная земля
            ]
        else:  # level 3
            colors = [
                (60, 30, 30),     # Темно-красный
                (120, 50, 50),    # Красный
                (180, 80, 60),    # Оранжево-красный
                (220, 120, 80),   # Оранжевый
                (80, 40, 40)      # Темная земля
            ]
        
        if self.level >= 4 and self.level < 6:
            # Уровни 4-5: Мистический лес
            colors = [
                (20, 50, 40),     # Темно-зеленый
                (40, 80, 60),     # Лесной зеленый
                (60, 120, 80),    # Светло-зеленый
                (100, 160, 120),  # Салатовый
                (40, 60, 50)      # Темная земля
            ]
        elif self.level >= 6:
            # Уровень 6: Финальный - золото и тьма
            colors = [
                (40, 20, 60),     # Темно-фиолетовый
                (80, 40, 100),    # Фиолетовый
                (150, 80, 120),   # Розовый
                (220, 150, 100),  # Золотой
                (60, 40, 50)      # Темная земля
            ]
        
        surface = pygame.Surface((self.screen_width, self.screen_height))
        
        num_strips = len(colors)
        strip_height = self.screen_height // (num_strips - 1)
        
        for i in range(num_strips - 1):
            top_color = colors[i]
            bottom_color = colors[i + 1]
            
            for y in range(i * strip_height, (i + 1) * strip_height):
                if y >= self.screen_height:
                    break
                t = y / self.screen_height
                r = int(top_color[0] + (bottom_color[0] - top_color[0]) * (y % strip_height) / strip_height)
                g = int(top_color[1] + (bottom_color[1] - top_color[1]) * (y % strip_height) / strip_height)
                b = int(top_color[2] + (bottom_color[2] - top_color[2]) * (y % strip_height) / strip_height)
                pygame.draw.line(surface, (r, g, b), (0, y), (self.screen_width, y))
        
        # Добавляем "землю" внизу
        ground_color = (34, 139, 34) if self.current_level == 1 else (60, 40, 80) if self.current_level == 2 else (50, 25, 25)
        ground_rect = pygame.Rect(0, self.screen_height - 80, self.screen_width, 80)
        pygame.draw.rect(surface, ground_color, ground_rect)
        
        # Добавляем траву или узоры
        for x in range(0, self.screen_width, 8):
            grass_height = random.randint(5, 15)
            grass_y = self.screen_height - 80 - grass_height
            grass_color = (50, 205, 50) if self.current_level == 1 else (80, 60, 100)
            pygame.draw.line(surface, grass_color, (x, grass_y + grass_height), (x + 2, grass_y), 2)
            
        return surface

    def handle_events(self, events):
        """Обработка событий для сцены"""
        for event in events:
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    self.interact_with_nearby_items()
                elif event.key == pygame.K_h:
                    # Показать подсказку
                    self.show_hint = True
                    self.hint_timer = 180  # 3 секунды при 60 FPS
                elif event.key == pygame.K_e:
                    # Взаимодействие с рычагом
                    self.interact_with_lever()
                    
            # Обработка кликов мыши
            if event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1:  # Левая кнопка
                    mx, my = pygame.mouse.get_pos()
                    
                    # Обработка кликов для новых головоломок
                    if self.puzzle_type == "wordsearch":
                        self.wordsearch_puzzle.handle_click((mx, my))
                    elif self.puzzle_type == "pattern":
                        self.pattern_puzzle.handle_click((mx, my))
                    else:
                        # Старая логика для переключателей
                        self.handle_switch_click(mx, my)
                        # Проверка клика на рычаг
                        if self.lever_rect and self.lever_rect.collidepoint(mx, my):
                            self.interact_with_lever()
                        # Проверка клика на кнопки памяти
                        if self.puzzle_type == PUZZLE_TYPE_MEMORY and not self.memory_showing_sequence:
                            for btn in self.memory_buttons:
                                btn_rect = pygame.Rect(btn['x'], btn['y'], 80, 60)
                                if btn_rect.collidepoint(mx, my):
                                    self.handle_memory_click(btn['id'])
                        
    def interact_with_lever(self):
        """Взаимодействие с рычагом"""
        # Рычаг можно активировать только после решения головоломки
        if self.puzzle_solved and not self.lever_activated and self.lever_rect:
            self.lever_activated = True
            self.lever_pulled = True
            
            # Эффект
            self.particle_system.emit(
                self.lever_rect.centerx,
                self.lever_rect.centery,
                (255, 215, 0), 30, 5, 50
            )

    def handle_switch_click(self, mx, my):
        """Обработка клика по переключателю"""
        if self.puzzle_type != PUZZLE_TYPE_SWITCHES:
            return
            
        for switch in self.switches:
            if switch.contains_point(mx, my) and not switch.activated:
                # Проверяем правильность последовательности
                expected = len(self.activated_switches) + 1
                if switch.switch_id == expected:
                    switch.activated = True
                    self.activated_switches.append(switch.switch_id)
                    
                    # Эффект активации
                    self.particle_system.emit(
                        switch.x + switch.width // 2,
                        switch.y + switch.height // 2,
                        (100, 255, 100), 20, 5, 40
                    )
                    
                    # Если все переключатели активированы
                    if len(self.activated_switches) == len(self.switches):
                        self.puzzle_solved = True
                        # Показываем предметы
                        for item in self.items:
                            item.show()
                else:
                    # Неправильная последовательность - сброс
                    self.reset_switches()
                    
    def reset_switches(self):
        """Сброс всех переключателей"""
        for switch in self.switches:
            switch.activated = False
        self.activated_switches = []
        
        # Эффект ошибки
        self.particle_system.emit(
            self.screen_width // 2,
            self.screen_height // 2,
            (255, 50, 50), 30, 8, 50
        )

    def update(self, keys_pressed):
        """Обновление состояния сцены"""
        # Обновление неуязвимости
        if self.invulnerable:
            self.invulnerable_timer -= 1
            if self.invulnerable_timer <= 0:
                self.invulnerable = False
                
        # Обновление вспышки урона
        if self.damage_flash > 0:
            self.damage_flash -= 1
        
        # Обновление новых головоломок
        if self.puzzle_type == "maze":
            self.maze_puzzle.handle_input(keys_pressed)
            if self.maze_puzzle.solved:
                self.puzzle_solved = True
        elif self.puzzle_type == "wordsearch":
            if self.wordsearch_puzzle.solved:
                self.puzzle_solved = True
        elif self.puzzle_type == "pattern":
            self.pattern_puzzle.update()
            if self.pattern_puzzle.solved:
                self.puzzle_solved = True
        else:
            # Старая логика для остальных уровней
            # Обновление игрока
            self.player.update(keys_pressed)
            
            # Проверка столкновений с движущимися препятствиями
            for obstacle in self.moving_obstacles:
                obstacle.update()
                if self.player.rect.colliderect(obstacle.rect) and not self.invulnerable:
                    # Столкновение - ОГРОМНЫЙ УРОН!
                    self.take_damage(40)  # Увеличен урон до 40 (2.5 удара до смерти!)
                    # Отбрасывание игрока
                    if obstacle.axis == 'x':
                        self.player.x = self.player.x - 50 if obstacle.direction > 0 else self.player.x + 50
                    else:
                        self.player.y = self.player.y - 50 if obstacle.direction > 0 else self.player.y + 50
                    self.player.x = max(0, min(self.player.x, self.screen_width - self.player.width))
                    self.player.y = max(0, min(self.player.y, self.screen_height - self.player.height))
                    self.player.rect.x = int(self.player.x)
                    self.player.rect.y = int(self.player.y)
            
            # Проверка смерти
            if self.current_health <= 0:
                # Перезапуск уровня
                self.current_health = self.max_health
                self.player.set_position(50, 300)
                self.collected_items = []
                self.activated_switches = []
                if self.timer_active:
                    self.time_remaining = self.time_limit
            
            # Обновление предметов
            for item in self.items:
                item.update()
                
            # Проверка столкновений с предметами
            self.check_item_collisions()
        
        # Обновление системы частиц
        self.particle_system.update()
        
        # Обновление облаков
        for cloud in self.clouds:
            cloud['x'] += cloud['speed']
            if cloud['x'] > self.screen_width + cloud['size']:
                cloud['x'] = -cloud['size']
                cloud['y'] = random.randint(50, 200)
        
        # Обновление таймера
        if self.timer_active and not self.puzzle_solved:
            self.time_remaining -= 1 / 60  # Приблизительно 1/60 секунды за кадр
            if self.time_remaining <= 0:
                self.time_remaining = 0
                self.lose_animation = True
                self.timer_active = False
        
        # Обновление логики памяти (уровень 4)
        if self.puzzle_type == PUZZLE_TYPE_MEMORY:
            self.update_memory_puzzle()
        
        # Обновление физики платформера (уровень 5)
        if self.puzzle_type == PUZZLE_TYPE_PLATFORM:
            self.update_platformer()
        
        # Мигание таймера при низком времени
        if self.time_remaining < 10:
            self.timer_flash = (pygame.time.get_ticks() // 500) % 2 == 0
        else:
            self.timer_flash = False
            
        # Обновление подсказки
        if self.show_hint:
            self.hint_timer -= 1
            if self.hint_timer <= 0:
                self.show_hint = False
        
        # Обновление визуальных подсказок для объектов
        self.update_visual_hints()
        
        # Анимация победы
        if self.win_animation:
            self.update_win_animation()
    
    def take_damage(self, amount):
        """Получить урон"""
        if not self.invulnerable:
            self.current_health -= amount
            self.current_health = max(0, self.current_health)
            self.invulnerable = True
            self.invulnerable_timer = 20  # 0.33 секунды неуязвимости (было 30)
            self.damage_flash = 20
            
            # Эффект урона
            self.particle_system.emit(
                self.player.rect.centerx,
                self.player.rect.centery,
                (255, 0, 0), 40, 7, 50
            )

    def update_visual_hints(self):
        """Обновление визуальных подсказок для объектов"""
        self.hints = []
        
        # Подсказки для переключателей (уровень 2)
        if self.puzzle_type == PUZZLE_TYPE_SWITCHES:
            next_switch = len(self.activated_switches) + 1
            for switch in self.switches:
                if not switch.activated:
                    if switch.switch_id == next_switch:
                        self.hints.append({
                            'x': switch.x + switch.width // 2,
                            'y': switch.y - 30,
                            'text': 'Следующий!',
                            'color': (255, 255, 100)
                        })
                    elif switch.switch_id < next_switch:
                        self.hints.append({
                            'x': switch.x + switch.width // 2,
                            'y': switch.y - 30,
                            'text': 'Пропущен!',
                            'color': (255, 100, 100)
                        })
        
        # Подсказки для предметов (когда игрок близко)
        for item in self.items:
            if item.visible:
                dist = math.sqrt((item.x - self.player.x)**2 + (item.y - self.player.y)**2)
                if dist < 100:
                    self.hints.append({
                        'x': item.x + item.width // 2,
                        'y': item.y - 30,
                        'text': f'Нажмите SPACE',
                        'color': (100, 200, 255)
                    })

    def check_item_collisions(self):
        """Проверка столкновений игрока с предметами"""
        player_rect = self.player.rect
        
        for item in self.items:
            # Для уровня 2 - предметы скрыты до решения головоломки
            if not item.visible:
                continue
                
            if item.is_colliding_with(player_rect):
                self.collect_item(item)
                
        # Проверка решения головоломки
        if self.puzzle_type == PUZZLE_TYPE_COLLECT:
            if len(self.collected_items) == len(self.items):
                self.puzzle_solved = True

    def collect_item(self, item):
        """Сбор предмета игроком с эффектами"""
        if item not in self.collected_items:
            self.collected_items.append(item)
            
            # Эффекты частиц
            center_x = item.x + item.width // 2
            center_y = item.y + item.height // 2
            
            self.particle_system.emit(center_x, center_y, (255, 215, 0), 30, 4, 50)
            self.particle_system.emit(center_x, center_y, (180, 100, 255), 20, 3, 40)
            self.particle_system.emit(center_x, center_y, (255, 255, 200), 15, 5, 30)
            
            item.hide()
            
            # Проверить решение
            if len(self.collected_items) == len(self.items):
                self.puzzle_solved = True

    def interact_with_nearby_items(self):
        """Взаимодействие с предметами поблизости"""
        player_rect = self.player.rect
        interaction_radius = 50
        interaction_rect = pygame.Rect(
            player_rect.centerx - interaction_radius,
            player_rect.centery - interaction_radius,
            interaction_radius * 2,
            interaction_radius * 2
        )
        
        for item in self.items:
            if item.visible and item.rect.colliderect(interaction_rect):
                item.interact(self.player)

    def draw(self, screen):
        """Отрисовка сцены"""
        # Вспышка урона
        if self.damage_flash > 0:
            flash_surf = pygame.Surface((self.screen_width, self.screen_height), pygame.SRCALPHA)
            flash_surf.fill((255, 0, 0, 50))
            screen.blit(flash_surf, (0, 0))
        
        # 1. Рисуем фон
        screen.blit(self.background, (0, 0))
        
        # 2. Рисуем облака
        self.draw_clouds(screen)
        
        # 3. Рисуем частицы (задний план)
        self.particle_system.draw(screen)
        
        # 4. Отрисовка новых головоломок
        if self.puzzle_type == "maze":
            self.maze_puzzle.draw(screen)
        elif self.puzzle_type == "wordsearch":
            self.wordsearch_puzzle.draw(screen)
        elif self.puzzle_type == "pattern":
            self.pattern_puzzle.draw(screen)
        else:
            # Старая логика для остальных уровней
            # 4. Отрисовка движущихся препятствий (уровень 3)
            for obstacle in self.moving_obstacles:
                obstacle.draw(screen)
            
            # 5. Отрисовка переключателей (уровень 2)
            if self.puzzle_type == PUZZLE_TYPE_SWITCHES:
                next_switch = len(self.activated_switches) + 1
                for switch in self.switches:
                    is_active = switch.switch_id == next_switch
                    switch.draw(screen, is_active)
            
            # 6. Отрисовка предметов
            for item in self.items:
                item.draw(screen)
                
            # 7. Отрисовка игрока (с мерцанием при неуязвимости)
            if not self.invulnerable or (self.invulnerable_timer // 5) % 2 == 0:
                self.player.draw(screen)
            
            # 8. Отрисовка рычага (после решения головоломки)
            if self.puzzle_solved and self.lever_rect:
                self.draw_lever(screen)
            
            # 9. Отрисовка платформ (уровень 5)
            if self.puzzle_type == PUZZLE_TYPE_PLATFORM:
                self.draw_platforms(screen)
            
            # 10. Отрисовка кнопок памяти (уровень 4)
            if self.puzzle_type == PUZZLE_TYPE_MEMORY:
                self.draw_memory_buttons(screen)
            
            # 11. Отрисовка визуальных подсказок
            self.draw_visual_hints(screen)
        
        # 12. Отрисовка полоски здоровья
        self.draw_health_bar(screen)
        
        # 13. Отрисовка анимации победы/поражения
        if self.win_animation:
            self.draw_win_animation(screen)
        elif self.lose_animation:
            self.draw_lose_screen(screen)
    
    def draw_health_bar(self, screen):
        """Отрисовка полоски здоровья"""
        bar_width = 200
        bar_height = 20
        bar_x = 10
        bar_y = 10
        
        # Фон
        pygame.draw.rect(screen, (50, 50, 50), (bar_x, bar_y, bar_width, bar_height), border_radius=5)
        
        # Здоровье
        health_width = int((self.current_health / self.max_health) * bar_width)
        if health_width > 0:
            # Цвет от зелёного к красному
            t = self.current_health / self.max_health
            r = int(255 * (1 - t))
            g = int(255 * t)
            pygame.draw.rect(screen, (r, g, 50), (bar_x, bar_y, health_width, bar_height), border_radius=5)
        
        # Рамка
        pygame.draw.rect(screen, (200, 200, 200), (bar_x, bar_y, bar_width, bar_height), 2, border_radius=5)
        
        # Текст
        font = pygame.font.SysFont('arial', 14, bold=True)
        text = f"HP: {int(self.current_health)}/{self.max_health}"
        text_surf = font.render(text, True, (255, 255, 255))
        text_rect = text_surf.get_rect(center=(bar_x + bar_width // 2, bar_y + bar_height // 2))
        screen.blit(text_surf, text_rect)
            
        # 10. Отображение UI
        self.draw_ui(screen)

    def draw_clouds(self, screen):
        """Отрисовка облаков"""
        for cloud in self.clouds:
            cloud_color = (255, 255, 255, 180)
            cloud_surf = pygame.Surface((cloud['size'] * 2, cloud['size']), pygame.SRCALPHA)
            
            pygame.draw.circle(cloud_surf, (255, 255, 255), 
                            (cloud['size'] // 2, cloud['size'] // 2), cloud['size'] // 2)
            pygame.draw.circle(cloud_surf, (255, 255, 255), 
                            (cloud['size'] // 2 - cloud['size'] // 3, cloud['size'] // 2 + 5), 
                            cloud['size'] // 3)
            pygame.draw.circle(cloud_surf, (255, 255, 255), 
                            (cloud['size'] // 2 + cloud['size'] // 3, cloud['size'] // 2 + 5), 
                            cloud['size'] // 3)
                            
            screen.blit(cloud_surf, (cloud['x'], cloud['y']), special_flags=pygame.BLEND_ADD)

    def draw_visual_hints(self, screen):
        """Отрисовка визуальных подсказок"""
        font = pygame.font.SysFont('arial', 14, bold=True)
        
        for hint in self.hints:
            # Фон подсказки
            text = font.render(hint['text'], True, hint['color'])
            text_rect = text.get_rect(center=(hint['x'], hint['y']))
            
            # Полупрозрачный фон
            bg_rect = text_rect.inflate(10, 6)
            bg_surf = pygame.Surface((bg_rect.width, bg_rect.height), pygame.SRCALPHA)
            bg_surf.fill((0, 0, 0, 150))
            screen.blit(bg_surf, bg_rect)
            
            screen.blit(text, text_rect)

    def draw_win_animation(self, screen):
        """Отрисовка анимации победы"""
        for p in self.win_particles:
            alpha = int(255 * (p['life'] / 60))
            radius = int(5 * (p['life'] / 60))
            pygame.draw.circle(screen, p['color'], (int(p['x']), int(p['y'])), radius)

    def draw_lose_screen(self, screen):
        """Отрисовка экрана проигрыша"""
        overlay = pygame.Surface((self.screen_width, self.screen_height), pygame.SRCALPHA)
        overlay.fill((0, 0, 0, 150))
        screen.blit(overlay, (0, 0))
        
        font_large = pygame.font.SysFont('arial', 48, bold=True)
        font = pygame.font.SysFont('arial', 24)
        
        text = font_large.render("ВРЕМЯ ВЫШЛО!", True, (255, 50, 50))
        text_rect = text.get_rect(center=(self.screen_width // 2, self.screen_height // 2 - 20))
        screen.blit(text, text_rect)
        
        text = font.render("Нажмите R для рестарта", True, (255, 255, 255))
        text_rect = text.get_rect(center=(self.screen_width // 2, self.screen_height // 2 + 30))
        screen.blit(text, text_rect)

    def draw_ui(self, screen):
        """Отрисовка пользовательского интерфейса"""
        font = pygame.font.SysFont('arial', 20, bold=True)
        font_large = pygame.font.SysFont('arial', 28, bold=True)
        
        # Отображение уровня
        level_text = font.render(f"Уровень {self.current_level}", True, self.ui_colors['gold'])
        screen.blit(level_text, (12, 12))
        
        # Отображение типа головоломки
        puzzle_name = ""
        if self.puzzle_type == "maze":
            puzzle_name = "Лабиринт"
        elif self.puzzle_type == "wordsearch":
            puzzle_name = "Поиск слов"
        elif self.puzzle_type == "pattern":
            puzzle_name = "Память"
        elif self.puzzle_type == PUZZLE_TYPE_COLLECT:
            puzzle_name = "Сбор предметов"
        elif self.puzzle_type == PUZZLE_TYPE_SWITCHES:
            puzzle_name = "Переключатели"
        elif self.puzzle_type == PUZZLE_TYPE_TIMED:
            puzzle_name = "На время"
        elif self.puzzle_type == PUZZLE_TYPE_MEMORY:
            puzzle_name = "Головоломка памяти"
        elif self.puzzle_type == PUZZLE_TYPE_PLATFORM:
            puzzle_name = "Платформер"
            
        puzzle_text = font.render(puzzle_name, True, (180, 180, 180))
        screen.blit(puzzle_text, (12, 38))
        
        # Таймер для уровня 3
        if self.timer_active or self.current_level >= 3:
            time_color = (255, 50, 50) if self.timer_flash else (255, 255, 255)
            time_text = font_large.render(f"Время: {int(self.time_remaining)}с", True, time_color)
            screen.blit(time_text, (self.screen_width - 150, 12))
        
        # Прогресс для новых головоломок
        if self.puzzle_type == "maze":
            if hasattr(self, 'maze_puzzle'):
                progress = "Пройдено!" if self.maze_puzzle.solved else "Найдите выход"
                text = font.render(progress, True, self.ui_colors['success'] if self.maze_puzzle.solved else self.ui_colors['text'])
                screen.blit(text, (12, 65))
        elif self.puzzle_type == "wordsearch":
            if hasattr(self, 'wordsearch_puzzle'):
                found = len(self.wordsearch_puzzle.found_words)
                total = len(self.wordsearch_puzzle.words)
                progress = f"Найдено слов: {found}/{total}"
                text = font.render(progress, True, self.ui_colors['text'])
                screen.blit(text, (12, 65))
        elif self.puzzle_type == "pattern":
            if hasattr(self, 'pattern_puzzle'):
                progress = f"Раунд: {self.pattern_puzzle.current_round}/{self.pattern_puzzle.max_rounds}"
                text = font.render(progress, True, self.ui_colors['text'])
                screen.blit(text, (12, 65))
        # Прогресс (для уровней 1 и 3)
        elif self.puzzle_type in [PUZZLE_TYPE_COLLECT, PUZZLE_TYPE_TIMED]:
            if len(self.items) > 0:
                progress = f"Собрано: {len(self.collected_items)}/{len(self.items)}"
                text = font.render(progress, True, self.ui_colors['text'])
                screen.blit(text, (12, 65))
        
        # Прогресс переключателей (уровень 2)
        if self.puzzle_type == PUZZLE_TYPE_SWITCHES:
            progress = f"Активировано: {len(self.activated_switches)}/{len(self.switches)}"
            text = font.render(progress, True, self.ui_colors['text'])
            screen.blit(text, (12, 65))
        
        # Прогресс памяти (уровень 4)
        if self.puzzle_type == PUZZLE_TYPE_MEMORY:
            if self.memory_showing_sequence:
                progress = f"Запоминайте! Раунд {self.memory_round}/{self.memory_max_rounds}"
            else:
                progress = f"Ввод: {len(self.memory_input)}/{len(self.memory_sequence)} | Раунд {self.memory_round}/{self.memory_max_rounds}"
            text = font.render(progress, True, (255, 200, 100))
            screen.blit(text, (12, 65))
        
        # Прогресс платформера (уровень 5)
        if self.puzzle_type == PUZZLE_TYPE_PLATFORM:
            progress = f"Собрано: {len(self.collected_items)}/{len(self.items)}"
            text = font.render(progress, True, self.ui_colors['text'])
            screen.blit(text, (12, 65))
        
        # Подсказка (H)
        hint_text = font.render("H - Подсказка", True, (150, 150, 150))
        screen.blit(hint_text, (12, self.screen_height - 30))
        
        # Информация о рычаге
        if self.puzzle_solved and not self.lever_activated:
            lever_hint = font.render("E - Потянуть рычаг", True, (255, 215, 0))
            screen.blit(lever_hint, (self.screen_width - 180, self.screen_height - 30))
        elif self.lever_activated:
            lever_hint = font.render("Головоломка отключена", True, (100, 200, 100))
            screen.blit(lever_hint, (self.screen_width - 180, self.screen_height - 30))
        
        # Отображение подсказки
        if self.show_hint:
            self.draw_hint_box(screen, self.hint_text)
        
        # Экран победы
        if self.puzzle_solved and not self.win_animation:
            self.win_animation = True
            
            overlay = pygame.Surface((self.screen_width, self.screen_height), pygame.SRCALPHA)
            overlay.fill((0, 0, 0, 100))
            screen.blit(overlay, (0, 0))
            
            # Поздравление
            text = font_large.render("ГОЛОВОЛOMКА РЕШЕНА!", True, self.ui_colors['gold'])
            text_rect = text.get_rect(center=(self.screen_width // 2, self.screen_height // 2 - 30))
            screen.blit(text, text_rect)
            
            text = font.render("Поздравляем!", True, self.ui_colors['success'])
            text_rect = text.get_rect(center=(self.screen_width // 2, self.screen_height // 2 + 20))
            screen.blit(text, text_rect)
            
            # Кнопки для следующих уровней
            if self.current_level < 3:
                next_text = font.render("Нажмите 2 для следующего уровня" if self.current_level == 1 
                                       else "Нажмите 3 для сложного уровня", True, (200, 200, 200))
                next_rect = next_text.get_rect(center=(self.screen_width // 2, self.screen_height // 2 + 60))
                screen.blit(next_text, next_rect)

    def draw_hint_box(self, screen, text):
        """Отрисовка окна подсказки"""
        font = pygame.font.SysFont('arial', 18)
        
        # Размер окна
        text_surf = font.render(text, True, self.ui_colors['hint'])
        padding = 20
        box_width = text_surf.get_width() + padding * 2
        box_height = text_surf.get_height() + padding
        
        # Позиция (внизу по центру)
        box_x = (self.screen_width - box_width) // 2
        box_y = self.screen_height - box_height - 20
        
        # Рисуем фон окна
        bg_surf = pygame.Surface((box_width, box_height), pygame.SRCALPHA)
        bg_surf.fill((0, 0, 0, 200))
        screen.blit(bg_surf, (box_x, box_y))
        
        # Рисуем обводку
        pygame.draw.rect(screen, self.ui_colors['hint'], 
                        (box_x, box_y, box_width, box_height), 2)
        
        # Рисуем текст
        screen.blit(text_surf, (box_x + padding, box_y + padding // 2))

    def update_win_animation(self):
        """Обновление анимации победы"""
        if random.random() < 0.3:
            x = random.randint(50, self.screen_width - 50)
            y = self.screen_height - 100
            self.win_particles.append({
                'x': x,
                'y': y,
                'vx': random.uniform(-2, 2),
                'vy': random.uniform(-4, -1),
                'life': 60,
                'color': random.choice([(255, 215, 0), (255, 255, 100), (100, 255, 100)])
            })
            
        for p in self.win_particles[:]:
            p['x'] += p['vx']
            p['y'] += p['vy']
            p['vy'] += 0.05
            p['life'] -= 1
            if p['life'] <= 0:
                self.win_particles.remove(p)

    def is_puzzle_solved(self):
        """Проверяет, решена ли головоломка"""
        return self.puzzle_solved
    
    def get_level(self):
        """Возвращает текущий уровень"""
        return self.current_level
    
    def draw_lever(self, screen):
        """Отрисовка рычага"""
        # Позиция
        x, y, w, h = self.lever_rect.x, self.lever_rect.y, self.lever_rect.width, self.lever_rect.height
        
        # Основание
        pygame.draw.rect(screen, (80, 80, 80), (x, y + 40, w, 20), border_radius=3)
        
        # Рукоятка рычага
        if self.lever_activated:
            # Рычаг активирован (опущен)
            lever_color = (150, 150, 50)
            handle_y = y + 35
        else:
            # Рычаг не активирован (поднят)
            lever_color = (200, 150, 50)
            handle_y = y + 10
            
        # Стержень
        pygame.draw.rect(screen, (100, 100, 100), (x + w//2 - 3, handle_y, 6, 35))
        
        # Рукоятка
        pygame.draw.rect(screen, lever_color, (x, handle_y, w, 15), border_radius=5)
        pygame.draw.rect(screen, (255, 255, 255), (x, handle_y, w, 15), 2, border_radius=5)
        
        # Подпись
        font = pygame.font.SysFont('arial', 12)
        if self.lever_activated:
            text = font.render("Отключено", True, (100, 200, 100))
        else:
            text = font.render("E - Рычаг", True, (200, 200, 150))
        screen.blit(text, (x - 10, y + h + 5))
        
    def generate_memory_sequence(self):
        """Генерация последовательности для памяти"""
        self.memory_sequence = []
        for _ in range(2 + self.memory_round):  # 2-4 элемента в зависимости от раунда
            self.memory_sequence.append(random.randint(1, 4))
        self.memory_input = []
        self.memory_showing_sequence = True
        self.memory_display_timer = 60  # Показать на 1 секунду
        
    def update_memory_puzzle(self):
        """Обновление головоломки на память"""
        if self.memory_showing_sequence:
            self.memory_display_timer -= 1
            if self.memory_display_timer <= 0:
                self.memory_showing_sequence = False
                self.memory_display_timer = 0
        
    def handle_memory_click(self, button_id):
        """Обработка клика на кнопку памяти"""
        if self.puzzle_type != PUZZLE_TYPE_MEMORY or self.memory_showing_sequence:
            return
            
        expected = self.memory_sequence[len(self.memory_input)]
        
        if button_id == expected:
            self.memory_input.append(button_id)
            # Эффект правильного ответа
            self.particle_system.emit(
                300 + button_id * 50, 250, (100, 255, 100), 10, 3, 20
            )
            
            # Проверка завершения последовательности
            if len(self.memory_input) == len(self.memory_sequence):
                if self.memory_round < self.memory_max_rounds:
                    self.memory_round += 1
                    self.generate_memory_sequence()
                else:
                    # Все раунды пройдены
                    self.puzzle_solved = True
                    for item in self.items:
                        item.show()
        else:
            # Неправильный ответ - сброс
            self.memory_input = []
            self.memory_round = 1
            self.generate_memory_sequence()
            # Эффект ошибки
            self.particle_system.emit(300, 250, (255, 50, 50), 20, 5, 30)
            
    def update_platformer(self):
        """Обновление физики платформера"""
        # Проверка коллизий с платформами
        player_bottom = self.player.y + self.player.height
        player_right = self.player.x + self.player.width
        self.player_on_ground = False
        
        for platform in self.platforms:
            px, py, pw, ph = platform['x'], platform['y'], platform['w'], platform['h']
            
            # Проверка: игрок падает вниз на платформу
            if (self.player.x + self.player.width > px and 
                self.player.x < px + pw and
                player_bottom >= py and 
                player_bottom <= py + 20 and
                self.player.vy > 0):
                
                self.player.y = py - self.player.height
                self.player.vy = 0
                self.player_on_ground = True
                
        # Прыжок
        if keys_pressed[pygame.K_SPACE] and self.player_on_ground:
            self.player.vy = -12
            
    def draw_platforms(self, screen):
        """Отрисовка платформ"""
        for p in self.platforms:
            pygame.draw.rect(screen, (100, 80, 60), (p['x'], p['y'], p['w'], p['h']))
            pygame.draw.rect(screen, (150, 120, 80), (p['x'], p['y'], p['w'], 5))
            
    def draw_memory_buttons(self, screen):
        """Отрисовка кнопок памяти"""
        for btn in self.memory_buttons:
            # Определяем цвет
            if self.memory_showing_sequence:
                # Показываем последовательность
                if btn['id'] in self.memory_sequence[:len(self.memory_input) + 1]:
                    if self.memory_display_timer > 30:
                        color = (255, 255, 255)
                    else:
                        color = btn['color']
                else:
                    color = (btn['color'][0] // 3, btn['color'][1] // 3, btn['color'][2] // 3)
            else:
                # Ожидаем ввода
                color = btn['color']
                
            # Рисуем кнопку
            pygame.draw.rect(screen, color, (btn['x'], btn['y'], 80, 60), border_radius=10)
            pygame.draw.rect(screen, (255, 255, 255), (btn['x'], btn['y'], 80, 60), 3, border_radius=10)


class ParticleSystem:
    """Упрощенная система частиц для сцены"""
    def __init__(self):
        self.particles = []
        
    def emit(self, x, y, color, count=20, spread=3, lifetime=40):
        """Испускание частиц"""
        for _ in range(count):
            angle = random.uniform(0, 2 * math.pi)
            speed = random.uniform(1, spread)
            vx = math.cos(angle) * speed
            vy = math.sin(angle) * speed - 1
            size = random.randint(2, 5)
            particle = Particle(x, y, color, vx, vy, lifetime + random.randint(-10, 10), size)
            self.particles.append(particle)
            
    def update(self):
        """Обновление частиц"""
        for particle in self.particles:
            particle.update()
        self.particles = [p for p in self.particles if p.alive]
        
    def draw(self, screen):
        """Отрисовка частиц"""
        for particle in self.particles:
            particle.draw(screen)


class Particle:
    """Класс частицы"""
    def __init__(self, x, y, color, velocity_x, velocity_y, lifetime, size):
        self.x = x
        self.y = y
        self.color = color
        self.velocity_x = velocity_x
        self.velocity_y = velocity_y
        self.lifetime = lifetime
        self.max_lifetime = lifetime
        self.size = size
        self.alive = True
        
    def update(self):
        """Обновление частицы"""
        self.x += self.velocity_x
        self.y += self.velocity_y
        self.lifetime -= 1
        if self.lifetime <= 0:
            self.alive = False
            return
        self.velocity_x *= 0.98
        self.velocity_y *= 0.98
        
    def draw(self, screen):
        """Отрисовка частицы"""
        if self.alive and self.lifetime > 0:
            alpha = int(255 * (self.lifetime / self.max_lifetime))
            surf = pygame.Surface((self.size * 2, self.size * 2), pygame.SRCALPHA)
            pygame.draw.circle(surf, (*self.color, alpha), (self.size, self.size), self.size)
            screen.blit(surf, (int(self.x - self.size), int(self.y - self.size)))


class TransitionEffect:
    """Эффект перехода"""
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.transitioning = False
        self.progress = 0
        self.duration = 30
        self.transition_type = "fade"
        
    def start_transition(self, transition_type="fade"):
        """Запуск перехода"""
        self.transitioning = True
        self.progress = 0
        self.transition_type = transition_type
        
    def update(self):
        """Обновление перехода"""
        if self.transitioning:
            self.progress += 1
            if self.progress >= self.duration:
                self.transitioning = False
                self.progress = 0
                
    def is_complete(self):
        """Проверка завершения"""
        return not self.transitioning
