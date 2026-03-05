import pygame
import random
import math
from .minigames import NPC


class TownScene:
    """Сцена города - хаб для перехода к уровням"""
    
    def __init__(self, screen_width, screen_height):
        self.screen_width = screen_width
        self.screen_height = screen_height
        
        # Состояние меню
        self.selected_option = 0
        self.transition_progress = 0
        self.is_transitioning = False
        self.transition_direction = None
        
        # Результат выбора
        self.result = None  # 'level1', 'level2', 'level3', 'back'
        
        # Цвета
        self.colors = {
            'bg_top': (30, 60, 90),
            'bg_bottom': (80, 50, 40),
            'ground': (60, 40, 30),
            'text': (255, 230, 180),
            'text_shadow': (30, 20, 10),
            'building': (100, 80, 60),
            'building_roof': (80, 50, 40),
            'window': (255, 220, 100),
            'door': (60, 40, 30),
            'lever_base': (80, 80, 80),
            'lever_handle': (200, 150, 50),
            'available': (100, 200, 100),
            'locked': (150, 50, 50),
            'completed': (255, 215, 0)
        }
        
        # Шрифты
        self.font_title = pygame.font.SysFont('fantasy', 48, bold=True)
        self.font_button = pygame.font.SysFont('fantasy', 28, bold=True)
        self.font_subtitle = pygame.font.SysFont('arial', 16)
        self.font_story = pygame.font.SysFont('arial', 18)
        
        # Опции меню (уровни)
        self.options = [
            {'text': 'Подземелье I - Заброшенная шахта', 'level': 1, 'desc': 'Найдите ключ от врат'},
            {'text': 'Подземелье II - Логово стражей', 'level': 2, 'desc': 'Активируйте механизм'},
            {'text': 'Подземелье III - Храм времени', 'level': 3, 'desc': 'Успейте до заката'},
            {'text': 'Подземелье IV - Лабиринт теней', 'level': 4, 'desc': 'Проверьте память'},
            {'text': 'Подземелье V - Башня кристаллов', 'level': 5, 'desc': 'Прыгайте по платформам'},
            {'text': 'Подземелье VI - Финал', 'level': 6, 'desc': 'Соберите артефакты'},
            {'text': 'Вернуться в меню', 'level': 0, 'desc': ''}
        ]
        
        # Опции для NPC (будут добавлены динамически)
        self.npc_options = []
        self.show_npc_menu = False
        self.npc_selected = 0
        
        # Система сохранения прогресса
        self.progress = {
            1: {'completed': False, 'lever_pulled': False},
            2: {'completed': False, 'lever_pulled': False},
            3: {'completed': False, 'lever_pulled': False},
            4: {'completed': False, 'lever_pulled': False},
            5: {'completed': False, 'lever_pulled': False},
            6: {'completed': False, 'lever_pulled': False}
        }
        
        # Здания города
        self.buildings = []
        self.create_buildings()
        
        # Частицы (светлячки)
        self.particles = []
        
        # Анимация
        self.anim_time = 0
        
        # Сюжетная линия (показывается один раз)
        self.show_story = True
        self.story_text = [
            "Древнее пророчество гласит:",
            "Тот, кто найдёт три части Артефакта Вечности,",
            "обретёт силу повелевать временем...",
            "",
            "Ты - искатель приключений, отправившийся",
            "в подземелья Древнего Королевства.",
            "Твоя цель - найти и собрать части Артефакта.",
            "",
            "Путь лежит через три подземелья..."
        ]
        self.story_index = 0
        self.story_timer = 0
        self.story_fade = 0
        
    def create_buildings(self):
        """Создание зданий города"""
        # Дома
        self.buildings = [
            {'x': 50, 'y': 200, 'w': 80, 'h': 120, 'type': 'house'},
            {'x': 150, 'y': 180, 'w': 100, 'h': 140, 'type': 'house'},
            {'x': 550, 'y': 190, 'w': 90, 'h': 130, 'type': 'house'},
            {'x': 660, 'y': 170, 'w': 110, 'h': 150, 'type': 'house'},
        ]
        
        # Магазин (центр)
        self.shop = {'x': 300, 'y': 150, 'w': 200, 'h': 180, 'type': 'shop'}
        
        # NPC старик
        self.npc = {'x': 400, 'y': 350, 'w': 30, 'h': 60}
        
        # Инвентарь игрока
        self.player_inventory = {
            'gold': 100,
            'items': [],
            'won_minigames': []
        }
        
        # Создаём NPC
        self.npcs = []
        # NPC для мини-игр
        self.npcs.append(NPC(80, 390, "Мастер РПС", "Давай сыграем в Камень-Ножницы-Бумага!", "rps", "Золото x50"))
        self.npcs.append(NPC(150, 390, "Мудрец", "Ответь на мои вопросы!", "quiz", "Свиток мудрости"))
        self.npcs.append(NPC(580, 390, "Воин", "Хочешь померяться силами?", "duel", "Меч воина"))
        self.npcs.append(NPC(650, 390, "Торговец", "Испытай удачу!", "gacha", "Редкий предмет"))
        self.npcs.append(NPC(500, 390, "Целитель", "Проверю твоё здоровье!", "quiz", "Зелье здоровья"))

    def handle_events(self, events):
        """Обработка событий"""
        # Обработка сюжета
        if self.show_story:
            for event in events:
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_RETURN or event.key == pygame.K_SPACE:
                        self.next_story_line()
                    elif event.key == pygame.K_ESCAPE:
                        self.show_story = False
            return
        
        if self.is_transitioning:
            return
            
        for event in events:
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_e:
                    # Взаимодействие с NPC
                    self.interact_with_npcs()
                elif event.key == pygame.K_UP or event.key == pygame.K_w:
                    self.selected_option = (self.selected_option - 1) % len(self.options)
                elif event.key == pygame.K_DOWN or event.key == pygame.K_s:
                    self.selected_option = (self.selected_option + 1) % len(self.options)
                elif event.key == pygame.K_RETURN or event.key == pygame.K_SPACE:
                    self.select_option()
                    
    def next_story_line(self):
        """Переход к следующей строке сюжета"""
        self.story_index += 1
        self.story_fade = 0
        if self.story_index >= len(self.story_text):
            self.show_story = False
            
    def update(self, keys_pressed):
        """Обновление состояния"""
        self.anim_time += 0.02
        
        # Обновление сюжета
        if self.show_story:
            self.story_fade = min(1.0, self.story_fade + 0.05)
            return
        
        # Частицы (светлячки)
        if random.random() < 0.05:
            self.particles.append({
                'x': random.randint(50, self.screen_width - 50),
                'y': random.randint(100, 350),
                'vx': random.uniform(-0.3, 0.3),
                'vy': random.uniform(-0.2, 0.2),
                'life': random.randint(60, 120),
                'size': random.randint(2, 4)
            })
            
        for p in self.particles[:]:
            p['x'] += p['vx']
            p['y'] += p['vy']
            p['life'] -= 1
            if p['life'] <= 0:
                self.particles.remove(p)
        
        # Обновление перехода
        if self.transition_direction == 'in':
            self.transition_progress += 0.05
            if self.transition_progress >= 1.0:
                self.transition_progress = 1.0
                self.is_transitioning = False
                self.transition_direction = None
        elif self.transition_direction == 'out':
            self.transition_progress -= 0.05
            if self.transition_progress <= 0.0:
                self.transition_progress = 0.0
                self.is_transitioning = False
                self.transition_direction = None
                
    def select_option(self):
        """Выбор опции"""
        option = self.options[self.selected_option]
        
        if option['level'] == 0:
            # Вернуться в меню
            self.result = 'back'
        else:
            # Проверка доступности уровня
            level = option['level']
            if level == 1 or self.progress[level - 1]['completed']:
                self.result = f'level{level}'
            else:
                # Уровень заблокирован
                pass
                
    def interact_with_npcs(self):
        """Взаимодействие с NPC"""
        # Показать меню NPC
        # Показываем список мини-игр
        self.show_npc_menu = True
        self.npc_selected = 0
        
    def update_npc_menu(self, keys_pressed):
        """Обновление меню NPC"""
        if not hasattr(self, 'show_npc_menu') or not self.show_npc_menu:
            return
            
        if keys_pressed[pygame.K_UP] or keys_pressed[pygame.K_w]:
            self.npc_selected = (self.npc_selected - 1) % len(self.npcs)
        elif keys_pressed[pygame.K_DOWN] or keys_pressed[pygame.K_s]:
            self.npc_selected = (self.npc_selected + 1) % len(self.npcs)
        elif keys_pressed[pygame.K_RETURN] or keys_pressed[pygame.K_SPACE]:
            # Запуск мини-игры
            self.result = f'npc_{self.npc_selected}'
            self.show_npc_menu = False
                
    def draw(self, screen):
        """Отрисовка города"""
        # Рисуем фон
        self.draw_background(screen)
        
        # Рисуем здания
        self.draw_buildings(screen)
        
        # Рисуем магазин
        self.draw_shop(screen)
        
        # Рисуем NPC
        self.draw_npcs(screen)
        
        # Рисуем частицы
        self.draw_particles(screen)
        
        # Рисуем сюжет
        if self.show_story:
            self.draw_story(screen)
            return
        
        # Рисуем название города
        self.draw_title(screen)
        
        # Рисуем опции меню
        self.draw_options(screen)
        
        # Рисуем подсказки
        self.draw_hints(screen)
        
        # Рисуем переход
        if self.transition_direction:
            self.draw_transition(screen)
            
    def draw_background(self, screen):
        """Рисуем фон города"""
        # Небо (градиент)
        for y in range(self.screen_height):
            t = y / self.screen_height
            r = int(self.colors['bg_top'][0] + (self.colors['bg_bottom'][0] - self.colors['bg_top'][0]) * t)
            g = int(self.colors['bg_top'][1] + (self.colors['bg_bottom'][1] - self.colors['bg_top'][1]) * t)
            b = int(self.colors['bg_top'][2] + (self.colors['bg_bottom'][2] - self.colors['bg_top'][2]) * t)
            pygame.draw.line(screen, (r, g, b), (0, y), (self.screen_width, y))
            
        # Земля
        ground_y = self.screen_height - 150
        pygame.draw.rect(screen, self.colors['ground'], 
                        (0, ground_y, self.screen_width, 150))
        
        # Дорога
        pygame.draw.rect(screen, (90, 70, 50), 
                        (0, ground_y + 20, self.screen_width, 80))
        
    def draw_buildings(self, screen):
        """Рисуем здания"""
        for b in self.buildings:
            # Стены
            pygame.draw.rect(screen, self.colors['building'],
                           (b['x'], b['y'], b['w'], b['h']))
            
            # Крыша
            roof_points = [
                (b['x'] - 10, b['y']),
                (b['x'] + b['w'] + 10, b['y']),
                (b['x'] + b['w'] // 2, b['y'] - 50)
            ]
            pygame.draw.polygon(screen, self.colors['building_roof'], roof_points)
            
            # Окна
            for wx in range(b['x'] + 15, b['x'] + b['w'] - 20, 25):
                pygame.draw.rect(screen, self.colors['window'],
                               (wx, b['y'] + 30, 15, 20))
                
            # Дверь
            pygame.draw.rect(screen, self.colors['door'],
                           (b['x'] + b['w'] // 2 - 12, b['y'] + b['h'] - 50, 24, 50))
            
    def draw_shop(self, screen):
        """Рисуем магазин"""
        s = self.shop
        
        # Вывеска "Магазин"
        sign_y = s['y'] - 40
        pygame.draw.rect(screen, (120, 80, 40),
                        (s['x'], sign_y, s['w'], 35))
        
        font_sign = pygame.font.SysFont('arial', 16, bold=True)
        sign_text = font_sign.render("МАГАЗИН", True, (255, 230, 180))
        screen.blit(sign_text, (s['x'] + (s['w'] - sign_text.get_width()) // 2, sign_y + 8))
        
        # Здание
        pygame.draw.rect(screen, (140, 100, 70), (s['x'], s['y'], s['w'], s['h']))
        
        # Крыша
        roof_points = [
            (s['x'] - 15, s['y']),
            (s['x'] + s['w'] + 15, s['y']),
            (s['x'] + s['w'] // 2, s['y'] - 60)
        ]
        pygame.draw.polygon(screen, (120, 60, 40), roof_points)
        
        # Витрина
        pygame.draw.rect(screen, self.colors['window'],
                       (s['x'] + 20, s['y'] + 40, s['w'] - 40, 80))
        
        # Дверь
        pygame.draw.rect(screen, self.colors['door'],
                       (s['x'] + s['w'] // 2 - 15, s['y'] + s['h'] - 55, 30, 55))
        
    def draw_npc(self, screen):
        """Рисуем NPC (старик)"""
        npc = self.npc
        
        # Тело
        pygame.draw.rect(screen, (100, 80, 60),
                        (npc['x'], npc['y'], npc['w'], npc['h']))
        
        # Голова
        pygame.draw.circle(screen, (220, 180, 140),
                         (npc['x'] + npc['w'] // 2, npc['y'] - 10), 15)
        
        # Борода
        pygame.draw.polygon(screen, (200, 200, 180), [
            (npc['x'] + 5, npc['y']),
            (npc['x'] + npc['w'] - 5, npc['y']),
            (npc['x'] + npc['w'] // 2, npc['y'] + 20)
        ])
        
        # Подсказка
        font_hint = pygame.font.SysFont('arial', 12)
        hint = font_hint.render("Старик-хранитель", True, (200, 200, 150))
        screen.blit(hint, (npc['x'] - 20, npc['y'] - 35))
        
    def draw_npcs(self, screen):
        """Отрисовка всех NPC"""
        for npc in self.npcs:
            npc.draw(screen)
            
            # Подсказка
            font_hint = pygame.font.SysFont('arial', 10)
            hint = font_hint.render(npc.name, True, (200, 200, 150))
            screen.blit(hint, (npc.x - 10, npc.y - 15))
        
    def draw_particles(self, screen):
        """Рисуем частицы (светлячки)"""
        for p in self.particles:
            alpha = int(255 * (p['life'] / 100))
            pulse = math.sin(self.anim_time * 3 + p['x']) * 0.3 + 0.7
            color = (int(255 * pulse), int(255 * pulse), int(100 * pulse))
            
            pygame.draw.circle(screen, color,
                             (int(p['x']), int(p['y'])), p['size'])
                             
    def draw_story(self, screen):
        """Отрисовка сюжета"""
        # Затемнение
        overlay = pygame.Surface((self.screen_width, self.screen_height))
        overlay.fill((0, 0, 0))
        overlay.set_alpha(int(200 * self.story_fade))
        screen.blit(overlay, (0, 0))
        
        if self.story_fade > 0.3:
            # Текст сюжета
            y = self.screen_height // 2 - 100
            
            for i, line in enumerate(self.story_text):
                color = (200, 180, 150) if line else (0, 0, 0)
                text = self.font_story.render(line, True, color)
                rect = text.get_rect(center=(self.screen_width // 2, y + i * 30))
                screen.blit(text, rect)
            
            # Подсказка
            hint = self.font_subtitle.render("Нажмите ENTER для продолжения...", True, (150, 150, 150))
            hint_rect = hint.get_rect(center=(self.screen_width // 2, self.screen_height - 50))
            screen.blit(hint, hint_rect)
            
    def draw_title(self, screen):
        """Отрисовка названия"""
        title = "ГОРОД ЭЛЬДОРАДО"
        
        # Тень
        shadow = self.font_title.render(title, True, self.colors['text_shadow'])
        screen.blit(shadow, (self.screen_width // 2 - shadow.get_width() // 2 + 3, 23))
        
        # Основной текст
        text = self.font_title.render(title, True, self.colors['text'])
        screen.blit(text, (self.screen_width // 2 - text.get_width() // 2, 20))
        
        # Подзаголовок
        subtitle = self.font_story.render("Центральная площадь", True, (180, 160, 140))
        screen.blit(subtitle, (self.screen_width // 2 - subtitle.get_width() // 2, 70))
        
    def draw_options(self, screen):
        """Отрисовка опций меню"""
        y_start = 120
        
        for i, option in enumerate(self.options):
            y = y_start + i * 70
            
            # Проверка доступности
            if option['level'] > 0:
                is_unlocked = option['level'] == 1 or self.progress[option['level'] - 1]['completed']
                is_completed = self.progress[option['level']]['completed']
            else:
                is_unlocked = True
                is_completed = False
            
            # Фон опции
            if i == self.selected_option:
                bg_color = (60, 80, 100)
                border_color = (100, 150, 200)
            else:
                bg_color = (40, 50, 60)
                border_color = (80, 90, 100)
            
            # Заблокированный уровень
            if option['level'] > 0 and not is_unlocked:
                bg_color = (50, 40, 40)
                border_color = (100, 50, 50)
            
            # Рисуем фон
            rect = pygame.Rect(50, y, self.screen_width - 100, 65)
            pygame.draw.rect(screen, bg_color, rect, border_radius=10)
            pygame.draw.rect(screen, border_color, rect, 2, border_radius=10)
            
            # Статус уровня
            status_x = 70
            if option['level'] > 0:
                if is_completed:
                    # Пройдено - золотая звезда
                    star_color = self.colors['completed']
                    status_text = "✓ ПРОЙДЕНО"
                    status_color = (100, 200, 100)
                elif is_unlocked:
                    status_text = "► ДОСТУПНО"
                    status_color = self.colors['available']
                else:
                    status_text = "🔒 ЗАБЛОКИРОВАНО"
                    status_color = self.colors['locked']
                
                status_surf = self.font_subtitle.render(status_text, True, status_color)
                screen.blit(status_surf, (status_x, y + 5))
            
            # Название уровня
            text_color = (200, 200, 200) if is_unlocked else (120, 120, 120)
            text = self.font_button.render(option['text'], True, text_color)
            screen.blit(text, (status_x, y + 22))
            
            # Описание
            if option['desc']:
                desc = self.font_subtitle.render(option['desc'], True, (140, 140, 140))
                screen.blit(desc, (status_x, y + 48))
                
    def draw_hints(self, screen):
        """Отрисовка подсказок"""
        hint_text = "↑↓ для выбора, ENTER для входа, E - мини-игры"
        hint_surf = self.font_subtitle.render(hint_text, True, (150, 150, 150))
        hint_rect = hint_surf.get_rect(center=(self.screen_width // 2, self.screen_height - 30))
        screen.blit(hint_surf, hint_rect)
        
    def draw_transition(self, screen):
        """Рисуем эффект перехода"""
        if self.transition_progress > 0:
            overlay = pygame.Surface((self.screen_width, self.screen_height))
            overlay.fill((0, 0, 0))
            overlay.set_alpha(int(255 * self.transition_progress))
            screen.blit(overlay, (0, 0))
            
    def is_transition_complete(self):
        """Проверка завершения перехода"""
        return self.result is not None
        
    def get_result(self):
        """Возвращает результат"""
        return self.result
        
    def set_progress(self, level, completed=False, lever_pulled=False):
        """Установить прогресс уровня"""
        if level in self.progress:
            if completed:
                self.progress[level]['completed'] = True
            if lever_pulled:
                self.progress[level]['lever_pulled'] = True
                
    def get_progress(self):
        """Получить прогресс"""
        return self.progress
