use macroquad::prelude::*;
use rand::Rng;

pub struct PatternPuzzle {
    buttons: Vec<Button>,
    sequence: Vec<usize>,
    player_input: Vec<usize>,
    current_round: usize,
    max_rounds: usize,
    showing_sequence: bool,
    show_timer: f32,
    current_show_index: usize,
    solved: bool,
}

struct Button {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    color: Color,
    id: usize,
    highlighted: bool,
}

impl PatternPuzzle {
    pub fn new() -> Self {
        let mut puzzle = Self {
            buttons: vec![
                Button {
                    x: 250.0,
                    y: 200.0,
                    width: 100.0,
                    height: 80.0,
                    color: Color::from_rgba(255, 100, 100, 255),
                    id: 0,
                    highlighted: false,
                },
                Button {
                    x: 450.0,
                    y: 200.0,
                    width: 100.0,
                    height: 80.0,
                    color: Color::from_rgba(100, 255, 100, 255),
                    id: 1,
                    highlighted: false,
                },
                Button {
                    x: 250.0,
                    y: 350.0,
                    width: 100.0,
                    height: 80.0,
                    color: Color::from_rgba(100, 100, 255, 255),
                    id: 2,
                    highlighted: false,
                },
                Button {
                    x: 450.0,
                    y: 350.0,
                    width: 100.0,
                    height: 80.0,
                    color: Color::from_rgba(255, 255, 100, 255),
                    id: 3,
                    highlighted: false,
                },
            ],
            sequence: Vec::new(),
            player_input: Vec::new(),
            current_round: 1,
            max_rounds: 5,
            showing_sequence: false,
            show_timer: 0.0,
            current_show_index: 0,
            solved: false,
        };
        
        puzzle.generate_sequence();
        puzzle.start_showing_sequence();
        puzzle
    }
    
    fn generate_sequence(&mut self) {
        let mut rng = rand::thread_rng();
        self.sequence.clear();
        
        for _ in 0..(2 + self.current_round) {
            self.sequence.push(rng.gen_range(0..4));
        }
    }
    
    fn start_showing_sequence(&mut self) {
        self.showing_sequence = true;
        self.show_timer = 0.0;
        self.current_show_index = 0;
        self.player_input.clear();
    }
    
    pub fn handle_input(&mut self) {
        if self.solved || self.showing_sequence {
            return;
        }
        
        if is_mouse_button_pressed(MouseButton::Left) {
            let (mx, my) = mouse_position();
            
            for button in &self.buttons {
                if mx >= button.x && mx <= button.x + button.width &&
                   my >= button.y && my <= button.y + button.height {
                    self.handle_button_click(button.id);
                    break;
                }
            }
        }
    }
    
    fn handle_button_click(&mut self, button_id: usize) {
        self.player_input.push(button_id);
        
        // Проверяем правильность
        let expected = self.sequence[self.player_input.len() - 1];
        
        if button_id != expected {
            // Ошибка - начинаем сначала
            self.current_round = 1;
            self.generate_sequence();
            self.start_showing_sequence();
            return;
        }
        
        // Проверяем завершение последовательности
        if self.player_input.len() == self.sequence.len() {
            if self.current_round >= self.max_rounds {
                // Все раунды пройдены!
                self.solved = true;
            } else {
                // Следующий раунд
                self.current_round += 1;
                self.generate_sequence();
                self.start_showing_sequence();
            }
        }
    }
    
    pub fn update(&mut self) {
        if self.showing_sequence {
            self.show_timer += get_frame_time();
            
            // Показываем кнопки по очереди
            let interval = 0.8; // 0.8 секунды на кнопку
            let current_index = (self.show_timer / interval) as usize;
            
            if current_index >= self.sequence.len() {
                // Закончили показ
                self.showing_sequence = false;
                for button in &mut self.buttons {
                    button.highlighted = false;
                }
            } else {
                // Подсвечиваем текущую кнопку
                for button in &mut self.buttons {
                    button.highlighted = button.id == self.sequence[current_index];
                }
            }
        }
    }
    
    pub fn draw(&self) {
        // Рисуем кнопки
        for button in &self.buttons {
            let color = if button.highlighted {
                WHITE
            } else {
                button.color
            };
            
            draw_rectangle(button.x, button.y, button.width, button.height, color);
            draw_rectangle_lines(button.x, button.y, button.width, button.height, 3.0, WHITE);
        }
        
        // Информация
        let info = if self.showing_sequence {
            format!("Запоминайте! Раунд {}/{}", self.current_round, self.max_rounds)
        } else {
            format!("Повторите! {}/{} | Раунд {}/{}", 
                   self.player_input.len(), 
                   self.sequence.len(),
                   self.current_round,
                   self.max_rounds)
        };
        
        draw_text(&info, 20.0, 60.0, 24.0, WHITE);
        
        // Подсказка
        if !self.showing_sequence {
            draw_text("Кликайте на кнопки в правильном порядке", 20.0, 90.0, 18.0, GRAY);
        }
    }
    
    pub fn is_solved(&self) -> bool {
        self.solved
    }
}
