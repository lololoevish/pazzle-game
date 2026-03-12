use macroquad::prelude::*;
use crate::game_state::{GameState, GameProgress};
use super::Scene;

pub struct TownScene {
    selected_level: usize,
    progress: GameProgress,
    next_state: Option<GameState>,
    animation_time: f32,
}

impl TownScene {
    pub fn new(progress: GameProgress) -> Self {
        Self {
            selected_level: 0,
            progress,
            next_state: None,
            animation_time: 0.0,
        }
    }
    
    fn get_level_info(&self, level: u8) -> (&'static str, &'static str) {
        match level {
            1 => ("Подземелье I - Лабиринт", "Пройдите лабиринт"),
            2 => ("Подземелье II - Поиск слов", "Найдите все слова"),
            3 => ("Подземелье III - Память", "Повторите последовательность"),
            4 => ("Подземелье IV - Пары", "Найдите одинаковые карточки"),
            5 => ("Подземелье V - Платформер", "Прыгайте по платформам"),
            6 => ("Подземелье VI - Финал", "Соберите артефакты"),
            _ => ("Неизвестно", ""),
        }
    }
}

impl Scene for TownScene {
    fn handle_input(&mut self) {
        if is_key_pressed(KeyCode::Up) || is_key_pressed(KeyCode::W) {
            self.selected_level = if self.selected_level == 0 {
                6
            } else {
                self.selected_level - 1
            };
        }
        
        if is_key_pressed(KeyCode::Down) || is_key_pressed(KeyCode::S) {
            self.selected_level = (self.selected_level + 1) % 7;
        }
        
        if is_key_pressed(KeyCode::Enter) || is_key_pressed(KeyCode::Space) {
            if self.selected_level == 6 {
                // Вернуться в меню
                self.next_state = Some(GameState::Menu);
            } else {
                let level = (self.selected_level + 1) as u8;
                if self.progress.is_level_unlocked(level) {
                    self.next_state = Some(GameState::Playing(level));
                }
            }
        }
        
        if is_key_pressed(KeyCode::Escape) {
            self.next_state = Some(GameState::Menu);
        }
    }
    
    fn update(&mut self) {
        self.animation_time += get_frame_time();
    }
    
    fn draw(&self) {
        // Фон
        for i in 0..screen_height() as i32 {
            let t = i as f32 / screen_height();
            let color = Color::new(
                0.12 + t * 0.2,
                0.24 + t * 0.1,
                0.35 + t * 0.15,
                1.0,
            );
            draw_line(0.0, i as f32, screen_width(), i as f32, 1.0, color);
        }
        
        // Земля
        let ground_y = screen_height() - 150.0;
        draw_rectangle(0.0, ground_y, screen_width(), 150.0, Color::from_rgba(60, 40, 30, 255));
        
        // Заголовок
        let title = "ГОРОД ЭЛЬДОРАДО";
        let title_size = 48.0;
        let title_width = measure_text(title, None, title_size as u16, 1.0).width;
        
        // Тень
        draw_text(
            title,
            screen_width() / 2.0 - title_width / 2.0 + 3.0,
            53.0,
            title_size,
            Color::from_rgba(30, 20, 10, 255),
        );
        
        // Основной текст
        draw_text(
            title,
            screen_width() / 2.0 - title_width / 2.0,
            50.0,
            title_size,
            Color::from_rgba(255, 230, 180, 255),
        );
        
        // Подзаголовок
        let subtitle = "Центральная площадь";
        let subtitle_size = 18.0;
        let subtitle_width = measure_text(subtitle, None, subtitle_size as u16, 1.0).width;
        draw_text(
            subtitle,
            screen_width() / 2.0 - subtitle_width / 2.0,
            75.0,
            subtitle_size,
            Color::from_rgba(180, 160, 140, 255),
        );
        
        // Список уровней
        let start_y = 120.0;
        let item_height = 70.0;
        
        for i in 0..7 {
            let y = start_y + i as f32 * item_height;
            let is_selected = i == self.selected_level;
            
            let (name, desc) = if i < 6 {
                self.get_level_info((i + 1) as u8)
            } else {
                ("Вернуться в меню", "")
            };
            
            // Проверка доступности
            let is_unlocked = if i < 6 {
                self.progress.is_level_unlocked((i + 1) as u8)
            } else {
                true
            };
            
            let is_completed = if i < 6 {
                self.progress.levels.get(&((i + 1) as u8))
                    .map(|p| p.completed)
                    .unwrap_or(false)
            } else {
                false
            };
            
            // Фон
            let bg_color = if !is_unlocked {
                Color::from_rgba(50, 40, 40, 200)
            } else if is_selected {
                Color::from_rgba(60, 80, 100, 200)
            } else {
                Color::from_rgba(40, 50, 60, 180)
            };
            
            let rect_x = 50.0;
            let rect_width = screen_width() - 100.0;
            
            draw_rectangle(rect_x, y, rect_width, 65.0, bg_color);
            
            // Рамка
            let border_color = if is_selected {
                Color::from_rgba(100, 150, 200, 255)
            } else {
                Color::from_rgba(80, 90, 100, 255)
            };
            
            draw_rectangle_lines(rect_x, y, rect_width, 65.0, 2.0, border_color);
            
            // Статус
            let status_x = rect_x + 20.0;
            if i < 6 {
                let (status_text, status_color) = if is_completed {
                    ("✓ ПРОЙДЕНО", Color::from_rgba(100, 200, 100, 255))
                } else if is_unlocked {
                    ("► ДОСТУПНО", Color::from_rgba(100, 200, 100, 255))
                } else {
                    ("🔒 ЗАБЛОКИРОВАНО", Color::from_rgba(150, 50, 50, 255))
                };
                
                draw_text(status_text, status_x, y + 20.0, 16.0, status_color);
            }
            
            // Название
            let text_color = if is_unlocked {
                Color::from_rgba(200, 200, 200, 255)
            } else {
                Color::from_rgba(120, 120, 120, 255)
            };
            
            draw_text(name, status_x, y + 40.0, 24.0, text_color);
            
            // Описание
            if !desc.is_empty() {
                draw_text(desc, status_x, y + 58.0, 14.0, Color::from_rgba(140, 140, 140, 255));
            }
        }
        
        // Подсказка
        let hint = "↑↓ для выбора, ENTER для входа, ESC - в меню";
        let hint_size = 16.0;
        let hint_width = measure_text(hint, None, hint_size as u16, 1.0).width;
        draw_text(
            hint,
            screen_width() / 2.0 - hint_width / 2.0,
            screen_height() - 20.0,
            hint_size,
            Color::from_rgba(150, 150, 150, 255),
        );
    }
    
    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }
}
