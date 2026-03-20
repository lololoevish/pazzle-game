use crate::audio;
use crate::ui_text::draw_game_text;
use macroquad::prelude::*;

struct Platform {
    rect: Rect,
}

struct Crystal {
    x: f32,
    y: f32,
    collected: bool,
}

pub struct PlatformerPuzzle {
    player: Rect,
    velocity: Vec2,
    spawn: Vec2,
    on_ground: bool,
    platforms: Vec<Platform>,
    crystals: Vec<Crystal>,
    respawn_message_timer: f32,
}

impl PlatformerPuzzle {
    pub fn new() -> Self {
        let spawn = vec2(80.0, 470.0);

        Self {
            player: Rect::new(spawn.x, spawn.y, 34.0, 46.0),
            velocity: Vec2::ZERO,
            spawn,
            on_ground: false,
            platforms: vec![
                Platform {
                    rect: Rect::new(40.0, 520.0, 220.0, 24.0),
                },
                Platform {
                    rect: Rect::new(260.0, 430.0, 150.0, 20.0),
                },
                Platform {
                    rect: Rect::new(460.0, 340.0, 150.0, 20.0),
                },
                Platform {
                    rect: Rect::new(610.0, 250.0, 120.0, 20.0),
                },
                Platform {
                    rect: Rect::new(330.0, 210.0, 150.0, 20.0),
                },
            ],
            crystals: vec![
                Crystal {
                    x: 320.0,
                    y: 390.0,
                    collected: false,
                },
                Crystal {
                    x: 520.0,
                    y: 300.0,
                    collected: false,
                },
                Crystal {
                    x: 665.0,
                    y: 210.0,
                    collected: false,
                },
                Crystal {
                    x: 395.0,
                    y: 170.0,
                    collected: false,
                },
            ],
            respawn_message_timer: 0.0,
        }
    }

    fn reset_player(&mut self) {
        self.player.x = self.spawn.x;
        self.player.y = self.spawn.y;
        self.velocity = Vec2::ZERO;
        self.respawn_message_timer = 1.2;
    }

    pub fn handle_input(&mut self) {
        let horizontal = if is_key_down(KeyCode::A) || is_key_down(KeyCode::Left) {
            -1.0
        } else if is_key_down(KeyCode::D) || is_key_down(KeyCode::Right) {
            1.0
        } else {
            0.0
        };

        self.velocity.x = horizontal * 250.0;

        if self.on_ground
            && (is_key_pressed(KeyCode::Space)
                || is_key_pressed(KeyCode::Up)
                || is_key_pressed(KeyCode::W))
        {
            self.velocity.y = -395.0;
            self.on_ground = false;
            audio::play_puzzle_select();
        }
    }

    pub fn update(&mut self) {
        let dt = get_frame_time();
        let previous_y = self.player.y;

        if self.respawn_message_timer > 0.0 {
            self.respawn_message_timer -= dt;
        }

        self.velocity.y += 760.0 * dt;
        self.player.x += self.velocity.x * dt;
        self.player.y += self.velocity.y * dt;

        self.player.x = self.player.x.clamp(0.0, screen_width() - self.player.w);
        self.on_ground = false;

        for platform in &self.platforms {
            let landed_on_platform = previous_y + self.player.h <= platform.rect.y
                && self.player.y + self.player.h >= platform.rect.y
                && self.player.x + self.player.w > platform.rect.x
                && self.player.x < platform.rect.x + platform.rect.w;

            if landed_on_platform {
                self.player.y = platform.rect.y - self.player.h;
                self.velocity.y = 0.0;
                self.on_ground = true;
            }
        }

        if self.player.y > screen_height() {
            audio::play_puzzle_fall();
            self.reset_player();
        }

        let player_center = vec2(
            self.player.x + self.player.w / 2.0,
            self.player.y + self.player.h / 2.0,
        );
        for crystal in &mut self.crystals {
            if crystal.collected {
                continue;
            }

            if player_center.distance(vec2(crystal.x, crystal.y)) < 28.0 {
                crystal.collected = true;
                audio::play_puzzle_item();
            }
        }
    }

    pub fn draw(&self) {
        draw_game_text("Соберите все кристаллы", 20.0, 60.0, 28.0, WHITE);
        let collected = self
            .crystals
            .iter()
            .filter(|crystal| crystal.collected)
            .count();
        let progress = format!("Кристаллы: {}/{}", collected, self.crystals.len());
        draw_game_text(&progress, 20.0, 90.0, 20.0, LIGHTGRAY);

        for platform in &self.platforms {
            draw_rectangle(
                platform.rect.x,
                platform.rect.y,
                platform.rect.w,
                platform.rect.h,
                Color::from_rgba(118, 87, 62, 255),
            );
            draw_rectangle(
                platform.rect.x,
                platform.rect.y,
                platform.rect.w,
                6.0,
                Color::from_rgba(173, 133, 94, 255),
            );
        }

        for crystal in &self.crystals {
            if crystal.collected {
                continue;
            }

            draw_poly(
                crystal.x,
                crystal.y,
                4,
                14.0,
                45.0,
                Color::from_rgba(110, 220, 255, 255),
            );
            draw_poly_lines(crystal.x, crystal.y, 4, 14.0, 45.0, 2.0, WHITE);
        }

        draw_rectangle(
            self.player.x,
            self.player.y,
            self.player.w,
            self.player.h,
            Color::from_rgba(120, 180, 255, 255),
        );
        draw_rectangle(
            self.player.x + 6.0,
            self.player.y + 8.0,
            self.player.w - 12.0,
            10.0,
            Color::from_rgba(230, 240, 255, 255),
        );

        draw_game_text(
            "A/D или стрелки - движение, SPACE - прыжок",
            20.0,
            screen_height() - 20.0,
            18.0,
            GRAY,
        );

        if self.respawn_message_timer > 0.0 {
            draw_game_text(
                "Вы упали. Возврат на старт",
                screen_width() - 240.0,
                90.0,
                20.0,
                Color::from_rgba(255, 210, 120, 255),
            );
        }
    }

    pub fn is_solved(&self) -> bool {
        self.crystals.iter().all(|crystal| crystal.collected)
    }
}
