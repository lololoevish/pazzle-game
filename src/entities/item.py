import pygame
import math
import random

class Item:
    def __init__(self, x, y, width, height, name="", description=""):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.name = name
        self.description = description
        self.rect = pygame.Rect(x, y, width, height)
        self.visible = True
        
        # Визуальные эффекты
        self.anim_frame = 0
        self.anim_speed = 0.08
        
        # Свечение
        self.glow_intensity = 1.0
        self.glow_pulse = random.uniform(0, math.pi * 2)  # Случайный начальный сдвиг
        self.glow_speed = 0.05
        
        # Цвета (разные для разных типов предметов)
        if "Ключ" in name:
            self.base_color = (255, 215, 0)  # Золотой
            self.glow_color = (255, 255, 150)  # Желтое свечение
        elif "Сундук" in name:
            self.base_color = (139, 69, 19)  # Коричневый
            self.glow_color = (255, 200, 100)  # Теплое свечение
        elif "Предмет" in name:
            self.base_color = (147, 112, 219)  # Фиолетовый
            self.glow_color = (200, 150, 255)  # Сиреневое свечение
        else:
            self.base_color = (255, 215, 0)  # Золотой по умолчанию
            self.glow_color = (255, 255, 150)
            
        # Искры (sparkles)
        self.sparkles = []
        self.sparkle_timer = 0
        self.sparkle_interval = 15
        
    def update(self):
        """Обновление анимации предмета"""
        if self.visible:
            self.anim_frame += self.anim_speed
            if self.anim_frame > 2 * math.pi:
                self.anim_frame -= 2 * math.pi
                
            self.glow_pulse += self.glow_speed
            if self.glow_pulse > 2 * math.pi:
                self.glow_pulse -= 2 * math.pi
                
            # Обновление искр
            self.sparkle_timer += 1
            if self.sparkle_timer >= self.sparkle_interval:
                self.sparkle_timer = 0
                # Добавляем новую искру
                if random.random() < 0.7:  # 70% шанс
                    sparkle = {
                        'x': self.x + random.randint(0, self.width),
                        'y': self.y + random.randint(0, self.height),
                        'life': 20,
                        'max_life': 20,
                        'size': random.randint(1, 3)
                    }
                    self.sparkles.append(sparkle)
                    
            # Обновляем существующие искры
            for sparkle in self.sparkles[:]:
                sparkle['y'] -= 0.3  # Искры поднимаются вверх
                sparkle['life'] -= 1
                if sparkle['life'] <= 0:
                    self.sparkles.remove(sparkle)
                    
    def get_glow_intensity(self):
        """Получение интенсивности свечения с пульсацией"""
        return 0.6 + 0.4 * math.sin(self.glow_pulse)
        
    def draw(self, screen):
        """Отрисовка предмета на экране со всеми эффектами"""
        if not self.visible:
            return
            
        center_x = self.x + self.width // 2
        center_y = self.y + self.height // 2
        
        # 1. Рисуем свечение (несколько слоев)
        glow_intensity = self.get_glow_intensity()
        glow_radius = int(max(self.width, self.height) * 1.2)
        
        for layer in range(3):
            layer_alpha = int(30 * glow_intensity / (layer + 1))
            layer_size = glow_radius + layer * 8
            
            glow_surf = pygame.Surface((layer_size * 2, layer_size * 2), pygame.SRCALPHA)
            pygame.draw.circle(glow_surf, (*self.glow_color, layer_alpha), 
                             (layer_size, layer_size), layer_size // 2)
            screen.blit(glow_surf, (center_x - layer_size, center_y - layer_size),
                       special_flags=pygame.BLEND_ADD)
        
        # 2. Рисуем основную форму предмета с градиентом
        body_surf = pygame.Surface((self.width, self.height))
        
        # Вертикальный градиент
        for y in range(self.height):
            t = y / self.height
            r = int(max(0, min(255, self.base_color[0] + 30 * (1 - t))))
            g = int(max(0, min(255, self.base_color[1] + 30 * (1 - t))))
            b = int(max(0, min(255, self.base_color[2] + 30 * (1 - t))))
            pygame.draw.line(body_surf, (r, g, b), (0, y), (self.width - 1, y))
            
        screen.blit(body_surf, (self.x, self.y))
        
        # 3. Рисуем блик
        highlight_rect = pygame.Rect(
            self.x + self.width // 4,
            self.y + self.height // 4,
            self.width // 3,
            self.height // 3
        )
        highlight_color = tuple(min(255, c + 80) for c in self.base_color)
        pygame.draw.rect(screen, highlight_color, highlight_rect)
        
        # 4. Рисуем обводку
        outline_rect = pygame.Rect(self.x, self.y, self.width, self.height)
        pygame.draw.rect(screen, self.glow_color, outline_rect, 2)
        
        # 5. Рисуем искры
        for sparkle in self.sparkles:
            alpha = int(255 * (sparkle['life'] / sparkle['max_life']))
            sparkle_surf = pygame.Surface((sparkle['size'] * 2, sparkle['size'] * 2), pygame.SRCALPHA)
            pygame.draw.circle(sparkle_surf, (255, 255, 200, alpha), 
                             (sparkle['size'], sparkle['size']), sparkle['size'])
            screen.blit(sparkle_surf, (sparkle['x'] - sparkle['size'], 
                                       sparkle['y'] - sparkle['size']))
            
        # 6. Добавляем пульсацию размера
        pulse = math.sin(self.anim_frame) * 2
        if pulse > 0:
            pulse_rect = pygame.Rect(
                self.x - pulse // 2,
                self.y - pulse // 2,
                self.width + pulse,
                self.height + pulse
            )
            # Пунктирная обводка
            pygame.draw.rect(screen, self.glow_color, pulse_rect, 1, border_radius=3)
            
    def interact(self, player):
        """Метод взаимодействия с игроком"""
        print(f"Игрок взаимодействует с предметом: {self.name}")
        return False  # Возвращаем False, если взаимодействие не завершено
        
    def get_position(self):
        """Возвращает текущую позицию предмета"""
        return (self.x, self.y)
        
    def is_colliding_with(self, other_rect):
        """Проверяет столкновение с другим прямоугольником"""
        return self.rect.colliderect(other_rect)
        
    def hide(self):
        """Скрывает предмет"""
        self.visible = False
        self.sparkles = []  # Очищаем искры при скрытии
        
    def show(self):
        """Показывает предмет"""
        self.visible = True
