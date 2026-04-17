
import matplotlib.pyplot as plt
import numpy as np

def draw_hatching_triangle(vertices, step=5):
    """
    Штриховка треугольника горизонтальными линиями
    
    Parameters:
    -----------
    vertices: список кортежей [(x1,y1), (x2,y2), (x3,y3)]
    step: шаг между линиями штриховки
    """
    # Разбираем вершины
    (x1, y1), (x2, y2), (x3, y3) = vertices
    
    # Находим границы по Y (без приведения к int)
    y_min = min(y1, y2, y3)
    y_max = max(y1, y2, y3)
    
    # Список для хранения точек пересечения
    hatching_lines = []
    
    # Проходим по каждой горизонтальной линии
    y = y_min
    while y <= y_max:
        intersections = []
        
        # Проверяем пересечение с каждой стороной треугольника
        sides = [(x1, y1, x2, y2), (x2, y2, x3, y3), (x3, y3, x1, y1)]
        
        for x_a, y_a, x_b, y_b in sides:
            # Проверяем, пересекает ли горизонтальная линия y сторону
            # Используем epsilon для сравнения float
            epsilon = 1e-10
            y_start = min(y_a, y_b)
            y_end = max(y_a, y_b)
            
            if y_start - epsilon <= y <= y_end + epsilon:
                if abs(y_b - y_a) > epsilon:  # Избегаем деления на ноль
                    # Находим x точки пересечения
                    t = (y - y_a) / (y_b - y_a)
                    x = x_a + t * (x_b - x_a)
                    intersections.append(x)
        
        # Сортируем пересечения
        intersections = sorted(intersections)
        
        # Рисуем линии между парами точек
        for i in range(0, len(intersections) - 1, 2):
            if i + 1 < len(intersections):
                x_start = intersections[i]