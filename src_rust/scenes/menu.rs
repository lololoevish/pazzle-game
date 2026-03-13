use crate::ui_text::{draw_game_text, draw_wrapped_game_text, measure_game_text};
use ::rand::random;
use macroquad::prelude::*;

use crate::game_state::{GameProgress, GameState};

use super::Scene;

pub struct MenuScene {
    progress: GameProgress,
    selected_option: usize,
    options: Vec<&'static str>,
    next_state: Option<GameState>,
    animation_time: f32,
    particles: Vec<Particle>,
    story_overlay_open: bool,
    reset_confirm_open: bool,
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
    pub fn new(progress: GameProgress) -> Self {
        Self {
            progress,
            selected_option: 0,
            options: vec!["Играть", "Новая игра", "Сюжет", "Выход"],
            next_state: None,
            animation_time: 0.0,
            particles: Vec::new(),
            story_overlay_open: false,
            reset_confirm_open: false,
        }
    }

    fn draw_gradient_background(&self) {
        let colors = [
            Color::from_rgba(12, 20, 36, 255),
            Color::from_rgba(28, 18, 48, 255),
            Color::from_rgba(48, 34, 68, 255),
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

    fn draw_backdrop(&self) {
        draw_circle(640.0, 110.0, 58.0, Color::from_rgba(255, 228, 160, 55));
        draw_circle(640.0, 110.0, 42.0, Color::from_rgba(255, 228, 160, 185));

        for i in 0..6 {
            let width = 110.0 + i as f32 * 18.0;
            let height = 90.0 + (i % 3) as f32 * 30.0;
            let x = 30.0 + i as f32 * 120.0;
            let y = 420.0 - height;
            draw_rectangle(x, y, width, height, Color::from_rgba(22, 28, 42, 210));
            draw_rectangle(
                x + width * 0.3,
                y - 25.0,
                24.0,
                25.0,
                Color::from_rgba(28, 34, 50, 220),
            );
        }

        draw_triangle(
            vec2(0.0, 520.0),
            vec2(260.0, 290.0),
            vec2(460.0, 520.0),
            Color::from_rgba(28, 42, 54, 220),
        );
        draw_triangle(
            vec2(300.0, 520.0),
            vec2(560.0, 250.0),
            vec2(800.0, 520.0),
            Color::from_rgba(24, 34, 46, 220),
        );
    }

    fn option_hint(&self, index: usize) -> &'static str {
        match index {
            0 => "Отправиться в город и начать цепочку испытаний.",
            1 => "Стереть сохранение и начать прохождение заново.",
            2 => "Показать краткую предысторию о шести печатях Элдорадо.",
            3 => "Закрыть игру.",
            _ => "",
        }
    }

    fn objective_label(&self) -> &'static str {
        match self.progress.current_objective_level() {
            1 => "Лабиринт молчаливых стен",
            2 => "Архивная пещера печатей",
            3 => "Грот часовщика",
            4 => "Галерея зеркального эха",
            5 => "Разлом кристаллов",
            6 => "Ядро глубинного хранилища",
            _ => "Неизвестная цель",
        }
    }
}

