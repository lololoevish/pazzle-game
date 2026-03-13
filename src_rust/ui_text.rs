use std::sync::OnceLock;

use macroquad::prelude::*;

static UI_FONT: OnceLock<Font> = OnceLock::new();

pub async fn init() {
    let candidates = [
        "assets/fonts/arial.ttf",
        "assets/fonts/segoeui.ttf",
        "C:/Windows/Fonts/arial.ttf",
        "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/tahoma.ttf",
    ];

    for path in candidates {
        if let Ok(font) = load_ttf_font(path).await {
            let _ = UI_FONT.set(font);
            return;
        }
    }
}

pub fn draw_game_text(text: &str, x: f32, y: f32, font_size: f32, color: Color) {
    if let Some(font) = UI_FONT.get() {
        draw_text_ex(
            text,
            x,
            y,
            TextParams {
                font: Some(font),
                font_size: font_size.round().max(1.0) as u16,
                font_scale: 1.0,
                font_scale_aspect: 1.0,
                rotation: 0.0,
                color,
            },
        );
    } else {
        draw_text(text, x, y, font_size, color);
    }
}

pub fn measure_game_text(
    text: &str,
    _font: Option<&Font>,
    font_size: u16,
    font_scale: f32,
) -> TextDimensions {
    macroquad::text::measure_text(text, UI_FONT.get(), font_size, font_scale)
}

pub fn draw_wrapped_game_text(
    text: &str,
    x: f32,
    mut y: f32,
    max_width: f32,
    font_size: f32,
    line_gap: f32,
    color: Color,
) {
    for line in wrap_text(text, max_width, font_size) {
        draw_game_text(&line, x, y, font_size, color);
        y += font_size + line_gap;
    }
}

pub fn wrap_text(text: &str, max_width: f32, font_size: f32) -> Vec<String> {
    let mut lines = Vec::new();
    let mut current_line = String::new();

    for word in text.split_whitespace() {
        let candidate = if current_line.is_empty() {
            word.to_string()
        } else {
            format!("{current_line} {word}")
        };

        let width = measure_game_text(&candidate, None, font_size.round() as u16, 1.0).width;
        if width <= max_width || current_line.is_empty() {
            current_line = candidate;
        } else {
            lines.push(current_line);
            current_line = word.to_string();
        }
    }

    if !current_line.is_empty() {
        lines.push(current_line);
    }

    lines
}
