import matplotlib.pyplot as plt
import numpy as np
import math

def rotate_point(x, y, angle_deg, cx=0, cy=0):
    """Поворачивает точку (x,y) вокруг (cx,cy) на angle_deg градусов"""
    angle_rad = math.radians(angle_deg)
    x_new = cx + (x - cx) * math.cos(angle_rad) - (y - cy) * math.sin(angle_rad)
    y_new = cy + (x - cx) * math.sin(angle_rad) + (y - cy) * math.cos(angle_rad)
    return x_new, y_new

def polygon_hatching(vertices, angle=0, step=5):
    """Универсальная штриховка многоугольника"""
    n = len(vertices)
    if n < 3:
        print("Многоугольник должен иметь минимум 3 вершины")
        return 0

    cx = sum(v[0] for v in vertices) / n
    cy = sum(v[1] for v in vertices) / n

    rotated_vertices = []
    for x, y in vertices:
        rx, ry = rotate_point(x, y, -angle, cx, cy)
        rotated_vertices.append((rx, ry))
    
    xs = [v[0] for v in rotated_vertices]
    ys = [v[1] for v in rotated_vertices]
    y_min, y_max = min(ys), max(ys)

    hatching_lines = []
    epsilon = 1e-9
    
    y = y_min
    while y <= y_max + epsilon:
        intersections = []

        for i in range(n):
            x1, y1 = rotated_vertices[i]
            x2, y2 = rotated_vertices[(i + 1) % n]

            y_start = min(y1, y2)
            y_end = max(y1, y2)
            
            if y_start - epsilon <= y <= y_end + epsilon:
                if abs(y2 - y1) < epsilon:
                    if abs(y - y1) < epsilon:
                        intersections.append(min(x1, x2))
                        intersections.append(max(x1, x2))
                else:
                    t = (y - y1) / (y2 - y1)
                    x = x1 + t * (x2 - x1)
                    intersections.append(x)

        intersections = sorted(intersections)

        if len(intersections) > 1:
            unique_intersections = [intersections[0]]
            for x in intersections[1:]:
                if x - unique_intersections[-1] > epsilon:
                    unique_intersections.append(x)
            intersections = unique_intersections

        i = 0
        while i < len(intersections) - 1:
            x1_rot, y1_rot = intersections[i], y
            x2_rot, y2_rot = intersections[i + 1], y

            if x2_rot - x1_rot > epsilon:
                x1_orig, y1_orig = rotate_point(x1_rot, y1_rot, angle, cx, cy)
                x2_orig, y2_orig = rotate_point(x2_rot, y2_rot, angle, cx, cy)
                hatching_lines.append(([x1_orig, x2_orig], [y1_orig, y2_orig]))

            i += 2

        y += step

    fig, ax = plt.subplots(1, 1, figsize=(10, 10))

    poly_x = [v[0] for v in vertices] + [vertices[0][0]]
    poly_y = [v[1] for v in vertices] + [vertices[0][1]]
    ax.plot(poly_x, poly_y, 'b-', linewidth=2, label='Контур')

    for x_coords, y_coords in hatching_lines:
        ax.plot(x_coords, y_coords, 'r-', linewidth=0.8, alpha=0.7)

    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_title(f'Штриховка многоугольника (угол {angle}°)')
    ax.legend()
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    plt.show()

    return len(hatching_lines)

# ============================================
# Пример 3: Пятиконечная звезда
# ============================================
star = []
for i in range(10):
    angle = i * 36
    r = 50 if i % 2 == 0 else 25
    x = 50 + r * math.cos(math.radians(angle - 90))
    y = 50 + r * math.sin(math.radians(angle - 90))
    star.append((x, y))

print("\n⭐ Звезда, вертикальная штриховка:")
count3 = polygon_hatching(star, angle=90, step=3)
print(f"Количество линий: {count3}")

# ============================================
# Пример 4: Треугольник для проверки
# ============================================
triangle = [(50, 20), (20, 80), (80, 80)]
print("\n🔺 Треугольник, горизонтальная штриховка:")
count4 = polygon_hatching(triangle, angle=0, step=5)
print(f"Количество линий: {count4}")