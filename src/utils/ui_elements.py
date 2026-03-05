"""
Красивые UI элементы для улучшения интерфейса
"""
import pygame
import math


class ModernButton:
    """Современная кнопка с эффектами"""
    
    def __init__(self, x, y, width, height, text, color=(100, 150, 200)):
        self.rect = pygame.Rect(x, y, width, height)
        self.text = text
        self.color = color
        self.hover = False
        self.pressed = False
        self.hover_scale = 0
        self.glow_alpha = 0
        
        self.font = pygame.font.SysFont('arial', 20, bold=True)
        
    def update(self, mouse_pos):
        """Обновление состояния кнопки"""
        self.hover = self.rect.collidepoint(mouse_pos)
        
        # Анимация наведения
        if self.hover:
            self.hover_scale = min(self.hover_scale + 0.1, 1.0)
            self.glow_alpha = min(self.glow_alpha + 15, 100)
        else:
            self.hover_scale = max(self.hover_scale - 0.1, 0)
            self.glow_alpha = max(self.glow_alpha - 15, 0)
            
    def draw(self, screen):
        """Отрисовка кнопки"""
        # Свечение при наведении
        if self.glow_alpha > 0:
            glow_rect = self.rect.inflate(20, 20)
            glow_surf = pygame.Surface((glow_rect.width, glow_rect.height), pygame.SRCALPHA)
            pygame.draw.rect(glow_surf, (*self.color, self.glow_alpha), 
                           (0, 0, glow_rect.width, glow_rect.height), border_radius=15)
            screen.blit(glow_surf, glow_rect.topleft)
        
        # Основная кнопка
        scale = 1.0 + 0.05 * self.hover_scale
        scaled_rect = self.rect.inflate(
            int(self.rect.width * (scale - 1)),
            int(self.rect.height * (scale - 1))
        )
        
        # Градиент
        button_surf = pygame.Surface((scaled_rect.width, scaled_rect.height), pygame.SRCALPHA)
        
        for i in range(scaled_rect.height):
            t = i / scaled_rect.height
            r = int(self.color[0] * (1 - t * 0.3))
            g = int(self.color[1] * (1 - t * 0.3))
            b = int(self.color[2] * (1 - t * 0.3))
            pygame.draw.line(button_surf, (r, g, b), (0, i), (scaled_rect.width, i))
        
        # Рамка
        pygame.draw.rect(button_surf, (255, 255, 255), 
                        (0, 0, scaled_rect.width, scaled_rect.height), 3, border_radius=10)
        
        screen.blit(button_surf, scaled_rect.topleft)
        
        # Текст
        text_surf = self.font.render(self.text, True, (255, 255, 255))
        text_rect = text_surf.get_rect(center=scaled_rect.center)
        screen.blit(text_surf, text_rect)
        
    def is_clicked(self, event):
        """Проверка клика"""
        if event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
            return self.hover
        return False


