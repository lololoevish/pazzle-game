use macroquad::prelude::*;
use crate::game_state::{GameState, GameProgress};
use super::Scene;
use super::puzzles::{MazePuzzle, WordSearchPuzzle};

pub struct RoomScene {
    room_id: u8,
    progress: GameProgress,
    next_state: Option<GameState>,
    puzzle_solved: bool,
    lever_activated: bool,
    lever_rect: Rect,
    // Головоломки
    maze_puzzle: Option<MazePuzzle>,
    wordsearch_puzzle: Option<WordSearchPuzzle>,
}

impl RoomScene {
    pub fn new(room_id: u8, progress: GameProgress) -> Self {
        let mut scene = Self {
            room_id,
            progress,
            next_state: None,
            puzzle_solved: false,
            lever_activated: false,
            lever_rect: Rect::new(350.0, 500.0, 40.0, 60.0),
            maze_puzzle: None,
            wordsearch_puzzle: None,
        };
        
        scene.setup_puzzle();
        scene
    }
    
    fn setup_puzzle(&mut self) {
        match self.room_id {
            1 => {
                // Уровень 1: Лабиринт
                self.maze_puzzle = Some(MazePuzzle::new(15, 15));
            }
            2 => {
                // Уровень 2: Поиск слов
                self.wordsearch_puzzle = Some(WordSearchPuzzle::new());
            }
            _ => {}
        }
    }
    
    fn draw_room(&self) {
        // Фон - стены комнаты
        clear_background(Color::from_rgba(80, 70, 60, 255));
        
        // Пол
        draw_rectangle(0.0, screen_height() - 50.0, screen_width(), 50.0, Color::from_rgba(60, 50, 40, 255));
        
        // Стены
        draw_rectangle(0.0, 0.0, 20.0, screen_height(), Color::from_rgba(100, 90, 80, 255));
        draw_rectangle(screen_width() - 20.0, 0.0, 20.0, screen_height(), Color::from_rgba(100, 90, 80, 255));
        draw_rectangle(0.0, 0.0, screen_width(), 20.0, Color::from_rgba(100, 90, 80, 255));
        
        // Дверь (выход)
        draw_rectangle(380.0, 0.0, 40.0, 40.0, Color::from_rgba(139, 69, 19, 255));
        draw_text("ВЫХОД", 385.0, 10.0, 14.0, WHITE);
    }
    
    fn draw_lever(&self) {
        let x = self.lever_rect.x;
        let y = self.lever_rect.y;
        let w = self.lever_rect.w;
        let h = self.lever_rect.h;
        
        // Основание
        draw_rectangle(x, y + 40.0, w, 20.0, Color::from_rgba(80, 80, 80, 255));
        
        // Рукоятка
        let handle_y = if self.lever_activated { y + 35.0 } else { y + 10.0 };
        let color = if self.lever_activated { Color::from_rgba(150, 150, 50, 255) } else { Color::from_rgba(200, 150, 50, 255) };
        
        draw_rectangle(x + w / 2.0 - 3.0, handle_y, 6.0, 35.0, Color::from_rgba(100, 100, 100, 255));
        draw_rectangle(x, handle_y, w, 15.0, color);
        draw_rectangle_lines(x, handle_y, w, 15.0, 2.0, WHITE);
        
        // Подпись
        let text = if self.lever_activated { "Открыто" } else { "E - Рычаг" };
        let text_width = measure_text(text, None, 12.0 as u16, 1.0).width;
        draw_text(text, x - text_width / 2.0 + w / 2.0, y + h + 15.0, 12.0, WHITE);
    }
    
    fn draw_puzzle(&self) {
        if let Some(maze) = &self.maze_puzzle {
            maze.draw();
        }
        
        if let Some(wordsearch) = &self.wordsearch_puzzle {
            wordsearch.draw();
        }
    }
}

impl Scene for RoomScene {
    fn handle_input(&mut self) {
        if is_key_pressed(KeyCode::Escape) {
            self.next_state = Some(GameState::Village);
            return;
        }
        
        // Обработка рычага
        let (mx, my) = mouse_position();
        if mx >= self.lever_rect.x && mx <= self.lever_rect.x + self.lever_rect.w &&
           my >= self.lever_rect.y && my <= self.lever_rect.y + self.lever_rect.h {
            if is_key_pressed(KeyCode::E) {
                self.lever_activated = true;
            }
        }
        
        // Обработка головоломок
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
        
        // Выход после решения головоломки
        if self.puzzle_solved && is_key_pressed(KeyCode::Enter) {
            self.next_state = Some(GameState::Village);
        }
    }
    
    fn update(&mut self) {
        if let Some(maze) = &mut self.maze_puzzle {
            maze.update();
        }
        
        if let Some(pattern) = &mut self.wordsearch_puzzle {
            pattern.update();
        }
    }
    
    fn draw(&self) {
        self.draw_room();
        self.draw_puzzle();
        self.draw_lever();
        
        // Сообщение о победе
        if self.puzzle_solved {
            let win_text = "ГОЛОВОЛОМКА РЕШЕНА!";
            let text_width = measure_text(win_text, None, 36.0 as u16, 1.0).width;
            draw_text(win_text, screen_width() / 2.0 - text_width / 2.0, 100.0, 36.0, Color::from_rgba(255, 215, 0, 255));
            
            let hint = "Нажмите ENTER для выхода";
            let hint_width = measure_text(hint, None, 20.0 as u16, 1.0).width;
            draw_text(hint, screen_width() / 2.0 - hint_width / 2.0, 150.0, 20.0, WHITE);
        }
        
        // Подсказка
        draw_text("ESC - выход в деревню", 20.0, screen_height() - 20.0, 16.0, GRAY);
    }
    
    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }
}
