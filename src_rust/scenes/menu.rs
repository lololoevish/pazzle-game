use macroquad::prelude::*;
use crate::game_state::GameState;
use super::Scene;

pub struct MenuScene {
    selected_option: usize,
    options: Vec<&'static str>,
    next_state: Option<GameState>,
    animation_time: f32,
    particles: Vec<Particle>,
}

struct Particle {
    x: f32,
    y: f32,
    vx: f32,
    vy: f32,
    life: f32,
    size: f32,
}

impl MenuScene {
    pub fn new() -> Self {
        Self {
            selected_option: 0,
            options: vec!["Играть", "Настройки", "Выход"],
            next_state: None,
            animation_time: 0.0,
            particles: Vec::new(),
        }
    }
    
    fn draw_gradient_background(&self) {
        // Градиентный фон
        let colors = [
            Color::from_rgba(20, 30, 50, 255),
            Color::from_rgba(40, 20, 60, 255),
            Color::from_rgba(60, 30, 80, 255),
        ];
        
        for i in 0..screen_height() as i32 {
            let t = i as f32 / screen_height();
            let idx = (t * (colors.len() - 1) as f32) as usize;
            let next_idx = (idx + 1).min(colors.len() - 1);
            let local_t = (t * (colors.len() - 1) as f32) - idx as f32;
            
            let color = Color::new(
                colors[idx].r + (colors[next_idx].r - colors[idx].r) * local_t,
                colors[idx].g + (colors[next_idx].g - colors[idx].g) * local_t,
                colors[idx].b + (colors[next_idx].b - colors[idx].b) * local_t,
                1.0,
            );
            
            draw_line(0.0, i as f32, screen_width(), i as f32, 1.0, color);
        }
    }
    
    fn draw_particles(&self) {
        for p in &self.particles {
            let alpha = p.life / 100.0;
            let color = Color::new(1.0, 1.0, 0.4, alpha);
            draw_circle(p.x, p.y, p.size, color);
        }
    }
}

impl Scene for MenuScene {
    fn handle_input(&mut self) {
        if is_key_pressed(KeyCode::Up) || is_key_pressed(KeyCode::W) {
            self.selected_option = if self.selected_option == 0 {
                self.options.len() - 1
            } else {
                self.selected_option - 1
            };
        }
        
        if is_key_pressed(KeyCode::Down) || is_key_pressed(KeyCode::S) {
            self.selected_option = (self.selected_option + 1) % self.options.len();
        }
        
        if is_key_pressed(KeyCode::Enter) || is_key_pressed(KeyCode::Space) {
            match self.selected_option {
                0 => self.next_state = Some(GameState::Town),
                1 => {}, // Настройки - пока не реализовано
                2 => self.next_state = Some(GameState::Quit),
                _ => {}
            }
        }
    }
    
    fn update(&mut self) {
        self.animation_time += get_frame_time();
        
        // Генерация частиц
        if rand::random::<f32>() < 0.1 {
            self.particles.push(Particle {
                x: rand::random::<f32>() * screen_width(),
                y: screen_height() + 10.0,
                vx: (rand::random::<f32>() - 0.5) * 2.0,
                vy: -rand::random::<f32>() * 3.0 - 1.0,
                life: 100.0,
                size: rand::random::<f32>() * 3.0 + 2.0,
            });
        }
        
        // Обновление частиц
        self.particles.retain_mut(|p| {
            p.x += p.vx;
            p.y += p.vy;
            p.life -= 1.0;
            p.life > 0.0
        });
    }
    
    fn draw(&self) {
        self.draw_gradient_background();
        self.draw_particles();
        
        // Заголовок
        let title = "ПРИКЛЮЧЕНЧЕСКАЯ ИГРА";
        let title_size = 50.0;
        let title_width = measure_text(title, None, title_size as u16, 1.0).width;
        
        // Тень заголовка
        draw_text(
            title,
            screen_width() / 2.0 - title_width / 2.0 + 3.0,
            150.0 + 3.0,
            title_size,
            Color::from_rgba(20, 10, 30, 255),
        );
        
        // Основной заголовок
        draw_text(
            title,
            screen_width() / 2.0 - title_width / 2.0,
            150.0,
            title_size,
            Color::from_rgba(255, 215, 0, 255),
        );
        
        // Подзаголовок
        let subtitle = "С головоломками";
        let subtitle_size = 25.0;
        let subtitle_width = measure_text(subtitle, None, subtitle_size as u16, 1.0).width;
        draw_text(
            subtitle,
            screen_width() / 2.0 - subtitle_width / 2.0,
            180.0,
            subtitle_size,
            Color::from_rgba(200, 180, 150, 255),
        );
        
        // Опции меню
        let menu_start_y = 280.0;
        let option_height = 60.0;
        
        for (i, option) in self.options.iter().enumerate() {
            let y = menu_start_y + i as f32 * option_height;
            let is_selected = i == self.selected_option;
            
            // Фон опции
            let bg_color = if is_selected {
                Color::from_rgba(80, 100, 140, 200)
            } else {
                Color::from_rgba(40, 50, 70, 150)
            };
            
            let rect_width = 300.0;
            let rect_x = screen_width() / 2.0 - rect_width / 2.0;
            
            draw_rectangle(rect_x, y - 35.0, rect_width, 50.0, bg_color);
            
            // Рамка
            let border_color = if is_selected {
                Color::from_rgba(150, 200, 255, 255)
            } else {
                Color::from_rgba(100, 120, 150, 255)
            };
            
            draw_rectangle_lines(rect_x, y - 35.0, rect_width, 50.0, 2.0, border_color);
            
            // Текст опции
            let text_size = if is_selected { 35.0 } else { 30.0 };
            let text_color = if is_selected {
                Color::from_rgba(255, 255, 255, 255)
            } else {
                Color::from_rgba(180, 180, 180, 255)
            };
            
            let text_width = measure_text(option, None, text_size as u16, 1.0).width;
            draw_text(
                option,
                screen_width() / 2.0 - text_width / 2.0,
                y,
                text_size,
                text_color,
            );
            
            // Индикатор выбора
            if is_selected {
                let pulse = (self.animation_time * 3.0).sin() * 0.3 + 0.7;
                let indicator_color = Color::new(1.0, 1.0, 0.4, pulse);
                draw_text("►", rect_x - 30.0, y, 30.0, indicator_color);
                draw_text("◄", rect_x + rect_width + 10.0, y, 30.0, indicator_color);
            }
        }
        
        // Подсказка
        let hint = "↑↓ - выбор, ENTER - подтвердить";
        let hint_size = 18.0;
        let hint_width = measure_text(hint, None, hint_size as u16, 1.0).width;
        draw_text(
            hint,
            screen_width() / 2.0 - hint_width / 2.0,
            screen_height() - 30.0,
            hint_size,
            Color::from_rgba(150, 150, 150, 255),
        );
        
        // Версия
        let version = "v1.2.0 (Rust Edition)";
        draw_text(
            version,
            10.0,
            screen_height() - 10.0,
            16.0,
            Color::from_rgba(100, 100, 100, 255),
        );
    }
    
    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }
}
