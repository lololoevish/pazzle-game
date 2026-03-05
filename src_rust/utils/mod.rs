// Утилиты для игры

use macroquad::prelude::*;

/// Рисует градиентный прямоугольник
pub fn draw_gradient_rect(x: f32, y: f32, width: f32, height: f32, color1: Color, color2: Color) {
    for i in 0..(height as i32) {
        let t = i as f32 / height;
        let color = Color::new(
            color1.r + (color2.r - color1.r) * t,
            color1.g + (color2.g - color1.g) * t,
            color1.b + (color2.b - color1.b) * t,
            color1.a + (color2.a - color1.a) * t,
        );
        draw_line(x, y + i as f32, x + width, y + i as f32, 1.0, color);
    }
}

/// Рисует текст с тенью
pub fn draw_text_with_shadow(text: &str, x: f32, y: f32, size: f32, color: Color, shadow_color: Color) {
    draw_text(text, x + 2.0, y + 2.0, size, shadow_color);
    draw_text(text, x, y, size, color);
}

/// Проверяет столкновение двух прямоугольников
pub fn check_collision(x1: f32, y1: f32, w1: f32, h1: f32, x2: f32, y2: f32, w2: f32, h2: f32) -> bool {
    x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2
}
