use macroquad::prelude::*;
use crate::game_state::GameState;
use super::Scene;
use super::puzzles::{MazePuzzle, WordSearchPuzzle, PatternPuzzle};

pub struct GameplayScene {
    level: u8,
    next_state: Option<GameState>,
    puzzle_solved: bool,
    
    // Головоломки
    maze_puzzle: Option<MazePuzzle>,
    wordsearch_puzzle: Option<WordSearchPuzzle>,
    pattern_puzzle: Option<PatternPuzzle>,
}

impl GameplayScene {
    pub fn new(level: u8) -> Self {
        let mut scene = Self {
            level,
            next_state: None,
            puzzle_solved: false,
            maze_puzzle: None,
            wordsearch_puzzle: None,
            pattern_puzzle: None,
        };
        
        scene.setup_level();
        scene
    }
    
    fn setup_level(&mut self) {
        match self.level {
            1 => {
                self.maze_puzzle = Some(MazePuzzle::new(15, 15));
            }
            2 => {
                self.wordsearch_puzzle = Some(WordSearchPuzzle::new());
            }
            3 => {
                self.pattern_puzzle = Some(PatternPuzzle::new());
            }
            _ => {}
        }
    }
}

impl Scene for GameplayScene {
    fn handle_input(&mut self) {
        if is_key_pressed(KeyCode::Escape) {
            self.next_state = Some(GameState::Town);
            return;
        }
        
        // Обработка ввода для головоломок
        if let Some(maze) = &mut self.maze_puzzle {
            maze.handle_input();
            if maze.is_solved() {
                self.puzzle_solved = true;
            }
        }
        
        if let Some(wordsearch) = &mut self.wordsearch_puzzle {
            wordsearch.handle_input();
            if wordsearch.is_solved() {
                self.puzzle_solved = true;
            }
        }
        
        if let Some(pattern) = &mut self.pattern_puzzle {
            pattern.handle_input();
            if pattern.is_solved() {
                self.puzzle_solved = true;
            }
        }
        
        // Выход после решения
        if self.puzzle_solved && is_key_pressed(KeyCode::Enter) {
            self.next_state = Some(GameState::Town);
        }
    }
    
    fn update(&mut self) {
        if let Some(maze) = &mut self.maze_puzzle {
            maze.update();
        }
        
        if let Some(pattern) = &mut self.pattern_puzzle {
            pattern.update();
        }
    }
    
    fn draw(&self) {
        // Фон
        clear_background(Color::from_rgba(30, 40, 60, 255));
        
        // Заголовок
        let title = format!("Уровень {}", self.level);
        draw_text(&title, 20.0, 30.0, 30.0, WHITE);
        
        // Отрисовка головоломок
        if let Some(maze) = &self.maze_puzzle {
            maze.draw();
        }
        
        if let Some(wordsearch) = &self.wordsearch_puzzle {
            wordsearch.draw();
        }
        
        if let Some(pattern) = &self.pattern_puzzle {
            pattern.draw();
        }
        
        // Сообщение о победе
        if self.puzzle_solved {
            let overlay_color = Color::from_rgba(0, 0, 0, 180);
            draw_rectangle(0.0, 0.0, screen_width(), screen_height(), overlay_color);
            
            let win_text = "ГОЛОВОЛОМКА РЕШЕНА!";
            let text_size = 48.0;
            let text_width = measure_text(win_text, None, text_size as u16, 1.0).width;
            
            draw_text(
                win_text,
                screen_width() / 2.0 - text_width / 2.0,
                screen_height() / 2.0,
                text_size,
                Color::from_rgba(255, 215, 0, 255),
            );
            
            let hint = "Нажмите ENTER для возврата";
            let hint_size = 24.0;
            let hint_width = measure_text(hint, None, hint_size as u16, 1.0).width;
            
            draw_text(
                hint,
                screen_width() / 2.0 - hint_width / 2.0,
                screen_height() / 2.0 + 50.0,
                hint_size,
                WHITE,
            );
        }
        
        // Подсказка
        draw_text("ESC - выход", 20.0, screen_height() - 20.0, 18.0, GRAY);
    }
    
    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }
}
