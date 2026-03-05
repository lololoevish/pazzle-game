use macroquad::prelude::*;
use crate::game_state::{GameState, GameProgress};
use super::Scene;

pub struct VillageScene {
    player_x: f32,
    player_y: f32,
    player_direction: Direction,
    progress: GameProgress,
    next_state: Option<GameState>,
    npcs: Vec<NPC>,
    current_npc: Option<usize>,
    dialogue_timer: f32,
    show_dialogue: bool,
    dialogue_text: String,
}

#[derive(Clone, Copy)]
enum Direction {
    Down,
    Up,
    Left,
    Right,
}

struct NPC {
    x: f32,
    y: f32,
    name: String,
    dialogue: Vec<String>,
    interacted: bool,
}

impl VillageScene {
    pub fn new(progress: GameProgress) -> Self {
        let mut scene = Self {
            player_x: 400.0,
            player_y: 300.0,
            player_direction: Direction::Down,
            progress,
            next_state: None,
            npcs: vec![
                NPC {
                    x: 350.0,
                    y: 250.0,
                    name: "Староста".to_string(),
                    dialogue: vec![
                        "Привет, путник!".to_string(),
                        "В деревне есть комната с головоломкой.".to_string(),
                        "Пройди её, чтобы открыть дверь в лабиринт.".to_string(),
                        "Удачи!".to_string(),
                    ],
                    interacted: false,
                },
                NPC {
                    x: 450.0,
                    y: 250.0,
                    name: "Торговец".to_string(),
                    dialogue: vec![
                        "Ищешь приключений?".to_string(),
                        "В комнате за деревней головоломка.".to_string(),
                        "Реши её, и дверь откроется.".to_string(),
                    ],
                    interacted: false,
                },
            ],
            current_npc: None,
            dialogue_timer: 0.0,
            show_dialogue: false,
            dialogue_text: String::new(),
        };
        
        scene
    }
    
    fn draw_village(&self) {
        // Фон - трава
        clear_background(Color::from_rgba(100, 150, 100, 255));
        
        // Земля
        draw_rectangle(0.0, screen_height() - 100.0, screen_width(), 100.0, Color::from_rgba(80, 120, 80, 255));
        
        // Деревья (простые круги)
        for i in 0..5 {
            let x = 100.0 + i * 150.0;
            draw_circle(x, 100.0, 40.0, Color::from_rgba(60, 120, 60, 255));
            draw_circle(x, 100.0, 30.0, Color::from_rgba(80, 140, 80, 255));
        }
        
        // Дом с комнатой
        draw_rectangle(600.0, 200.0, 150.0, 150.0, Color::from_rgba(150, 100, 50, 255));
        draw_rectangle(650.0, 250.0, 50.0, 50.0, Color::from_rgba(100, 50, 25, 255)); // Дверь
        
        // Надпись "Комната"
        draw_text("Комната", 630.0, 180.0, 16.0, WHITE);
        
        // Знак "Вход"
        draw_text("Вход", 665.0, 265.0, 14.0, WHITE);
    }
    
    fn draw_player(&self) {
        let color = match self.player_direction {
            Direction::Down => Color::from_rgba(100, 150, 255, 255),
            Direction::Up => Color::from_rgba(100, 150, 255, 255),
            Direction::Left => Color::from_rgba(100, 150, 255, 255),
            Direction::Right => Color::from_rgba(100, 150, 255, 255),
        };
        
        draw_circle(self.player_x, self.player_y, 15.0, color);
        draw_circle_lines(self.player_x, self.player_y, 15.0, 2.0, WHITE);
    }
    
    fn draw_npcs(&self) {
        for (i, npc) in self.npcs.iter().enumerate() {
            let color = if self.current_npc == Some(i) {
                YELLOW
            } else {
                Color::from_rgba(255, 200, 100, 255)
            };
            
            draw_circle(npc.x, npc.y, 15.0, color);
            draw_circle_lines(npc.x, npc.y, 15.0, 2.0, WHITE);
            
            // Имя
            let name_width = measure_text(&npc.name, None, 14.0 as u16, 1.0).width;
            draw_text(&npc.name, npc.x - name_width / 2.0, npc.y - 25.0, 14.0, WHITE);
            
            // Иконка диалога
            if !npc.interacted {
                draw_text("!", npc.x + 18.0, npc.y - 18.0, 20.0, YELLOW);
            }
        }
    }
    
