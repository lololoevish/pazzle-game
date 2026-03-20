use crate::audio;
use crate::ui_text::{draw_game_text, measure_game_text};
use macroquad::prelude::*;

struct Hazard {
    rect: Rect,
    velocity: Vec2,
}

struct Artifact {
    pos: Vec2,
    collected: bool,
}

pub struct FinalChallengePuzzle {
    player: Rect,
    spawn: Vec2,
    hazards: Vec<Hazard>,
    artifacts: Vec<Artifact>,
    time_left: f32,
    failed: bool,
    hit_cooldown: f32,
}

impl FinalChallengePuzzle {
    pub fn new() -> Self {
        let mut puzzle = Self {
            player: Rect::new(70.0, 500.0, 28.0, 28.0),
            spawn: vec2(70.0, 500.0),
            hazards: vec![
                Hazard {
                    rect: Rect::new(130.0, 130.0, 70.0, 18.0),
                    velocity: vec2(180.0, 0.0),
                },
                Hazard {
                    rect: Rect::new(520.0, 210.0, 18.0, 70.0),
                    velocity: vec2(0.0, 170.0),
                },
                Hazard {
                    rect: Rect::new(210.0, 360.0, 80.0, 18.0),
                    velocity: vec2(-210.0, 0.0),
                },
                Hazard {
                    rect: Rect::new(620.0, 420.0, 18.0, 80.0),
                    velocity: vec2(0.0, -190.0),
                },
            ],
            artifacts: vec![
                Artifact {
                    pos: vec2(150.0, 90.0),
                    collected: false,
                },
                Artifact {
                    pos: vec2(660.0, 150.0),
                    collected: false,
                },
                Artifact {
                    pos: vec2(240.0, 300.0),
                    collected: false,
                },
                Artifact {
                    pos: vec2(620.0, 500.0),
                    collected: false,
                },
            ],
            time_left: 45.0,
            failed: false,
            hit_cooldown: 0.0,
        };
        puzzle.reset();
        puzzle
    }

    fn reset(&mut self) {
        self.player.x = self.spawn.x;
        self.player.y = self.spawn.y;
        self.time_left = 45.0;
        self.failed = false;
        self.hit_cooldown = 0.0;
        for artifact in &mut self.artifacts {
            artifact.collected = false;
        }
        self.hazards[0].rect.x = 130.0;
        self.hazards[1].rect.y = 210.0;
        self.hazards[2].rect.x = 210.0;
        self.hazards[3].rect.y = 420.0;
    }

    pub fn handle_input(&mut self) {
        if self.failed {
            if is_key_pressed(KeyCode::R) {
                audio::play_ui_confirm();
                self.reset();
            }
            return;
        }

        let dt = get_frame_time();
        let speed = 220.0 * dt;
        if is_key_down(KeyCode::A) || is_key_down(KeyCode::Left) {
            self.player.x -= speed;
        }
        if is_key_down(KeyCode::D) || is_key_down(KeyCode::Right) {
            self.player.x += speed;
        }
        if is_key_down(KeyCode::W) || is_key_down(KeyCode::Up) {
            self.player.y -= speed;
        }
        if is_key_down(KeyCode::S) || is_key_down(KeyCode::Down) {
            self.player.y += speed;
        }

        self.player.x = self
            .player
            .x
            .clamp(20.0, screen_width() - self.player.w - 20.0);
        self.player.y = self
            .player
            .y
            .clamp(80.0, screen_height() - self.player.h - 30.0);
    }

    pub fn update(&mut self) {
        if self.failed || self.is_solved() {
            return;
        }

        let dt = get_frame_time();
        if self.hit_cooldown > 0.0 {
            self.hit_cooldown -= dt;
        }
        self.time_left -= dt;
        if self.time_left <= 0.0 {
            self.time_left = 0.0;
            self.failed = true;
            audio::play_ui_cancel();
            return;
        }

        for hazard in &mut self.hazards {
            hazard.rect.x += hazard.velocity.x * dt;
            hazard.rect.y += hazard.velocity.y * dt;

            if hazard.rect.x <= 20.0 || hazard.rect.x + hazard.rect.w >= screen_width() - 20.0 {
                hazard.velocity.x *= -1.0;
            }
            if hazard.rect.y <= 90.0 || hazard.rect.y + hazard.rect.h >= screen_height() - 40.0 {
                hazard.velocity.y *= -1.0;
            }

            if self.hit_cooldown <= 0.0 && hazard.rect.overlaps(&self.player) {
                self.player.x = self.spawn.x;
                self.player.y = self.spawn.y;
                self.hit_cooldown = 1.0;
                audio::play_ui_cancel();
            }
        }

        let player_center = vec2(
            self.player.x + self.player.w / 2.0,
            self.player.y + self.player.h / 2.0,
        );
        for artifact in &mut self.artifacts {
            if !artifact.collected && artifact.pos.distance(player_center) < 24.0 {
                artifact.collected = true;
                audio::play_ui_success();
            }
        }
    }

