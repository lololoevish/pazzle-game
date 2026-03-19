use ::rand::{seq::SliceRandom, thread_rng};
use macroquad::prelude::*;

use crate::audio;
use crate::ui_text::{draw_game_text, measure_game_text};

#[derive(Clone, Copy, PartialEq, Eq)]
enum CardSymbol {
    Sun,
    Moon,
    Crystal,
    Star,
}

#[derive(Clone)]
struct Card {
    symbol: CardSymbol,
    revealed: bool,
    matched: bool,
    flip_progress: f32,
}

pub struct MemoryMatchPuzzle {
    cards: Vec<Card>,
    columns: usize,
    selected_indices: Vec<usize>,
    mismatch_timer: f32,
    attempts: u32,
    solved_flash: f32,
}

impl MemoryMatchPuzzle {
    pub fn new() -> Self {
        let mut symbols = vec![
            CardSymbol::Sun,
            CardSymbol::Sun,
            CardSymbol::Moon,
            CardSymbol::Moon,
            CardSymbol::Crystal,
            CardSymbol::Crystal,
            CardSymbol::Star,
            CardSymbol::Star,
        ];
        symbols.shuffle(&mut thread_rng());

        Self {
            cards: symbols
                .into_iter()
                .map(|symbol| Card {
                    symbol,
                    revealed: false,
                    matched: false,
                    flip_progress: 0.0,
                })
                .collect(),
            columns: 4,
            selected_indices: Vec::new(),
            mismatch_timer: 0.0,
            attempts: 0,
            solved_flash: 0.0,
        }
    }

    fn grid_metrics(&self) -> (f32, f32, f32, f32) {
        let card_width = 110.0;
        let card_height = 110.0;
        let total_width = self.columns as f32 * card_width;
        let offset_x = (screen_width() - total_width) / 2.0;
        let offset_y = 140.0;
        (offset_x, offset_y, card_width, card_height)
    }

    fn card_at_position(&self, mx: f32, my: f32) -> Option<usize> {
        let (offset_x, offset_y, card_width, card_height) = self.grid_metrics();
        let rows = self.cards.len().div_ceil(self.columns);

        if mx < offset_x || my < offset_y {
            return None;
        }

        let col = ((mx - offset_x) / card_width).floor() as i32;
        let row = ((my - offset_y) / card_height).floor() as i32;

        if col < 0 || row < 0 || col >= self.columns as i32 || row >= rows as i32 {
            return None;
        }

        let index = row as usize * self.columns + col as usize;
        (index < self.cards.len()).then_some(index)
    }

    fn resolve_selected_pair(&mut self) {
        if self.selected_indices.len() != 2 {
            return;
        }

        let first = self.selected_indices[0];
        let second = self.selected_indices[1];
        self.attempts += 1;

        if self.cards[first].symbol == self.cards[second].symbol {
            self.cards[first].matched = true;
            self.cards[second].matched = true;
            self.selected_indices.clear();
            self.solved_flash = 0.25;
            audio::play_ui_success();
        } else {
            self.mismatch_timer = 0.9;
            audio::play_ui_cancel();
        }
    }

    fn draw_symbol(&self, symbol: CardSymbol, x: f32, y: f32, size: f32, pulse: f32) {
        match symbol {
            CardSymbol::Sun => {
                let color = Color::from_rgba(255, 212, 110, 255);
                for ray in 0..8 {
                    let angle = ray as f32 * 45.0 + pulse * 20.0;
                    let dir = vec2(angle.to_radians().cos(), angle.to_radians().sin());
                    let inner = vec2(x, y) + dir * (size * 0.42);
                    let outer = vec2(x, y) + dir * (size * 0.72);
                    draw_line(inner.x, inner.y, outer.x, outer.y, 3.0, color);
                }
                draw_circle(x, y, size * 0.32, color);
                draw_circle(x, y, size * 0.18, Color::from_rgba(255, 245, 200, 255));
            }
            CardSymbol::Moon => {
                draw_circle(x, y, size * 0.34, Color::from_rgba(180, 205, 255, 255));
                draw_circle(
                    x + size * 0.14,
                    y - size * 0.04,
                    size * 0.28,
                    Color::from_rgba(242, 220, 165, 255),
                );
            }
            CardSymbol::Crystal => {
                draw_poly(
                    x,
                    y - size * 0.05,
                    4,
                    size * 0.38,
                    45.0,
                    Color::from_rgba(110, 240, 255, 255),
                );
                draw_poly_lines(x, y - size * 0.05, 4, size * 0.38, 45.0, 3.0, WHITE);
                draw_line(
                    x,
                    y - size * 0.42,
                    x,
                    y + size * 0.30,
                    2.0,
                    Color::from_rgba(220, 255, 255, 255),
                );
            }
            CardSymbol::Star => {
                let mut points = Vec::with_capacity(10);
                for i in 0..10 {
                    let angle = -90.0 + i as f32 * 36.0 + pulse * 15.0;
                    let radius = if i % 2 == 0 { size * 0.38 } else { size * 0.18 };
                    points.push(vec2(
                        x + radius * angle.to_radians().cos(),
                        y + radius * angle.to_radians().sin(),
                    ));
                }
                for i in 1..points.len() - 1 {
                    draw_triangle(
                        points[0],
                        points[i],
                        points[i + 1],
                        Color::from_rgba(255, 150, 190, 255),
                    );
                }
                for i in 0..points.len() {
                    let a = points[i];
                    let b = points[(i + 1) % points.len()];
                    draw_line(a.x, a.y, b.x, b.y, 2.0, WHITE);
                }
            }
        }
    }

