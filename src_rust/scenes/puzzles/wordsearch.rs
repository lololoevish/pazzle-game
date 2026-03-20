use crate::ui_text::{draw_game_text, draw_wrapped_game_text, measure_game_text};
use ::rand::{thread_rng, Rng};
use macroquad::prelude::*;
use std::collections::HashSet;

#[derive(Clone)]
struct WordPlacement {
    word: String,
    positions: Vec<(usize, usize)>,
}

pub struct WordSearchPuzzle {
    grid: Vec<Vec<char>>,
    words: Vec<String>,
    found_words: Vec<String>,
    placements: Vec<WordPlacement>,
    drag_start: Option<(usize, usize)>,
    click_start: Option<(usize, usize)>,
    current_selection: Vec<(usize, usize)>,
    grid_size: usize,
    status_message: String,
}

impl WordSearchPuzzle {
    pub fn new() -> Self {
        let words = vec![
            "ИГРА".to_string(),
            "КОД".to_string(),
            "ПАЗЛ".to_string(),
            "КВЕСТ".to_string(),
        ];

        let mut puzzle = Self {
            grid: vec![vec![' '; 10]; 10],
            words,
            found_words: Vec::new(),
            placements: Vec::new(),
            drag_start: None,
            click_start: None,
            current_selection: Vec::new(),
            grid_size: 10,
            status_message: "Кликните первую и последнюю букву слова или протяните мышью"
                .to_string(),
        };

        puzzle.generate_grid();
        puzzle
    }

    fn generate_grid(&mut self) {
        let mut rng = thread_rng();
        let letters: Vec<char> = "АБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЭЮЯ".chars().collect();

        self.grid = vec![vec![' '; self.grid_size]; self.grid_size];
        self.placements.clear();

        for word in self.words.clone() {
            if let Some(positions) = self.place_word(&word) {
                self.placements.push(WordPlacement { word, positions });
            }
        }

        for row in &mut self.grid {
            for cell in row {
                if *cell == ' ' {
                    let idx = rng.gen_range(0..letters.len());
                    *cell = letters[idx];
                }
            }
        }
    }

    fn place_word(&mut self, word: &str) -> Option<Vec<(usize, usize)>> {
        let mut rng = thread_rng();
        let chars: Vec<char> = word.chars().collect();

        for _ in 0..100 {
            let horizontal = rng.gen_bool(0.5);

            if horizontal {
                let x = rng.gen_range(0..=(self.grid_size - chars.len()));
                let y = rng.gen_range(0..self.grid_size);

                if chars
                    .iter()
                    .enumerate()
                    .all(|(i, &ch)| self.grid[y][x + i] == ' ' || self.grid[y][x + i] == ch)
                {
                    let mut positions = Vec::with_capacity(chars.len());
                    for (i, &ch) in chars.iter().enumerate() {
                        self.grid[y][x + i] = ch;
                        positions.push((x + i, y));
                    }
                    return Some(positions);
                }
            } else {
                let x = rng.gen_range(0..self.grid_size);
                let y = rng.gen_range(0..=(self.grid_size - chars.len()));

                if chars
                    .iter()
                    .enumerate()
                    .all(|(i, &ch)| self.grid[y + i][x] == ' ' || self.grid[y + i][x] == ch)
                {
                    let mut positions = Vec::with_capacity(chars.len());
                    for (i, &ch) in chars.iter().enumerate() {
                        self.grid[y + i][x] = ch;
                        positions.push((x, y + i));
                    }
                    return Some(positions);
                }
            }
        }

        None
    }

    fn grid_origin(&self) -> (f32, f32, f32) {
        let cell_size = 40.0;
        let offset_x = (screen_width() - self.grid_size as f32 * cell_size) / 2.0;
        let offset_y = 100.0;
        (offset_x, offset_y, cell_size)
    }

    fn cell_from_mouse(&self, mx: f32, my: f32) -> Option<(usize, usize)> {
        let (offset_x, offset_y, cell_size) = self.grid_origin();
        if mx < offset_x || my < offset_y {
            return None;
        }

        let x = ((mx - offset_x) / cell_size).floor() as i32;
        let y = ((my - offset_y) / cell_size).floor() as i32;

        if x >= 0 && y >= 0 && x < self.grid_size as i32 && y < self.grid_size as i32 {
            Some((x as usize, y as usize))
        } else {
            None
        }
    }

    fn build_selection_path(
        &self,
        start: (usize, usize),
        end: (usize, usize),
    ) -> Vec<(usize, usize)> {
        let dx = end.0 as i32 - start.0 as i32;
        let dy = end.1 as i32 - start.1 as i32;

        if dx != 0 && dy != 0 {
            return Vec::new();
        }

        let step_x = dx.signum();
        let step_y = dy.signum();
        let steps = dx.abs().max(dy.abs()) as usize;

        let mut path = Vec::with_capacity(steps + 1);
        for i in 0..=steps {
            path.push((
                (start.0 as i32 + step_x * i as i32) as usize,
                (start.1 as i32 + step_y * i as i32) as usize,
            ));
        }

        path
    }