class ProgressBar:
    """Красивая полоска прогресса"""
    
    def __init__(self, x, y, width, height, max_value=100):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.max_value = max_value
        self.current_value = max_value
        self.target_value = max_value
        
    def set_value(self, value):
        """Установить значение"""
        self.target_value = max(0, min(value, self.max_value))
        
    def update(self):
        """Плавное изменение значения"""
        if self.current_value < self.target_value:
            self.current_value += (self.target_value - self.current_value) * 0.1
        elif self.current_value > self.target_value:
            self.current_value -= (self.current_value - self.target_value) * 0.1
            
    def draw(self, screen):
        """Отрисовка"""
        # Фон
        pygame.draw.rect(screen, (50, 50, 50), 
                        (self.x, self.y, self.width, self.height), border_radius=5)
        
        # Прогресс
        progress_width = int((self.current_value / self.max_value) * self.width)
        if progress_width > 0:
            # Градиент от зелёного к красному
            t = self.current_value / self.max_value
            r = int(255 * (1 - t))
            g = int(255 * t)
            
            pygame.draw.rect(screen, (r, g, 50), 
                           (self.x, self.y, progress_width, self.height), border_radius=5)
        
        # Рамка
        pygame.draw.rect(screen, (200, 200, 200), 
                        (self.x, self.y, self.width, self.height), 2, border_radius=5)
        
        # Текст
        font = pygame.font.SysFont('arial', 14, bold=True)
        text = f"{int(self.current_value)}/{self.max_value}"
        text_surf = font.render(text, True, (255, 255, 255))
        text_rect = text_surf.get_rect(center=(self.x + self.width // 2, self.y + self.height // 2))
        screen.blit(text_surf, text_rect)


class Notification:
    """Всплывающее уведомление"""
    
    def __init__(self, text, x, y, duration=120):
        self.text = text
        self.x = x
        self.y = y
        self.start_y = y
        self.duration = duration
        self.timer = 0
        self.alpha = 255
        
        self.font = pygame.font.SysFont('arial', 18, bold=True)
        
    def update(self):
        """Обновление анимации"""
        self.timer += 1
        
        # Движение вверх
        self.y = self.start_y - (self.timer * 0.5)
        
        # Затухание
        if self.timer > self.duration - 30:
            self.alpha = max(0, 255 - (self.timer - (self.duration - 30)) * 8)
            
    def draw(self, screen):
        """Отрисовка"""
        if self.alpha > 0:
            # Фон
            text_surf = self.font.render(self.text, True, (255, 255, 255))
            text_rect = text_surf.get_rect(center=(self.x, int(self.y)))
            
            bg_rect = text_rect.inflate(20, 10)
            bg_surf = pygame.Surface((bg_rect.width, bg_rect.height), pygame.SRCALPHA)
            pygame.draw.rect(bg_surf, (50, 50, 50, min(200, self.alpha)), 
                           (0, 0, bg_rect.width, bg_rect.height), border_radius=10)
            pygame.draw.rect(bg_surf, (255, 215, 0, self.alpha), 
                           (0, 0, bg_rect.width, bg_rect.height), 2, border_radius=10)
            
            screen.blit(bg_surf, bg_rect.topleft)
            
            # Текст
            text_surf.set_alpha(self.alpha)
            screen.blit(text_surf, text_rect)
            
    def is_finished(self):
        """Проверка завершения"""
        return self.timer >= self.duration


class Tooltip:
    """Всплывающая подсказка"""
    
    def __init__(self):
        self.text = ""
        self.visible = False
        self.x = 0
        self.y = 0
        self.font = pygame.font.SysFont('arial', 14)
        
    def show(self, text, x, y):
        """Показать подсказку"""
        self.text = text
        self.x = x
        self.y = y
        self.visible = True
        
    def hide(self):
        """Скрыть подсказку"""
        self.visible = False
        
    def draw(self, screen):
        """Отрисовка"""
        if not self.visible or not self.text:
            return
            
        # Текст
        text_surf = self.font.render(self.text, True, (255, 255, 255))
        text_rect = text_surf.get_rect()
        text_rect.topleft = (self.x + 10, self.y + 10)
        
        # Фон
        bg_rect = text_rect.inflate(10, 6)
        pygame.draw.rect(screen, (40, 40, 40, 230), bg_rect, border_radius=5)
        pygame.draw.rect(screen, (200, 200, 200), bg_rect, 1, border_radius=5)
        
        screen.blit(text_surf, text_rect)


class IconButton:
    """Кнопка с иконкой"""
    
    def __init__(self, x, y, size, icon_text, color=(100, 100, 150)):
        self.rect = pygame.Rect(x, y, size, size)
        self.icon_text = icon_text
        self.color = color
        self.hover = False
        self.pulse = 0
        
        self.font = pygame.font.SysFont('arial', int(size * 0.6), bold=True)
        
    def update(self, mouse_pos):
        """Обновление"""
        self.hover = self.rect.collidepoint(mouse_pos)
        self.pulse += 0.1
        
    def draw(self, screen):
        """Отрисовка"""
        # Пульсация при наведении
        if self.hover:
            scale = 1.0 + 0.1 * math.sin(self.pulse * 5)
            size = int(self.rect.width * scale)
            rect = pygame.Rect(0, 0, size, size)
            rect.center = self.rect.center
        else:
            rect = self.rect
            
        # Круг
        pygame.draw.circle(screen, self.color, rect.center, rect.width // 2)
        pygame.draw.circle(screen, (255, 255, 255), rect.center, rect.width // 2, 2)
        
        # Иконка
        icon_surf = self.font.render(self.icon_text, True, (255, 255, 255))
        icon_rect = icon_surf.get_rect(center=rect.center)
        screen.blit(icon_surf, icon_rect)
        
    def is_clicked(self, event):
        """Проверка клика"""
        if event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
            return self.hover
        return False
