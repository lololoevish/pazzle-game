
import matplotlib.pyplot as plt
import numpy as np

def draw_hatching_triangle(vertices, step=5):
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
if abs(y_b - y_a) > epsilon: # Избегаем деления на нол
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
x_end = intersections[i + 1]
# Добавляем линию только если она имеет длину
if x_end > x_start:
hatching_lines.append(([x_start, x_end], [y, y]))

y += step
# Визуализация
fig, ax = plt.subplots(1, 1, figsize=(8, 8))

# Рисуем контур треугольника
triangle_x = [x1, x2, x3, x1]
triangle_y = [y1, y2, y3, y1]

ax.plot(triangle_x, triangle_y, 'b-', linewidth=2, label='Контур')

# Рисуем штриховку
for x_coords, y_coords in hatching_lines:
ax.plot(x_coords, y_coords, 'r-', linewidth=1, alpha=0.6)

ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.set_title('Штриховка треугольника')
ax.legend()
ax.set_xlabel('X')
ax.set_ylabel('Y')
plt.show()

# Пример использования
triangle = [(50, 20), (20, 80), (80, 80)]
draw_hatching_triangle(triangle, step=3)


