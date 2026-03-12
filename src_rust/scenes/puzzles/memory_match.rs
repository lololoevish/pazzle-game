use ::rand::{seq::SliceRandom, thread_rng};
use macroquad::prelude::*;

#[derive(Clone)]
struct Card {
    symbol: char,
    revealed: bool,
    matched: bool,
}

pub struct MemoryMatchPuzzle {
    cards: Vec<Card>,
    columns: usize,
    selected_indices: Vec<usize>,
    mismatch_timer: f32,
    attempts: u32,
    preview_timer: f32,
}

impl MemoryMatchPuzzle {
    pub fn new() -> Self {
        let mut symbols = vec!['★', '★', '◆', '◆', '●', '●', '▲', '▲'];
        symbols.shuffle(&mut thread_rng());

        Self {
            cards: symbols
                .into_iter()
                .map(|symbol| Card {
                    symbol,
                    revealed: false,
                    matched: false,
                })
                .collect(),
            columns: 4,
            selected_indices: Vec::new(),
            mismatch_timer: 0.0,
            attempts: 0,
            preview_timer: 2.2,
        }
    }

    fn grid_metrics(&self) -> (f32, f32, f32, f32) {
        let card_width = 110.0;
        let card_height = 110.0;
        let total_width = self.columns as f32 * card_width;
        let offset_x = (screen_width() - total_width) / 2.0;
        let offset_y = 120.0;
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
        } else {
            self.mismatch_timer = 0.8;
        }
    }

    pub fn handle_input(&mut self) {
        if self.mismatch_timer > 0.0 || self.preview_timer > 0.0 {
            return;
        }

        if is_mouse_button_pressed(MouseButton::Left) {
            let (mx, my) = mouse_position();
            if let Some(index) = self.card_at_position(mx, my) {
                let card = &self.cards[index];
                if card.matched || card.revealed || self.selected_indices.len() >= 2 {
                    return;
                }

                self.cards[index].revealed = true;
                self.selected_indices.push(index);

                if self.selected_indices.len() == 2 {
                    self.resolve_selected_pair();
                }
            }
        }
    }

    pub fn update(&mut self) {
        if self.preview_timer > 0.0 {
            self.preview_timer -= get_frame_time();
            if self.preview_timer < 0.0 {
                self.preview_timer = 0.0;
            }
        }

        if self.mismatch_timer > 0.0 {
            self.mismatch_timer -= get_frame_time();
            if self.mismatch_timer <= 0.0 {
                for index in self.selected_indices.drain(..) {
                    if !self.cards[index].matched {
                        self.cards[index].revealed = false;
                    }
                }
                self.mismatch_timer = 0.0;
            }
        }
    }

    pub fn draw(&self) {
        let (offset_x, offset_y, card_width, card_height) = self.grid_metrics();

        draw_text("Откройте все пары", 20.0, 60.0, 28.0, WHITE);
        let progress = format!(
            "Пар найдено: {}/{} | Попытки: {}",
            self.cards.iter().filter(|card| card.matched).count() / 2,
            self.cards.len() / 2,
            self.attempts
        );
        draw_text(&progress, 20.0, 90.0, 20.0, LIGHTGRAY);

        for (index, card) in self.cards.iter().enumerate() {
            let row = index / self.columns;
            let col = index % self.columns;
            let x = offset_x + col as f32 * card_width;
            let y = offset_y + row as f32 * card_height;

            let fill = if card.matched {
                Color::from_rgba(90, 180, 110, 255)
            } else if card.revealed {
                Color::from_rgba(240, 220, 160, 255)
            } else {
                Color::from_rgba(70, 90, 130, 255)
            };

            draw_rectangle(x, y, card_width - 10.0, card_height - 10.0, fill);
            draw_rectangle_lines(
                x,
                y,
                card_width - 10.0,
                card_height - 10.0,
                3.0,
                Color::from_rgba(210, 220, 240, 255),
            );

            let text = if self.preview_timer > 0.0 || card.revealed || card.matched {
                card.symbol.to_string()
            } else {
                "?".to_string()
            };
            let text_size = 48.0;
            let text_width = measure_text(&text, None, text_size as u16, 1.0).width;
            draw_text(
                &text,
                x + (card_width - 10.0 - text_width) / 2.0,
                y + card_height / 2.0 + 12.0,
                text_size,
                BLACK,
            );
        }

        let hint = if self.preview_timer > 0.0 {
            "Запомните расположение символов"
        } else if self.mismatch_timer > 0.0 {
            "Запоминайте открытые карты"
        } else {
            "Кликайте по двум карточкам подряд"
        };
        draw_text(hint, 20.0, screen_height() - 20.0, 18.0, GRAY);
    }

    pub fn is_solved(&self) -> bool {
        self.cards.iter().all(|card| card.matched)
    }
}
