use macroquad::prelude::*;

use crate::audio;
use crate::game_state::{GameProgress, GameState};
use crate::ui_text::{draw_game_text, draw_wrapped_game_text, measure_game_text};
use crate::visual_assets::{draw_sprite, item_texture};

use super::Scene;

pub struct VictoryScene {
    progress: GameProgress,
    next_state: Option<GameState>,
    animation_time: f32,
}

impl VictoryScene {
    pub fn new(progress: GameProgress) -> Self {
        Self {
            progress,
            next_state: None,
            animation_time: 0.0,
        }
    }

    fn draw_background(&self) {
        let pulse = (self.animation_time * 1.6).sin() * 0.5 + 0.5;
        for i in 0..screen_height() as i32 {
            let t = i as f32 / screen_height();
            let color = Color::new(0.02 + t * 0.06, 0.02 + t * 0.04, 0.06 + t * 0.18, 1.0);
            draw_line(0.0, i as f32, screen_width(), i as f32, 1.0, color);
        }

        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            158.0,
            Color::from_rgba(0, 0, 0, 70),
        );
        draw_circle(
            screen_width() * 0.5,
            108.0,
            124.0 + pulse * 26.0,
            Color::from_rgba(255, 120, 120, (24.0 + pulse * 18.0) as u8),
        );
        draw_circle(
            screen_width() * 0.5,
            118.0,
            78.0,
            Color::from_rgba(255, 214, 128, 60),
        );
        draw_circle(
            screen_width() * 0.5,
            118.0,
            54.0,
            Color::from_rgba(255, 236, 176, 192),
        );

        for idx in 0..7 {
            let x = 28.0 + idx as f32 * 116.0;
            let height = 130.0 + (idx % 3) as f32 * 28.0;
            draw_triangle(
                vec2(x, 520.0),
                vec2(x + 86.0, 520.0),
                vec2(x + 43.0, 520.0 - height),
                Color::from_rgba(20, 28, 38, 220),
            );
        }

        for ring in 0..6 {
            let radius = 96.0 + ring as f32 * 34.0 + pulse * 12.0;
            draw_circle_lines(
                screen_width() * 0.5,
                262.0,
                radius,
                2.0,
                Color::from_rgba(120, 192, 255, 24 + ring as u8 * 12),
            );
        }

        draw_triangle(
            vec2(-20.0, 520.0),
            vec2(190.0, 188.0),
            vec2(398.0, 520.0),
            Color::from_rgba(18, 24, 34, 228),
        );
        draw_triangle(
            vec2(318.0, 520.0),
            vec2(556.0, 166.0),
            vec2(840.0, 520.0),
            Color::from_rgba(14, 18, 28, 236),
        );
    }

    fn draw_summary_panel(&self) {
        let panel = Rect::new(86.0, 164.0, screen_width() - 172.0, 326.0);
        draw_rectangle(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            Color::from_rgba(8, 10, 18, 238),
        );
        draw_rectangle(
            panel.x + 10.0,
            panel.y + 10.0,
            panel.w - 20.0,
            panel.h - 20.0,
            Color::from_rgba(26, 16, 22, 192),
        );
        draw_rectangle_lines(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            3.0,
            Color::from_rgba(255, 216, 128, 235),
        );
        draw_game_text(
            "CHAPTER // FINALE COMPLETE",
            panel.x + 30.0,
            panel.y + 24.0,
            18.0,
            Color::from_rgba(255, 210, 132, 255),
        );

        let title = "Ядро раскрыто";
        let title_width = measure_game_text(title, None, 38, 1.0).width;
        draw_game_text(
            title,
            panel.x + panel.w / 2.0 - title_width / 2.0,
            panel.y + 58.0,
            38.0,
            Color::from_rgba(255, 236, 184, 255),
        );

        draw_wrapped_game_text(
            "Шестая печать сорвана, рычаг ядра переведён, и цепочка пещер под Элдорадо больше не держит город в древнем замке.",
            panel.x + 32.0,
            panel.y + 108.0,
            panel.w - 64.0,
            24.0,
            6.0,
            Color::from_rgba(232, 238, 246, 255),
        );
        draw_wrapped_game_text(
            "Экспедиция завершена полностью: теперь можно вернуться в деревню, заново пройти любимые печати или начать новое прохождение из главного меню.",
            panel.x + 32.0,
            panel.y + 186.0,
            panel.w - 64.0,
            20.0,
            5.0,
            Color::from_rgba(194, 210, 228, 255),
        );

        let stats = format!(
            "Открыто печатей: {}/6   |   Решено головоломок: {}/6",
            self.progress.opened_count(),
            self.progress.completed_count()
        );
        let stats_width = measure_game_text(&stats, None, 18, 1.0).width;
        draw_game_text(
            &stats,
            panel.x + panel.w / 2.0 - stats_width / 2.0,
            panel.y + 278.0,
            18.0,
            Color::from_rgba(132, 212, 255, 255),
        );

        let rewards = format!(
            "Побочные награды: {} / 3",
            self.progress.is_elder_trial_completed() as u8
                + self.progress.is_mechanic_training_completed() as u8
                + self.progress.is_archivist_quiz_completed() as u8
        );
        let rewards_width = measure_game_text(&rewards, None, 18, 1.0).width;
        draw_game_text(
            &rewards,
            panel.x + panel.w / 2.0 - rewards_width / 2.0,
            panel.y + 304.0,
            18.0,
            Color::from_rgba(184, 236, 196, 255),
        );

        draw_game_text(
            "ENTER - в деревню, ESC - в меню",
            panel.x + 32.0,
            panel.y + panel.h - 26.0,
            18.0,
            Color::from_rgba(255, 206, 122, 255),
        );
    }
}

impl Scene for VictoryScene {
    fn handle_input(&mut self) {
        if is_key_pressed(KeyCode::Enter) || is_key_pressed(KeyCode::Space) {
            audio::play_ui_confirm();
            self.next_state = Some(GameState::Town);
        }

        if is_key_pressed(KeyCode::Escape) {
            audio::play_ui_cancel();
            self.next_state = Some(GameState::Menu);
        }
    }

    fn update(&mut self) {
        self.animation_time += get_frame_time();
    }

    fn draw(&self) {
        self.draw_background();

        let relic = item_texture();
        let pulse = (self.animation_time * 2.2).sin() * 0.5 + 0.5;
        for idx in 0..6 {
            let x = 136.0 + idx as f32 * 92.0;
            let y = 112.0 + (idx % 2) as f32 * 18.0;
            draw_circle(
                x + 22.0,
                y + 22.0,
                24.0 + pulse * 8.0,
                Color::from_rgba(112, 198, 255, (28.0 + pulse * 18.0) as u8),
            );
            draw_sprite(&relic, x, y, 44.0, 44.0, WHITE);
        }

        let title = "ELDORADO";
        let title_width = measure_game_text(title, None, 62, 1.0).width;
        draw_game_text(
            title,
            screen_width() / 2.0 - title_width / 2.0,
            132.0,
            62.0,
            Color::from_rgba(255, 240, 204, 255),
        );

        self.draw_summary_panel();
    }

    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }
}