    fn draw_dialogue(&self) {
        if !self.show_dialogue {
            return;
        }
        
        let overlay = Color::from_rgba(0, 0, 0, 200);
        draw_rectangle(50.0, screen_height() - 150.0, screen_width() - 100.0, 130.0, overlay);
        draw_rectangle_lines(50.0, screen_height() - 150.0, screen_width() - 100.0, 130.0, 2.0, WHITE);
        
        let lines: Vec<&str> = self.dialogue_text.lines().collect();
        let mut y = screen_height() - 135.0;
        
        for line in lines {
            draw_text(line, 65.0, y, 20.0, WHITE);
            y += 25.0;
        }
        
        draw_text("Нажми ENTER для продолжения", screen_width() / 2.0 - 150.0, screen_height() - 25.0, 16.0, GRAY);
    }
}

impl Scene for VillageScene {
    fn handle_input(&mut self) {
        if self.show_dialogue {
            if is_key_pressed(KeyCode::Enter) {
                self.show_dialogue = false;
                self.current_npc = None;
            }
            return;
        }
        
        let speed = 3.0;
        let mut moved = false;
        
        if is_key_pressed(KeyCode::Up) || is_key_pressed(KeyCode::W) {
            self.player_y = (self.player_y - speed).max(50.0);
            self.player_direction = Direction::Up;
            moved = true;
        }
        if is_key_pressed(KeyCode::Down) || is_key_pressed(KeyCode::S) {
            self.player_y = (self.player_y + speed).min(screen_height() - 50.0);
            self.player_direction = Direction::Down;
            moved = true;
        }
        if is_key_pressed(KeyCode::Left) || is_key_pressed(KeyCode::A) {
            self.player_x = (self.player_x - speed).max(50.0);
            self.player_direction = Direction::Left;
            moved = true;
        }
        if is_key_pressed(KeyCode::Right) || is_key_pressed(KeyCode::D) {
            self.player_x = (self.player_x + speed).min(600.0);
            self.player_direction = Direction::Right;
            moved = true;
        }
        
        // Проверка входа в комнату
        if self.player_x >= 600.0 && self.player_x <= 750.0 && self.player_y >= 200.0 && self.player_y <= 350.0 {
            if is_key_pressed(KeyCode::Enter) {
                self.next_state = Some(GameState::Room(1));
                return;
            }
        }
        
        // Проверка взаимодействия с NPC
        for (i, npc) in self.npcs.iter().enumerate() {
            let dx = self.player_x - npc.x;
            let dy = self.player_y - npc.y;
            if dx * dx + dy * dy < 100.0 {
                if is_key_pressed(KeyCode::E) {
                    self.current_npc = Some(i);
                    self.show_dialogue = true;
                    self.dialogue_text = npc.dialogue.join("\n");
                    if !npc.interacted {
                        npc.interacted = true;
                    }
                }
            }
        }
        
        // Выход в меню
        if is_key_pressed(KeyCode::Escape) {
            self.next_state = Some(GameState::Menu);
        }
    }
    
    fn update(&mut self) {
        // Проверка достижения двери в лабиринт
        if self.player_x >= 750.0 && self.player_y >= 250.0 && self.player_y <= 350.0 {
            if is_key_pressed(KeyCode::Enter) {
                // Проверяем, решена ли головоломка
                if self.progress.is_level_unlocked(1) {
                    self.next_state = Some(GameState::Playing(1));
                }
            }
        }
    }
    
    fn draw(&self) {
        self.draw_village();
        self.draw_npcs();
        self.draw_player();
        self.draw_dialogue();
        
        // Подсказка
        draw_text("WASD - движение, E - диалог, ENTER - вход", 20.0, 30.0, 18.0, WHITE);
        
        // Индикатор двери
        if self.progress.is_level_unlocked(1) {
            draw_text("Дверь открыта!", 700.0, 150.0, 20.0, GREEN);
        } else {
            draw_text("Дверь закрыта", 700.0, 150.0, 20.0, RED);
        }
    }
    
    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }
}
