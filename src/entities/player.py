import pygame
import math

class Player:
    def __init__(self, x, y, width, height, speed=5):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.speed = speed
        self.rect = pygame.Rect(x, y, width, height)
        
        # Параметры для плавного движения
        self.target_dx = 0
        self.target_dy = 0
        self.current_dx = 0
        self.current_dy = 0
        self.acceleration = 0.5  # Ускорение
        self.deceleration = 0.3  # Замедление
        
        # Анимация
        self.anim_frame = 0
        self.anim_speed = 0.15
        self.is_moving = False
        self.direction = 0  # 0 = вниз, 1 = вверх, 2 = влево, 3 = вправо
        
        # Эффекты свечения
        self.glow_intensity = 1.0
        self.glow_pulse = 0
        self.glow_speed = 0.08
        
        # След (trail effect)
        self.trail = []  # Список предыдущих позиций
        self.max_trail_length = 10
        
        # Визуальные параметры
        self.base_color = (50, 120, 220)  # Основной цвет - синий
        self.glow_color = (100, 180, 255)  # Цвет свечения
        self.trail_color = (80, 140, 200)  # Цвет следа
        
    def move(self, dx=0, dy=0):
        """Перемещение игрока"""
        # Сохраняем предыдущую позицию для следа
        if dx != 0 or dy != 0:
            self.trail.append((self.x, self.y))
            if len(self.trail) > self.max_trail_length:
                self.trail.pop(0)
                
        self.x += dx
        self.y += dy
        self.rect.x = int(self.x)  # Конвертируем в int для pygame.Rect
        self.rect.y = int(self.y)
        self.is_moving = (dx != 0 or dy != 0)
        
        # Определяем направление движения
        if dy > 0:
            self.direction = 0
        elif dy < 0:
            self.direction = 1
        elif dx < 0:
            self.direction = 2
        elif dx > 0:
            self.direction = 3
        
    def move_left(self):
        self.move(dx=-self.speed)
        
    def move_right(self):
        self.move(dx=self.speed)
        
    def move_up(self):
        self.move(dy=-self.speed)
        
    def move_down(self):
        self.move(dy=self.speed)
        
    def update(self, keys_pressed):
        """Обновление позиции игрока в зависимости от нажатых клавиш"""
        # Определяем целевое направление
        target_dx, target_dy = 0, 0
        
        if keys_pressed[pygame.K_LEFT] or keys_pressed[pygame.K_a]:
            target_dx = -self.speed
        if keys_pressed[pygame.K_RIGHT] or keys_pressed[pygame.K_d]:
            target_dx = self.speed
        if keys_pressed[pygame.K_UP] or keys_pressed[pygame.K_w]:
            target_dy = -self.speed
        if keys_pressed[pygame.K_DOWN] or keys_pressed[pygame.K_s]:
            target_dy = self.speed
            
        # Плавное изменение скорости к целевому значению
        if self.target_dx != target_dx or self.target_dy != target_dy:
            self.target_dx = target_dx
            self.target_dy = target_dy
            
        # Обновляем текущую скорость с учетом ускорения/замедления
        if self.current_dx != self.target_dx:
            if abs(self.current_dx - self.target_dx) < self.acceleration:
                self.current_dx = self.target_dx
            elif self.current_dx < self.target_dx:
                self.current_dx += self.acceleration
            else:
                self.current_dx -= self.acceleration
                
        if self.current_dy != self.target_dy:
            if abs(self.current_dy - self.target_dy) < self.acceleration:
                self.current_dy = self.target_dy
            elif self.current_dy < self.target_dy:
                self.current_dy += self.acceleration
            else:
                self.current_dy -= self.acceleration
                
        # Если обе команды равны нулю, применяем замедление
        if self.target_dx == 0 and abs(self.current_dx) > 0:
            if self.current_dx > 0:
                self.current_dx = max(0, self.current_dx - self.deceleration)
            else:
                self.current_dx = min(0, self.current_dx + self.deceleration)
                
        if self.target_dy == 0 and abs(self.current_dy) > 0:
            if self.current_dy > 0:
                self.current_dy = max(0, self.current_dy - self.deceleration)
            else:
                self.current_dy = min(0, self.current_dy + self.deceleration)
        
        # Применяем движение
        if abs(self.current_dx) > 0.1 or abs(self.current_dy) > 0.1:  # Порог для маленькой величины
            self.move(dx=self.current_dx, dy=self.current_dy)
            self.is_moving = True
        else:
            self.is_moving = False
            self.current_dx = 0
            self.current_dy = 0
            
        # Обновление анимации
        if self.is_moving:
            self.anim_frame += self.anim_speed
        else:
            # Плавное возвращение в исходное состояние
            self.anim_frame = 0
            
        # Обновление свечения
        self.glow_pulse += self.glow_speed
        if self.glow_pulse > 2 * math.pi:
            self.glow_pulse -= 2 * math.pi
            
    def get_glow_intensity(self):
        """Получение интенсивности свечения с пульсацией"""
        base = 0.7
        pulse = 0.3 * math.sin(self.glow_pulse)
        return base + pulse
        
    def draw(self, screen):
        """Отрисовка игрока со всеми эффектами"""
        
        # 1. Рисуем след (trail)
        for i, (tx, ty) in enumerate(self.trail):
            alpha = int(100 * (i / len(self.trail))) if self.trail else 0
            if alpha > 0:
                trail_rect = pygame.Rect(tx, ty, self.width, self.height)
                # Создаем полупрозрачную поверхность для следа
                trail_surf = pygame.Surface((self.width, self.height), pygame.SRCALPHA)
                pygame.draw.rect(trail_surf, (*self.trail_color, alpha), 
                                (0, 0, self.width, self.height))
                screen.blit(trail_surf, (tx, ty))
        
        # 2. Рисуем внешнее свечение (несколько слоев)
        glow_intensity = self.get_glow_intensity()
        center_x = self.x + self.width // 2
        center_y = self.y + self.height // 2
        
        # Внешнее размытое свечение
        glow_radius = int(max(self.width, self.height) * 1.5 * glow_intensity)
        
        # Рисуем несколько слоев свечения
        for layer in range(3):
            layer_alpha = int(25 * glow_intensity / (layer + 1))
            layer_size = self.width + glow_radius * (layer + 1) // 2
            
            glow_surf = pygame.Surface((layer_size * 2, layer_size * 2), pygame.SRCALPHA)
            pygame.draw.circle(glow_surf, (*self.glow_color, layer_alpha), 
                             (layer_size, layer_size), layer_size // 2)
            
            # Масштабируем для более плавного свечения
            glow_surf = pygame.transform.scale(glow_surf, 
                                               (layer_size * 2, layer_size * 2))
            screen.blit(glow_surf, (center_x - layer_size, center_y - layer_size),
                       special_flags=pygame.BLEND_ADD)
        
        # 3. Рисуем основное тело игрока с градиентом
        # Создаем градиентную заливку
        body_surf = pygame.Surface((self.width, self.height))
        
        # Верхняя часть - светлее
        top_color = tuple(min(255, c + 40) for c in self.base_color)
        # Нижняя часть - темнее  
        bottom_color = tuple(max(0, c - 20) for c in self.base_color)
        
        for y in range(self.height):
            t = y / self.height
            r = int(bottom_color[0] + (top_color[0] - bottom_color[0]) * t)
            g = int(bottom_color[1] + (top_color[1] - bottom_color[1]) * t)
            b = int(bottom_color[2] + (top_color[2] - bottom_color[2]) * t)
            pygame.draw.line(body_surf, (r, g, b), (0, y), (self.width - 1, y))
            
        screen.blit(body_surf, (self.x, self.y))
        
        # 4. Рисуем блик (highlight)
        highlight_rect = pygame.Rect(
            self.x + self.width // 4,
            self.y + self.height // 4,
            self.width // 3,
            self.height // 3
        )
        pygame.draw.rect(screen, (150, 200, 255), highlight_rect)
        
        # 5. Рисуем обводку (outline)
        outline_rect = pygame.Rect(self.x, self.y, self.width, self.height)
        pygame.draw.rect(screen, self.glow_color, outline_rect, 2)
        
        # 6. Рисуем "глаза" в зависимости от направления
        eye_color = (255, 255, 255)
        eye_size = 4
        
        if self.direction == 0:  # Вниз
            left_eye = (self.x + self.width // 3, self.y + self.height // 2)
            right_eye = (self.x + 2 * self.width // 3, self.y + self.height // 2)
        elif self.direction == 1:  # Вверх
            left_eye = (self.x + self.width // 3, self.y + self.height // 3)
            right_eye = (self.x + 2 * self.width // 3, self.y + self.height // 3)
        elif self.direction == 2:  # Влево
            left_eye = (self.x + self.width // 4, self.y + self.height // 2)
            right_eye = (self.x + self.width // 2, self.y + self.height // 2)
        else:  # Вправо
            left_eye = (self.x + self.width // 2, self.y + self.height // 2)
            right_eye = (self.x + 3 * self.width // 4, self.y + self.height // 2)
            
        pygame.draw.circle(screen, eye_color, left_eye, eye_size)
        pygame.draw.circle(screen, eye_color, right_eye, eye_size)
        
    def get_position(self):
        """Возвращает текущую позицию игрока"""
        return (self.x, self.y)
        
    def set_position(self, x, y):
        """Устанавливает позицию игрока"""
        self.x = x
        self.y = y
        self.rect.x = x
        self.rect.y = y
        # Очищаем след при телепортации
        self.trail = []
