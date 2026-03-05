import pygame
import random
import math


class MenuScene:
    """Сцена стартового меню игры"""
    
    def __init__(self, screen_width, screen_height):
        self.screen_width = screen_width
        self.screen_height = screen_height
        
        # Состояние меню
        self.selected_option = 0  # 0 - Играть, 1 - Выход
        self.transition_progress = 0
        self.is_transitioning = False
        self.transition_direction = None  # 'in' или 'out'
        self._transition_out_triggered = False  # Флаг запуска перехода 'out'
        
        # Цвета
        self.colors = {
            'bg_top': (20, 20, 60),
            'bg_bottom': (60, 20, 80),
            'title': (255, 215, 0),
            'title_shadow': (150, 100, 0),
            'button_normal': (50, 50, 100),
            'button_hover': (80, 80, 150),
            'button_selected': (100, 150, 200),
            'text_normal': (200, 200, 200),
            'text_hover': (255, 255, 255),
            'text_selected': (255, 255, 255),
            'star': (255, 255, 255)
        }
        
        # Шрифты
        self.font_title = pygame.font.SysFont('fantasy', 72, bold=True)
        self.font_button = pygame.font.SysFont('fantasy', 36, bold=True)
        self.font_subtitle = pygame.font.SysFont('arial', 18)
        
        # Кнопки меню
        self.buttons = [
            {'text': 'Играть', 'y_offset': 50},
            {'text': 'Выход', 'y_offset': 120}
        ]
        
        # Анимация заголовка (пульсация)
        self.title_pulse = 0
        self.title_pulse_speed = 0.03
        
        # Фоновые звезды
        self.stars = []
        for _ in range(100):
            self.stars.append({
                'x': random.randint(0, screen_width),
                'y': random.randint(0, screen_height),
                'size': random.randint(1, 3),
                'speed': random.uniform(0.1, 0.5),
                'brightness': random.randint(100, 255),
                'twinkle_offset': random.uniform(0, 2 * math.pi)
            })
        
        # Частицы фона
        self.particles = []
        self.particle_timer = 0
        
        # Анимация кнопок
        self.button_hover_animation = [0, 0]  # Анимация наведения для каждой кнопки
        
    def handle_events(self, events):
        """Обработка событий меню"""
        if self.is_transitioning:
            return
            
        for event in events:
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_UP or event.key == pygame.K_w:
                    self.selected_option = (self.selected_option - 1) % len(self.buttons)
                elif event.key == pygame.K_DOWN or event.key == pygame.K_s:
                    self.selected_option = (self.selected_option + 1) % len(self.buttons)
                elif event.key == pygame.K_RETURN or event.key == pygame.K_SPACE:
                    self.select_option()
                    
    def update(self, keys_pressed):
        """Обновление состояния меню"""
        # Обновление пульсации заголовка
        self.title_pulse += self.title_pulse_speed
        if self.title_pulse > 2 * math.pi:
            self.title_pulse -= 2 * math.pi
        
        # Обновление звезд
        for star in self.stars:
            star['y'] += star['speed']
            if star['y'] > self.screen_height:
                star['y'] = 0
                star['x'] = random.randint(0, self.screen_width)
        
        # Обновление частиц
        self.particle_timer += 1
        if self.particle_timer > 10:
            self.particle_timer = 0
            if len(self.particles) < 30:
                self.particles.append(self.create_particle())
        
        for particle in self.particles[:]:
            particle['x'] += particle['vx']
            particle['y'] += particle['vy']
            particle['life'] -= 1
            particle['vy'] += 0.02  # Гравитация
            if particle['life'] <= 0:
                self.particles.remove(particle)
        
        # Обновление анимации кнопок
        for i in range(len(self.buttons)):
            target = 1.0 if i == self.selected_option else 0.0
            self.button_hover_animation[i] += (target - self.button_hover_animation[i]) * 0.15
        
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
                
    def create_particle(self):
        """Создание новой частицы"""
        return {
            'x': random.randint(0, self.screen_width),
            'y': -10,
            'vx': random.uniform(-0.5, 0.5),
            'vy': random.uniform(1, 2),
            'life': random.randint(60, 120),
            'color': random.choice([
                (255, 215, 0),  # Золото
                (100, 150, 255),  # Голубой
                (200, 100, 255)   # Фиолетовый
            ]),
            'size': random.randint(2, 4)
        }
        
    def draw(self, screen):
        """Отрисовка меню"""
        # Рисуем фон
        self.draw_background(screen)
        
        # Рисуем звезды
        self.draw_stars(screen)
        
        # Рисуем частицы
        self.draw_particles(screen)
        
        # Рисуем заголовок
        self.draw_title(screen)
        
        # Рисуем кнопки
        self.draw_buttons(screen)
        
        # Рисуем подсказки
        self.draw_hints(screen)
        
        # Рисуем переход
        if self.transition_direction:
            self.draw_transition(screen)
            
    def draw_background(self, screen):
        """Рисуем градиентный фон"""
        # Создаем градиент
        colors = [
            self.colors['bg_top'],
            (40, 20, 70),
            self.colors['bg_bottom']
        ]
        
        num_strips = len(colors)
        strip_height = self.screen_height // (num_strips - 1)
        
        for i in range(num_strips - 1):
            top_color = colors[i]
            bottom_color = colors[i + 1]
            
            for y in range(i * strip_height, (i + 1) * strip_height):
                if y >= self.screen_height:
                    break
                t = y % strip_height / strip_height
                r = int(top_color[0] + (bottom_color[0] - top_color[0]) * t)
                g = int(top_color[1] + (bottom_color[1] - top_color[1]) * t)
                b = int(top_color[2] + (bottom_color[2] - top_color[2]) * t)
                pygame.draw.line(screen, (r, g, b), (0, y), (self.screen_width, y))
                
    def draw_stars(self, screen):
        """Рисуем мерцающие звезды"""
        for star in self.stars:
            # Вычисляем мерцание
            twinkle = math.sin(self.title_pulse * 2 + star['twinkle_offset'])
            brightness = int(star['brightness'] * (0.5 + 0.5 * twinkle))
            
            color = (brightness, brightness, min(brightness + 30, 255))
            pygame.draw.circle(screen, color, (int(star['x']), int(star['y'])), star['size'])
            
    def draw_particles(self, screen):
        """Рисуем частицы"""
        for particle in self.particles:
            alpha = int(255 * (particle['life'] / 120))
            color = (*particle['color'], alpha)
            surf = pygame.Surface((particle['size'] * 2, particle['size'] * 2), pygame.SRCALPHA)
            pygame.draw.circle(surf, color, (particle['size'], particle['size']), particle['size'])
            screen.blit(surf, (int(particle['x'] - particle['size']), int(particle['y'] - particle['size'])))
            
    def draw_title(self, screen):
        """Рисуем заголовок игры с пульсацией"""
        title = "Приключенческая"
        subtitle = "ИГРА"
        
        # Эффект пульсации
        pulse_scale = 1.0 + 0.03 * math.sin(self.title_pulse * 2)
        
        # Тень заголовка
        shadow_offset = 4 + 2 * math.sin(self.title_pulse)
        
        # Основной заголовок
        title_surf = self.font_title.render(title, True, self.colors['title_shadow'])
        title_rect = title_surf.get_rect(center=(self.screen_width // 2 + shadow_offset, 150 + shadow_offset))
        screen.blit(title_surf, title_rect)
        
        # Подзаголовок
        subtitle_surf = self.font_title.render(subtitle, True, self.colors['title_shadow'])
        subtitle_rect = subtitle_surf.get_rect(center=(self.screen_width // 2 + shadow_offset, 220 + shadow_offset))
        
        # Масштабируем подзаголовок
        scaled_subtitle = pygame.transform.scale(
            subtitle_surf, 
            (int(subtitle_rect.width * pulse_scale), int(subtitle_rect.height * pulse_scale))
        )
        subtitle_rect = scaled_subtitle.get_rect(center=(self.screen_width // 2 + shadow_offset, 220 + shadow_offset))
        screen.blit(scaled_subtitle, subtitle_rect)
        
        # Основной заголовок (передний план)
        title_surf = self.font_title.render(title, True, self.colors['title'])
        title_rect = title_surf.get_rect(center=(self.screen_width // 2, 150))
        screen.blit(title_surf, title_rect)
        
        # Подзаголовок с пульсацией
        subtitle_surf = self.font_title.render(subtitle, True, self.colors['title'])
        subtitle_rect = subtitle_surf.get_rect(center=(self.screen_width // 2, 220))
        scaled_subtitle = pygame.transform.scale(
            subtitle_surf, 
            (int(subtitle_rect.width * pulse_scale), int(subtitle_rect.height * pulse_scale))
        )
        subtitle_rect = scaled_subtitle.get_rect(center=(self.screen_width // 2, 220))
        screen.blit(scaled_subtitle, subtitle_rect)
        
        # Декоративные линии по бокам
        line_length = 80
        line_y = 185
        pygame.draw.line(screen, self.colors['title'], 
                        (self.screen_width // 2 - 200, line_y), 
                        (self.screen_width // 2 - 50, line_y), 2)
        pygame.draw.line(screen, self.colors['title'], 
                        (self.screen_width // 2 + 50, line_y), 
                        (self.screen_width // 2 + 200, line_y), 2)
                        
    def draw_buttons(self, screen):
        """Рисуем кнопки меню с анимацией"""
        for i, button in enumerate(self.buttons):
            # Позиция кнопки
            x = self.screen_width // 2
            y = self.screen_height // 2 + button['y_offset']
            
            # Анимация масштаба
            scale = 1.0 + 0.1 * self.button_hover_animation[i]
            
            # Цвета кнопки
            if i == self.selected_option:
                button_color = self.colors['button_selected']
                text_color = self.colors['text_selected']
            else:
                button_color = self.colors['button_normal']
                text_color = self.colors['text_normal']
            
            # Рисуем фон кнопки с эффектом свечения
            button_rect = pygame.Rect(0, 0, 250, 60)
            button_rect.center = (x, y)
            
            # Свечение для выбранной кнопки
            if i == self.selected_option:
                glow_rect = button_rect.copy()
                glow_rect.inflate_ip(20, 20)
                glow_surf = pygame.Surface((glow_rect.width, glow_rect.height), pygame.SRCALPHA)
                pygame.draw.rect(glow_surf, (*button_color, 50), 
                               (0, 0, glow_rect.width, glow_rect.height), border_radius=15)
                screen.blit(glow_surf, glow_rect.topleft)
            
            # Основная кнопка
            button_surf = pygame.Surface((button_rect.width, button_rect.height), pygame.SRCALPHA)
            pygame.draw.rect(button_surf, (*button_color, 180), 
                           (0, 0, button_rect.width, button_rect.height), border_radius=15)
            pygame.draw.rect(button_surf, self.colors['title'], 
                           (0, 0, button_rect.width, button_rect.height), 3, border_radius=15)
            screen.blit(button_surf, button_rect.topleft)
            
            # Текст кнопки
            text_surf = self.font_button.render(button['text'], True, text_color)
            text_rect = text_surf.get_rect(center=(x, y))
            
            # Масштабируем текст
            if scale != 1.0:
                text_surf = pygame.transform.scale(text_surf, 
                    (int(text_rect.width * scale), int(text_rect.height * scale)))
                text_rect = text_surf.get_rect(center=(x, y))
                
            screen.blit(text_surf, text_rect)
            
    def draw_hints(self, screen):
        """Рисуем подсказки управления"""
        hint_text = "Используйте ↑↓ для выбора, Enter для подтверждения"
        hint_surf = self.font_subtitle.render(hint_text, True, (150, 150, 150))
        hint_rect = hint_surf.get_rect(center=(self.screen_width // 2, self.screen_height - 40))
        screen.blit(hint_surf, hint_rect)
        
    def draw_transition(self, screen):
        """Рисуем эффект перехода"""
        if self.transition_progress > 0:
            overlay = pygame.Surface((self.screen_width, self.screen_height))
            overlay.fill((0, 0, 0))
            overlay.set_alpha(int(255 * self.transition_progress))
            screen.blit(overlay, (0, 0))
            
    def select_option(self):
        """Выбор опции меню"""
        print(f"[MENU] select_option: {self.selected_option}")
        if self.selected_option == 0:
            # Запуск игры
            self.start_transition_out()
        elif self.selected_option == 1:
            # Выход из игры
            import sys
            pygame.quit()
            sys.exit()
            
    def start_transition_out(self):
        """Запуск перехода для выхода из меню"""
        print("[MENU] start_transition_out called!")
        self.is_transitioning = True
        self.transition_direction = 'out'
        self._transition_out_triggered = True
        
    def is_transition_complete(self):
        """Проверка завершения перехода"""
        result = self._transition_out_triggered and self.transition_progress <= 0
        print(f"[MENU] is_transition_complete: triggered={self._transition_out_triggered}, progress={self.transition_progress}, result={result}")
        return result
        
    def get_result(self):
        """Возвращает результат работы меню"""
        if self.selected_option == 0:
            return 'play'
        return 'exit'
