import pygame

def draw_text(screen, text, x, y, font_size=24, color=(0, 0, 0)):
    """Отрисовка текста на экране"""
    font = pygame.font.SysFont(None, font_size)
    text_surface = font.render(text, True, color)
    screen.blit(text_surface, (x, y))

def check_collision(rect1, rect2):
    """Проверка столкновения двух прямоугольников"""
    return rect1.colliderect(rect2)

def clamp(value, min_value, max_value):
    """Ограничение значения в заданном диапазоне"""
    return max(min_value, min(value, max_value))

def distance_between_points(x1, y1, x2, y2):
    """Вычисление расстояния между двумя точками"""
    return ((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5