    pub fn handle_input(&mut self) {
        if self.mismatch_timer > 0.0 || self.selected_indices.len() >= 2 {
            return;
        }

        if is_mouse_button_pressed(MouseButton::Left) {
            let (mx, my) = mouse_position();
            if let Some(index) = self.card_at_position(mx, my) {
                let card = &self.cards[index];
                if card.matched || card.revealed {
                    return;
                }

                self.cards[index].revealed = true;
                self.selected_indices.push(index);
                audio::play_ui_confirm();

                if self.selected_indices.len() == 2 {
                    self.resolve_selected_pair();
                }
            }
        }
    }

    pub fn update(&mut self) {
        let dt = get_frame_time();

        if self.mismatch_timer > 0.0 {
            self.mismatch_timer -= dt;
            if self.mismatch_timer <= 0.0 {
                for index in self.selected_indices.drain(..) {
                    if !self.cards[index].matched {
                        self.cards[index].revealed = false;
                    }
                }
                self.mismatch_timer = 0.0;
            }
        }

        if self.solved_flash > 0.0 {
            self.solved_flash = (self.solved_flash - dt).max(0.0);
        }

        for card in &mut self.cards {
            let target = if card.revealed || card.matched {
                1.0
            } else {
                0.0
            };
            let speed = 7.5 * dt;
            if card.flip_progress < target {
                card.flip_progress = (card.flip_progress + speed).min(target);
            } else if card.flip_progress > target {
                card.flip_progress = (card.flip_progress - speed).max(target);
            }
        }
    }

    pub fn draw(&self) {
        let (offset_x, offset_y, card_width, card_height) = self.grid_metrics();
        let matched_pairs = self.cards.iter().filter(|card| card.matched).count() / 2;

        draw_game_text("Мемори: найдите все пары", 20.0, 62.0, 28.0, WHITE);
        let progress = format!(
            "Пар найдено: {}/{} | Ходов: {}",
            matched_pairs,
            self.cards.len() / 2,
            self.attempts
        );
        draw_game_text(&progress, 20.0, 92.0, 20.0, LIGHTGRAY);

        for (index, card) in self.cards.iter().enumerate() {
            let row = index / self.columns;
            let col = index % self.columns;
            let base_x = offset_x + col as f32 * card_width;
            let base_y = offset_y + row as f32 * card_height;

            let pulse = (get_time() as f32 * 2.3 + index as f32 * 0.7).sin() * 0.5 + 0.5;
            let reveal_scale = ((card.flip_progress - 0.5).abs() * 2.0 - 1.0)
                .abs()
                .clamp(0.08, 1.0);
            let visual_width = (card_width - 10.0) * reveal_scale;
            let x = base_x + ((card_width - 10.0) - visual_width) / 2.0;
            let y = base_y + if card.matched { pulse * 2.0 } else { 0.0 };

            let front_side = card.flip_progress >= 0.5;
            let fill = if card.matched {
                Color::from_rgba(86, 176, 118, 255)
            } else if front_side {
                Color::from_rgba(245, 229, 188, 255)
            } else {
                Color::from_rgba(64, 92, 142, 255)
            };

            draw_rectangle(x, y, visual_width, card_height - 10.0, fill);
            draw_rectangle_lines(
                x,
                y,
                visual_width,
                card_height - 10.0,
                3.0,
                if card.matched {
                    Color::from_rgba(220, 255, 220, 255)
                } else {
                    Color::from_rgba(210, 220, 240, 255)
                },
            );

            if front_side {
                self.draw_symbol(
                    card.symbol,
                    x + visual_width / 2.0,
                    y + (card_height - 10.0) / 2.0,
                    46.0,
                    pulse,
                );
            } else {
                let mark = "?";
                let mark_width = measure_game_text(mark, None, 36, 1.0).width;
                draw_game_text(
                    mark,
                    x + visual_width / 2.0 - mark_width / 2.0,
                    y + card_height / 2.0 + 8.0,
                    36.0,
                    Color::from_rgba(230, 240, 255, 255),
                );
                draw_circle(
                    x + visual_width / 2.0,
                    y + (card_height - 10.0) / 2.0,
                    18.0 + pulse * 3.0,
                    Color::from_rgba(105, 145, 215, 120),
                );
            }
        }

        let hint = if self.mismatch_timer > 0.0 {
            "Карты не совпали. Запомните их расположение."
        } else if self.selected_indices.len() == 1 {
            "Выберите вторую карту."
        } else {
            "Открывайте по две карты и ищите одинаковые символы."
        };
        draw_game_text(hint, 20.0, screen_height() - 20.0, 18.0, GRAY);
    }

    pub fn is_solved(&self) -> bool {
        self.cards.iter().all(|card| card.matched)
    }
}
