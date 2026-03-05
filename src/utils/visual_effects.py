import pygame
import random
import math

class Particle:
    """Класс для эффекта частиц"""
    def __init__(self, x, y, color, velocity_x=0, velocity_y=0, lifetime=30, size=4):
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
        """Обновление состояния частицы"""
        self.x += self.velocity_x
        self.y += self.velocity_y
        self.lifetime -= 1
        if self.lifetime <= 0:
            self.alive = False
            return
        
        # Замедление со временем
        self.velocity_x *= 0.98
        self.velocity_y *= 0.98
        
    def draw(self, screen):
        """Отрисовка частицы с эффектом затухания"""
        if self.alive and self.lifetime > 0:
            alpha = int(255 * (self.lifetime / self.max_lifetime))
            # Создаем поверхность с альфа-каналом для полупрозрачности
            surf = pygame.Surface((self.size * 2, self.size * 2), pygame.SRCALPHA)
            
            # Рисуем круг с градиентом прозрачности
            pygame.draw.circle(surf, (*self.color, alpha), (self.size, self.size), self.size)
            screen.blit(surf, (int(self.x - self.size), int(self.y - self.size)))


class ParticleSystem:
    """Система управления частицами"""
    def __init__(self):
        self.particles = []
        
    def emit(self, x, y, color, count=20, spread=3, lifetime=40):
        """Испускание частиц из точки"""
        for _ in range(count):
            angle = random.uniform(0, 2 * math.pi)
            speed = random.uniform(1, spread)
            vx = math.cos(angle) * speed
            vy = math.sin(angle) * speed
            size = random.randint(2, 5)
            particle = Particle(x, y, color, vx, vy, lifetime + random.randint(-10, 10), size)
            self.particles.append(particle)
            
    def update(self):
        """Обновление всех частиц"""
        for particle in self.particles:
            particle.update()
        # Удаляем мертвые частицы
        self.particles = [p for p in self.particles if p.alive]
        
    def draw(self, screen):
        """Отрисовка всех частиц"""
        for particle in self.particles:
            particle.draw(screen)
            
    def clear(self):
        """Очистка всех частиц"""
        self.particles = []


class GlowEffect:
    """Эффект свечения вокруг объекта"""
    def __init__(self, color, intensity=1.0):
        self.color = color
        self.intensity = intensity
        self.pulse = 0
        self.pulse_speed = 0.05
        
    def update(self):
        """Обновление пульсации"""
        self.pulse += self.pulse_speed
        if self.pulse > 2 * math.pi:
            self.pulse -= 2 * math.pi
            
    def get_current_intensity(self):
        """Получение текущей интенсивности с пульсацией"""
        return self.intensity * (0.7 + 0.3 * math.sin(self.pulse))
    
    def draw_around_rect(self, screen, rect, glow_size=15):
        """Отрисовка свечения вокруг прямоугольника"""
        if not hasattr(self, 'cache'):
            self.cache = {}
            
        intensity = self.get_current_intensity()
        
        # Рисуем несколько слоев свечения
        for layer in range(3):
            layer_size = glow_size * (1 + layer * 0.5)
            alpha = int(40 * intensity / (layer + 1))
            
            # Создаем поверхность для свечения
            glow_rect = pygame.Rect(
                rect.x - layer_size,
                rect.y - layer_size,
                rect.width + layer_size * 2,
                rect.height + layer_size * 2
            )
            
            surf = pygame.Surface((glow_rect.width, glow_rect.height), pygame.SRCALPHA)
            
            # Рисуем размытый круг (имитация свечения)
            center = (glow_rect.width // 2, glow_rect.height // 2)
            radius = min(glow_rect.width, glow_rect.height) // 2
            
            pygame.draw.circle(surf, (*self.color, alpha), center, radius)
            screen.blit(surf, (glow_rect.x, glow_rect.y))


class GradientBackground:
    """Класс для создания градиентного фона"""
    def __init__(self, width, height, colors):
        """
        width, height - размеры экрана
        colors - список цветов для градиента [(r,g,b), ...]
        """
        self.width = width
        self.height = height
        self.colors = colors
        self.surface = self.create_gradient()
        
    def create_gradient(self):
        """Создание поверхности с градиентом"""
        surface = pygame.Surface((self.width, self.height))
        
        if len(self.colors) < 2:
            surface.fill(self.colors[0] if self.colors else (0, 0, 0))
            return surface
            
        # Создаем вертикальный градиент
        for y in range(self.height):
            # Вычисляем позицию в градиенте
            t = y / self.height
            
            # Интерполируем между цветами
            if len(self.colors) == 2:
                r = int(self.colors[0][0] + (self.colors[1][0] - self.colors[0][0]) * t)
                g = int(self.colors[0][1] + (self.colors[1][1] - self.colors[0][1]) * t)
                b = int(self.colors[0][2] + (self.colors[1][2] - self.colors[0][2]) * t)
            else:
                # Для более чем 2 цветов
                segment = t * (len(self.colors) - 1)
                i = int(segment)
                if i >= len(self.colors) - 1:
                    color = self.colors[-1]
                else:
                    local_t = segment - i
                    r = int(self.colors[i][0] + (self.colors[i+1][0] - self.colors[i][0]) * local_t)
                    g = int(self.colors[i][1] + (self.colors[i+1][1] - self.colors[i][1]) * local_t)
                    b = int(self.colors[i][2] + (self.colors[i+1][2] - self.colors[i][2]) * local_t)
                    
            pygame.draw.line(surface, (r, g, b), (0, y), (self.width, y))
            
        return surface
        
    def draw(self, screen):
        """Отрисовка фона"""
        screen.blit(self.surface, (0, 0))


class TransitionEffect:
    """Эффект перехода между состояниями"""
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.transitioning = False
        self.progress = 0
        self.duration = 30  # кадры
        self.transition_type = "fade"  # fade, slide, dissolve
        
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
        """Проверка завершения перехода"""
        return not self.transitioning
        
    def get_alpha(self):
        """Получение текущего значения альфа для затухания"""
        if not self.transitioning:
            return 255
        # Плавная кривая
        t = self.progress / self.duration
        return int(255 * (1 - t * t))  # Квадратичная функция для плавности


# Палитра цветов для игры
class ColorPalette:
    """Палитра цветов игры"""
    # Фон
    SKY_TOP = (45, 85, 145)       # Темно-синий верх
    SKY_BOTTOM = (135, 206, 235)   # Голубой низ
    GROUND = (34, 139, 34)        # Лесной зеленый
    GROUND_DARK = (0, 100, 0)      # Темно-зеленый
    
    # Игрок
    PLAYER_CORE = (50, 100, 200)   # Ядро игрока - синий
    PLAYER_GLOW = (100, 150, 255)  # Свечение - светло-синий
    PLAYER_TRAIL = (70, 130, 180)  # След - steel blue
    
    # Предметы
    ITEM_GOLD = (255, 215, 0)      # Золотой
    ITEM_GLOW = (255, 255, 150)    # Свечение предмета
    ITEM_SPECIAL = (255, 100, 100)# Особый предмет - красный
    
    # Эффекты
    PARTICLE_GOLD = (255, 215, 0)  # Золотые частицы
    PARTICLE_MAGIC = (180, 100, 255)  # Магические частицы
    PARTICLE_SPARKLE = (255, 255, 200)  # Искры
    
    # UI
    TEXT_COLOR = (255, 255, 255)  # Белый текст
    TEXT_SHADOW = (0, 0, 0)       # Тень текста