impl Scene for MenuScene {
    fn handle_input(&mut self) {
        if self.reset_confirm_open {
            if is_key_pressed(KeyCode::Escape) {
                self.reset_confirm_open = false;
            }
            if is_key_pressed(KeyCode::Enter) || is_key_pressed(KeyCode::Space) {
                self.next_state = Some(GameState::ResetGame);
            }
            return;
        }

        if self.story_overlay_open {
            if is_key_pressed(KeyCode::Escape)
                || is_key_pressed(KeyCode::Enter)
                || is_key_pressed(KeyCode::Space)
            {
                self.story_overlay_open = false;
            }
            return;
        }

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
                1 => self.reset_confirm_open = true,
                2 => self.story_overlay_open = true,
                3 => self.next_state = Some(GameState::Quit),
                _ => {}
            }
        }
    }

    fn update(&mut self) {
        self.animation_time += get_frame_time();

        if random::<f32>() < 0.1 {
            self.particles.push(Particle {
                x: random::<f32>() * screen_width(),
                y: screen_height() + 10.0,
                vx: (random::<f32>() - 0.5) * 2.0,
                vy: -random::<f32>() * 3.0 - 1.0,
                life: 100.0,
                size: random::<f32>() * 3.0 + 2.0,
            });
        }

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
        self.draw_backdrop();

        let title = "ELDORADO PUZZLE";
        let title_size = 50.0;
        let title_width = measure_game_text(title, None, title_size as u16, 1.0).width;

        draw_game_text(
            title,
            screen_width() / 2.0 - title_width / 2.0 + 3.0,
            138.0,
            title_size,
            Color::from_rgba(20, 10, 30, 255),
        );
        draw_game_text(
            title,
            screen_width() / 2.0 - title_width / 2.0,
            135.0,
            title_size,
            Color::from_rgba(255, 215, 0, 255),
        );

        let subtitle = "Город шести печатей и древних механизмов";
        let subtitle_size = 24.0;
        let subtitle_width = measure_game_text(subtitle, None, subtitle_size as u16, 1.0).width;
        draw_game_text(
            subtitle,
            screen_width() / 2.0 - subtitle_width / 2.0,
            170.0,
            subtitle_size,
            Color::from_rgba(200, 180, 150, 255),
        );

        draw_wrapped_game_text(
            "Каждый пройденный уровень открывает путь к следующему. Повторно пройденные печати можно отключать рычагом.",
            65.0,
            210.0,
            screen_width() - 130.0,
            20.0,
            4.0,
            Color::from_rgba(184, 203, 228, 255),
        );

        let progress_panel = Rect::new(88.0, 236.0, screen_width() - 176.0, 50.0);
        draw_rectangle(
            progress_panel.x,
            progress_panel.y,
            progress_panel.w,
            progress_panel.h,
            Color::from_rgba(12, 18, 30, 170),
        );
        draw_rectangle_lines(
            progress_panel.x,
            progress_panel.y,
            progress_panel.w,
            progress_panel.h,
            2.0,
            Color::from_rgba(112, 170, 214, 126),
        );
        let progress_text = format!(
            "Открыто печатей: {}/6 | Решено головоломок: {}/6 | Текущая цель: {}",
            self.progress.opened_count(),
            self.progress.completed_count(),
            self.objective_label()
        );
        draw_wrapped_game_text(
            &progress_text,
            progress_panel.x + 16.0,
            progress_panel.y + 20.0,
            progress_panel.w - 32.0,
            17.0,
            3.0,
            Color::from_rgba(226, 232, 240, 255),
        );

        let menu_start_y = 316.0;
        let option_height = 70.0;

        for (i, option) in self.options.iter().enumerate() {
            let y = menu_start_y + i as f32 * option_height;
            let is_selected = i == self.selected_option;
            let bg_color = if is_selected {
                Color::from_rgba(80, 100, 140, 200)
            } else {
                Color::from_rgba(40, 50, 70, 150)
            };

            let rect_width = 420.0;
            let rect_x = screen_width() / 2.0 - rect_width / 2.0;

            draw_rectangle(rect_x, y - 35.0, rect_width, 56.0, bg_color);

            let border_color = if is_selected {
                Color::from_rgba(150, 200, 255, 255)
            } else {
                Color::from_rgba(100, 120, 150, 255)
            };
            draw_rectangle_lines(rect_x, y - 35.0, rect_width, 56.0, 2.0, border_color);

            let text_size = if is_selected { 35.0 } else { 30.0 };
            let text_color = if is_selected {
                Color::from_rgba(255, 255, 255, 255)
            } else {
                Color::from_rgba(180, 180, 180, 255)
            };

            let text_width = measure_game_text(option, None, text_size as u16, 1.0).width;
            draw_game_text(
                option,
                screen_width() / 2.0 - text_width / 2.0,
                y - 3.0,
                text_size,
                text_color,
            );
            draw_game_text(
                self.option_hint(i),
                rect_x + 18.0,
                y + 18.0,
                16.0,
                Color::from_rgba(185, 198, 215, 255),
            );

            if is_selected {
                let pulse = (self.animation_time * 3.0).sin() * 0.3 + 0.7;
                let indicator_color = Color::new(1.0, 1.0, 0.4, pulse);
                draw_game_text("►", rect_x - 30.0, y, 30.0, indicator_color);
                draw_game_text("◄", rect_x + rect_width + 10.0, y, 30.0, indicator_color);
            }
        }

        let hint = "↑↓ - выбор, ENTER - подтвердить";
        let hint_size = 18.0;
        let hint_width = measure_game_text(hint, None, hint_size as u16, 1.0).width;
        draw_game_text(
            hint,
            screen_width() / 2.0 - hint_width / 2.0,
            screen_height() - 30.0,
            hint_size,
            Color::from_rgba(150, 150, 150, 255),
        );

        draw_game_text(
            "v1.3.0-dev (Rust Edition)",
            10.0,
            screen_height() - 10.0,
            16.0,
            Color::from_rgba(100, 100, 100, 255),
        );

        if self.story_overlay_open {
            draw_rectangle(
                0.0,
                0.0,
                screen_width(),
                screen_height(),
                Color::from_rgba(2, 4, 10, 242),
            );

            let panel = Rect::new(90.0, 90.0, screen_width() - 180.0, screen_height() - 180.0);
            draw_rectangle(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                Color::from_rgba(10, 16, 30, 255),
            );
            draw_rectangle_lines(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                3.0,
                Color::from_rgba(255, 214, 126, 255),
            );

            draw_game_text(
                "Предыстория",
                panel.x + 26.0,
                panel.y + 44.0,
                34.0,
                Color::from_rgba(255, 230, 180, 255),
            );
            draw_wrapped_game_text(
                "Под Элдорадо скрыт механизм из шести печатей. Каждая печать удерживает один участок города от падения.",
                panel.x + 26.0,
                panel.y + 88.0,
                panel.w - 52.0,
                24.0,
                6.0,
                WHITE,
            );
            draw_wrapped_game_text(
                "Чтобы добраться до ядра хранилища, придётся пройти все испытания по порядку: лабиринт, архив слов, зал памяти, галерею пар, мост над бездной и финальную комнату артефактов.",
                panel.x + 26.0,
                panel.y + 152.0,
                panel.w - 52.0,
                22.0,
                6.0,
                LIGHTGRAY,
            );
            draw_wrapped_game_text(
                "После первой победы на уровне появляется рычаг, который отключает механизм для повторных посещений.",
                panel.x + 26.0,
                panel.y + 248.0,
                panel.w - 52.0,
                22.0,
                6.0,
                LIGHTGRAY,
            );
            draw_game_text(
                "ENTER или ESC - закрыть",
                panel.x + 26.0,
                panel.y + panel.h - 28.0,
                20.0,
                Color::from_rgba(120, 210, 255, 255),
            );
        }

        if self.reset_confirm_open {
            draw_rectangle(
                0.0,
                0.0,
                screen_width(),
                screen_height(),
                Color::from_rgba(0, 0, 0, 190),
            );
            let panel = Rect::new(150.0, 180.0, screen_width() - 300.0, 190.0);
            draw_rectangle(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                Color::from_rgba(22, 16, 18, 250),
            );
            draw_rectangle_lines(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                3.0,
                Color::from_rgba(220, 110, 90, 255),
            );
            draw_game_text(
                "Новая игра",
                panel.x + 24.0,
                panel.y + 40.0,
                32.0,
                Color::from_rgba(255, 220, 190, 255),
            );
            draw_wrapped_game_text(
                "Текущее сохранение будет стёрто. Прогресс по уровням, рычагам и маршруту пещер начнётся заново.",
                panel.x + 24.0,
                panel.y + 82.0,
                panel.w - 48.0,
                20.0,
                5.0,
                WHITE,
            );
            draw_game_text(
                "ENTER - подтвердить, ESC - отмена",
                panel.x + 24.0,
                panel.y + panel.h - 22.0,
                18.0,
                Color::from_rgba(255, 204, 120, 255),
            );
        }
    }

    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }
}