    pub fn draw(&self) {
        let arena = Rect::new(20.0, 90.0, screen_width() - 40.0, screen_height() - 130.0);
        draw_rectangle_lines(
            arena.x,
            arena.y,
            arena.w,
            arena.h,
            3.0,
            Color::from_rgba(255, 210, 120, 255),
        );

        draw_game_text(
            "Финал: соберите артефакты до конца времени",
            20.0,
            125.0,
            26.0,
            WHITE,
        );
        let timer_color = if self.time_left < 10.0 {
            RED
        } else {
            Color::from_rgba(255, 220, 130, 255)
        };
        draw_game_text(
            &format!("Таймер: {:.0}", self.time_left.ceil()),
            screen_width() - 160.0,
            125.0,
            28.0,
            timer_color,
        );

        let collected = self
            .artifacts
            .iter()
            .filter(|artifact| artifact.collected)
            .count();
        draw_game_text(
            &format!("Артефакты: {}/{}", collected, self.artifacts.len()),
            20.0,
            152.0,
            20.0,
            LIGHTGRAY,
        );

        for hazard in &self.hazards {
            draw_rectangle(
                hazard.rect.x,
                hazard.rect.y,
                hazard.rect.w,
                hazard.rect.h,
                Color::from_rgba(190, 70, 70, 255),
            );
            draw_rectangle_lines(
                hazard.rect.x,
                hazard.rect.y,
                hazard.rect.w,
                hazard.rect.h,
                2.0,
                WHITE,
            );
        }

        for artifact in &self.artifacts {
            if artifact.collected {
                continue;
            }
            draw_poly(
                artifact.pos.x,
                artifact.pos.y,
                6,
                12.0,
                0.0,
                Color::from_rgba(255, 215, 0, 255),
            );
            draw_poly_lines(artifact.pos.x, artifact.pos.y, 6, 12.0, 0.0, 2.0, WHITE);
        }

        let player_color = if self.hit_cooldown > 0.0 {
            Color::from_rgba(255, 170, 120, 255)
        } else {
            Color::from_rgba(120, 190, 255, 255)
        };
        draw_rectangle(
            self.player.x,
            self.player.y,
            self.player.w,
            self.player.h,
            player_color,
        );
        draw_rectangle(self.player.x + 6.0, self.player.y + 6.0, 6.0, 6.0, WHITE);
        draw_rectangle(self.player.x + 16.0, self.player.y + 6.0, 6.0, 6.0, WHITE);

        if self.failed {
            let overlay = Color::from_rgba(0, 0, 0, 170);
            draw_rectangle(0.0, 0.0, screen_width(), screen_height(), overlay);
            let text = "Время вышло";
            let width = measure_game_text(text, None, 46, 1.0).width;
            draw_game_text(
                text,
                screen_width() / 2.0 - width / 2.0,
                screen_height() / 2.0,
                46.0,
                RED,
            );
            let hint = "Нажмите R для рестарта";
            let hint_width = measure_game_text(hint, None, 24, 1.0).width;
            draw_game_text(
                hint,
                screen_width() / 2.0 - hint_width / 2.0,
                screen_height() / 2.0 + 40.0,
                24.0,
                WHITE,
            );
        } else {
            draw_game_text(
                "WASD/стрелки - движение, избегайте ловушек",
                20.0,
                screen_height() - 20.0,
                18.0,
                GRAY,
            );
            if self.hit_cooldown > 0.0 {
                draw_game_text(
                    "Столкновение: короткая передышка",
                    screen_width() - 290.0,
                    82.0,
                    20.0,
                    Color::from_rgba(255, 180, 140, 255),
                );
            }
        }
    }

    pub fn is_solved(&self) -> bool {
        self.artifacts.iter().all(|artifact| artifact.collected)
    }
}
