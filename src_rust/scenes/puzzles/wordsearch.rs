use macroquad::prelude::*;
use rand::Rng;

pub struct WordSearchPuzzle {
    grid: Vec<Vec<char>>,
    words: Vec<String>,
    found_words: Vec<String>,
    grid_size: usize,
}

impl WordSearchPuzzle {
    pub fn new() -> Self {
        let mut puzzle = Self {
            grid: vec![vec![' '; 10]; 10],
            words: vec![
                "ИГРА".to_string(),
                "КОД".to_string(),
                "ПАЗЛ".to_string(),
                "КВЕСТ".to_string(),
            ],
            found_words: Vec::new(),
            grid_size: 10,
        };
        
        puzzle.generate_grid();
        puzzle
    }
    
    fn generate_grid(&mut self) {
        let mut rng = rand::thread_rng();
        
        // Заполняем случайными буквами
        let letters = "АБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЭЮЯ";
        for y in 0..self.grid_size {
            for x in 0..self.grid_size {
                let idx = rng.gen_range(0..letters.len());
                self.grid[y][x] = letters.chars().nth(idx).unwrap();
            }
        }
        
        // Размещаем слова
        for word in &self.words {
            self.place_word(word);
        }
    }
    
    fn place_word(&mut self, word: &str) {
        let mut rng = rand::thread_rng();
        let chars: Vec<char> = word.chars().collect();
        
        for _ in 0..100 {
            let horizontal = rng.gen_bool(0.5);
            
            if horizontal {
                let x = rng.gen_range(0..=(self.grid_size - chars.len()));
                let y = rng.gen_range(0..self.grid_size);
                
                // Проверяем, можно ли разместить
                let mut can_place = true;
                for (i, &ch) in chars.iter().enumerate() {
                    if self.grid[y][x + i] != ' ' && self.grid[y][x + i] != ch {
                        can_place = false;
                        break;
                    }
                }
                
                if can_place {
                    for (i, &ch) in chars.iter().enumerate() {
                        self.grid[y][x + i] = ch;
                    }
                    return;
                }
            } else {
                let x = rng.gen_range(0..self.grid_size);
                let y = rng.gen_range(0..=(self.grid_size - chars.len()));
                
                let mut can_place = true;
                for (i, &ch) in chars.iter().enumerate() {
                    if self.grid[y + i][x] != ' ' && self.grid[y + i][x] != ch {
                        can_place = false;
                        break;
                    }
                }
                
                if can_place {
                    for (i, &ch) in chars.iter().enumerate() {
                        self.grid[y + i][x] = ch;
                    }
                    return;
                }
            }
        }
    }
    
    pub fn handle_input(&mut self) {
        // Обработка кликов мыши (упрощённая версия)
        if is_mouse_button_pressed(MouseButton::Left) {
            let (mx, my) = mouse_position();
            // TODO: Реализовать выбор букв
        }
    }
    
    pub fn draw(&self) {
        let cell_size = 40.0;
        let offset_x = (screen_width() - self.grid_size as f32 * cell_size) / 2.0;
        let offset_y = 100.0;
        
        // Рисуем сетку
        for y in 0..self.grid_size {
            for x in 0..self.grid_size {
                let px = offset_x + x as f32 * cell_size;
                let py = offset_y + y as f32 * cell_size;
                
                draw_rectangle(px, py, cell_size - 2.0, cell_size - 2.0, 
                             Color::from_rgba(240, 240, 250, 255));
                draw_rectangle_lines(px, py, cell_size - 2.0, cell_size - 2.0, 1.0, GRAY);
                
                // Рисуем букву
                let ch = self.grid[y][x].to_string();
                let text_size = 24.0;
                let text_width = measure_text(&ch, None, text_size as u16, 1.0).width;
                draw_text(
                    &ch,
                    px + (cell_size - text_width) / 2.0,
                    py + cell_size / 2.0 + 8.0,
                    text_size,
                    BLACK,
                );
            }
        }
        
        // Список слов
        let words_x = 50.0;
        let words_y = offset_y;
        
        draw_text("Найдите слова:", words_x, words_y, 20.0, WHITE);
        
        for (i, word) in self.words.iter().enumerate() {
            let color = if self.found_words.contains(word) {
                GREEN
            } else {
                WHITE
            };
            
            draw_text(word, words_x, words_y + 30.0 + i as f32 * 25.0, 18.0, color);
        }
        
        // Прогресс
        let progress = format!("Найдено: {}/{}", self.found_words.len(), self.words.len());
        draw_text(&progress, 20.0, 60.0, 20.0, WHITE);
    }
    
    pub fn is_solved(&self) -> bool {
        self.found_words.len() == self.words.len()
    }
}