    fn check_selection(&mut self) {
        if self.current_selection.is_empty() {
            return;
        }

        for placement in &self.placements {
            if self.found_words.contains(&placement.word) {
                continue;
            }

            let reversed: Vec<(usize, usize)> = placement.positions.iter().copied().rev().collect();
            if self.current_selection == placement.positions || self.current_selection == reversed {
                self.found_words.push(placement.word.clone());
                self.status_message = format!("Найдено слово: {}", placement.word);
                self.current_selection.clear();
                return;
            }
        }

        self.status_message =
            "Это не подходит. Выделяйте слово по горизонтали или вертикали".to_string();
        self.current_selection.clear();
    }

    pub fn handle_input(&mut self) {
        let (mx, my) = mouse_position();

        if is_mouse_button_pressed(MouseButton::Left) {
            self.drag_start = self.cell_from_mouse(mx, my);
            if let Some(start) = self.drag_start {
                self.current_selection = vec![start];
                if let Some(click_start) = self.click_start {
                    let path = self.build_selection_path(click_start, start);
                    if !path.is_empty() && path.len() > 1 {
                        self.current_selection = path;
                        self.check_selection();
                        self.click_start = None;
                        self.drag_start = None;
                        return;
                    }
                } else {
                    self.click_start = Some(start);
                    self.status_message = "Выберите последнюю букву слова".to_string();
                }
            }
        }

        if is_mouse_button_down(MouseButton::Left) {
            if let (Some(start), Some(end)) = (self.drag_start, self.cell_from_mouse(mx, my)) {
                let path = self.build_selection_path(start, end);
                if !path.is_empty() {
                    self.current_selection = path;
                    self.click_start = Some(start);
                }
            }
        }

        if is_mouse_button_released(MouseButton::Left) {
            if self.current_selection.len() > 1 {
                self.check_selection();
                self.click_start = None;
            }
            self.drag_start = None;
        }

        if is_mouse_button_pressed(MouseButton::Right) {
            self.click_start = None;
            self.current_selection.clear();
            self.status_message = "Выбор сброшен. Кликните первую букву заново".to_string();
        }
    }

    pub fn draw(&self) {
        let (offset_x, offset_y, cell_size) = self.grid_origin();

        let selected_cells: HashSet<(usize, usize)> =
            self.current_selection.iter().copied().collect();
        let mut found_cells = HashSet::new();
        for placement in &self.placements {
            if self.found_words.contains(&placement.word) {
                for position in &placement.positions {
                    found_cells.insert(*position);
                }
            }
        }

        for y in 0..self.grid_size {
            for x in 0..self.grid_size {
                let px = offset_x + x as f32 * cell_size;
                let py = offset_y + y as f32 * cell_size;

                let fill = if found_cells.contains(&(x, y)) {
                    Color::from_rgba(110, 200, 120, 255)
                } else if selected_cells.contains(&(x, y)) {
                    Color::from_rgba(255, 210, 110, 255)
                } else {
                    Color::from_rgba(240, 240, 250, 255)
                };

                draw_rectangle(px, py, cell_size - 2.0, cell_size - 2.0, fill);
                draw_rectangle_lines(px, py, cell_size - 2.0, cell_size - 2.0, 1.0, GRAY);

                let ch = self.grid[y][x].to_string();
                let text_size = 24.0;
                let text_width = measure_game_text(&ch, None, text_size as u16, 1.0).width;
                draw_game_text(
                    &ch,
                    px + (cell_size - text_width) / 2.0,
                    py + cell_size / 2.0 + 8.0,
                    text_size,
                    BLACK,
                );
            }
        }

        let words_x = 50.0;
        let words_y = offset_y;

        draw_game_text("Найдите слова:", words_x, words_y, 20.0, WHITE);

        for (i, word) in self.words.iter().enumerate() {
            let color = if self.found_words.contains(word) {
                GREEN
            } else {
                WHITE
            };

            draw_game_text(word, words_x, words_y + 30.0 + i as f32 * 25.0, 18.0, color);
        }

        let progress = format!("Найдено: {}/{}", self.found_words.len(), self.words.len());
        draw_game_text(&progress, 20.0, 130.0, 20.0, WHITE);
        draw_wrapped_game_text(
            &self.status_message,
            20.0,
            screen_height() - 62.0,
            screen_width() - 40.0,
            18.0,
            4.0,
            LIGHTGRAY,
        );
    }

    pub fn is_solved(&self) -> bool {
        self.found_words.len() == self.words.len()
    }
}
