use crate::ui_text::{draw_game_text, draw_wrapped_game_text, measure_game_text};
use ::rand::random;
use macroquad::prelude::*;

use crate::game_state::{GameProgress, GameState};

use super::Scene;

pub struct MenuScene {
    progress: GameProgress,
    selected_option: usize,
    options: Vec<String>,
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
            options: vec![
                "Играть".to_string(),
                "Новая игра".to_string(),
                "Сюжет".to_string(),
                "Выход".to_string(),
            ],
            next_state: None,
            animation_time: 0.0,
            particles: Vec::new(),
            story_overlay_open: false,
            reset_confirm_open: false,
        }
    }

    fn draw_gradient_background(&self) {
        let colors = [
            Color::from_rgba(2, 4, 10, 255),
            Color::from_rgba(14, 8, 22, 255),
            Color::from_rgba(34, 10, 20, 255),
            Color::from_rgba(10, 4, 10, 255),
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

        for stripe in 0..26 {
            let y = 12.0 + stripe as f32 * 22.0;
            draw_rectangle(
                0.0,
                y,
                screen_width(),
                1.0,
                Color::from_rgba(255, 255, 255, 8),
            );
        }

        draw_circle(
            screen_width() * 0.77 + 14.0,
            108.0,
            132.0,
            Color::from_rgba(214, 36, 72, 30),
        );
        draw_circle(
            screen_width() * 0.77,
            118.0,
            78.0,
            Color::from_rgba(252, 194, 108, 24),
        );
        draw_circle(
            screen_width() * 0.77,
            118.0,
            40.0,
            Color::from_rgba(255, 238, 196, 42),
        );
    }

    fn draw_particles(&self) {
        for (index, p) in self.particles.iter().enumerate() {
            let alpha = p.life / 100.0;
            let tint = if index % 3 == 0 {
                Color::new(1.0, 0.34, 0.46, alpha * 0.75)
            } else if index % 3 == 1 {
                Color::new(1.0, 0.86, 0.48, alpha * 0.65)
            } else {
                Color::new(0.52, 0.82, 1.0, alpha * 0.55)
            };
            let color = tint;
            draw_circle(p.x, p.y, p.size, color);
        }
    }

    fn draw_backdrop(&self) {
        let pulse = (self.animation_time * 1.2).sin() * 0.5 + 0.5;
        draw_circle(
            640.0,
            108.0,
            96.0 + pulse * 14.0,
            Color::from_rgba(220, 48, 82, (26.0 + pulse * 16.0) as u8),
        );
        draw_circle(640.0, 108.0, 54.0, Color::from_rgba(255, 222, 146, 172));
        draw_circle(640.0, 108.0, 26.0, Color::from_rgba(255, 244, 210, 255));

        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            154.0,
            Color::from_rgba(0, 0, 0, 74),
        );
        draw_rectangle(
            0.0,
            screen_height() - 128.0,
            screen_width(),
            128.0,
            Color::from_rgba(8, 0, 8, 92),
        );

        for i in 0..7 {
            let width = 92.0 + i as f32 * 26.0;
            let height = 110.0 + (i % 3) as f32 * 38.0;
            let x = -10.0 + i as f32 * 122.0;
            let y = 420.0 - height;
            draw_rectangle(x, y, width, height, Color::from_rgba(10, 12, 20, 228));
            draw_rectangle(
                x + width * 0.3,
                y - 38.0,
                26.0,
                38.0,
                Color::from_rgba(14, 18, 28, 236),
            );
            draw_rectangle(
                x + width * 0.62,
                y - 28.0,
                18.0,
                28.0,
                Color::from_rgba(12, 14, 24, 236),
            );
        }

        draw_triangle(
            vec2(0.0, 520.0),
            vec2(236.0, 248.0),
            vec2(460.0, 520.0),
            Color::from_rgba(16, 24, 34, 228),
        );
        draw_triangle(
            vec2(300.0, 520.0),
            vec2(554.0, 206.0),
            vec2(800.0, 520.0),
            Color::from_rgba(12, 18, 28, 232),
        );
        draw_triangle(
            vec2(520.0, 520.0),
            vec2(734.0, 250.0),
            vec2(840.0, 520.0),
            Color::from_rgba(16, 18, 30, 234),
        );

        let frame = Rect::new(58.0, 54.0, screen_width() - 116.0, screen_height() - 106.0);
        draw_rectangle_lines(
            frame.x,
            frame.y,
            frame.w,
            frame.h,
            2.0,
            Color::from_rgba(122, 82, 90, 144),
        );
    }

    fn draw_chapter_card(&self) {
        let chapter = if self.progress.is_expedition_complete() {
            "CHAPTER // FINALE"
        } else if self.has_progress() {
            "CHAPTER // RESUME"
        } else {
            "CHAPTER // DESCENT"
        };
        let card = Rect::new(78.0, 66.0, 214.0, 54.0);
        draw_rectangle(
            card.x,
            card.y,
            card.w,
            card.h,
            Color::from_rgba(14, 10, 16, 228),
        );
        draw_rectangle_lines(
            card.x,
            card.y,
            card.w,
            card.h,
            2.0,
            Color::from_rgba(220, 92, 118, 200),
        );
        draw_game_text(
            chapter,
            card.x + 18.0,
            card.y + 21.0,
            18.0,
            Color::from_rgba(255, 216, 154, 255),
        );
        draw_game_text(
            "ПЕЧАТИ ЭЛЬДОРАДО",
            card.x + 18.0,
            card.y + 40.0,
            14.0,
            Color::from_rgba(198, 204, 224, 255),
        );
    }

    fn option_hint(&self, index: usize) -> &'static str {
        match index {
            0 => {
                if self.has_progress() {
                    "Продолжить текущую экспедицию с уже найденным прогрессом."
                } else {
                    "Отправиться в город и начать цепочку испытаний."
                }
            }
            1 => "Стереть сохранение и начать прохождение заново.",
            2 => "Показать краткую предысторию о шести печатях Элдорадо.",
            3 => "Закрыть игру.",
            _ => "",
        }
    }

    fn has_progress(&self) -> bool {
        self.progress.completed_count() > 0 || self.progress.opened_count() > 0
    }

    fn refresh_options(&mut self) {
        self.options[0] = if self.has_progress() {
            "Продолжить".to_string()
        } else {
            "Играть".to_string()
        };
    }

    fn objective_label(&self) -> &'static str {
        if self.progress.is_expedition_complete() {
            return "Экспедиция завершена";
        }

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
        self.refresh_options();

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
        self.refresh_options();

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
        self.draw_chapter_card();

        let title = "ELDORADO";
        let title_size = 68.0;
        let title_width = measure_game_text(title, None, title_size as u16, 1.0).width;

        draw_game_text(
            title,
            screen_width() / 2.0 - title_width / 2.0 + 3.0,
            152.0,
            title_size,
            Color::from_rgba(10, 0, 10, 255),
        );
        draw_game_text(
            title,
            screen_width() / 2.0 - title_width / 2.0,
            148.0,
            title_size,
            Color::from_rgba(255, 240, 206, 255),
        );
        let subtitle_title = "DESCENT OF SIX SEALS";
        let sub_width = measure_game_text(subtitle_title, None, 24, 1.0).width;
        draw_game_text(
            subtitle_title,
            screen_width() / 2.0 - sub_width / 2.0,
            184.0,
            24.0,
            Color::from_rgba(230, 110, 126, 255),
        );

        let subtitle = "Шесть печатей держат город над бездной";
        let subtitle_size = 22.0;
        let subtitle_width = measure_game_text(subtitle, None, subtitle_size as u16, 1.0).width;
        draw_game_text(
            subtitle,
            screen_width() / 2.0 - subtitle_width / 2.0,
            214.0,
            subtitle_size,
            Color::from_rgba(214, 214, 222, 255),
        );

        draw_wrapped_game_text(
            "Спуск начинается в тихой деревне и уходит всё глубже. Каждый решённый зал открывает следующий, а старые механизмы можно обойти рычагом.",
            118.0,
            246.0,
            screen_width() - 236.0,
            18.0,
            4.0,
            Color::from_rgba(204, 210, 226, 255),
        );

        let progress_panel = Rect::new(92.0, 284.0, screen_width() - 184.0, 72.0);
        draw_rectangle(
            progress_panel.x,
            progress_panel.y,
            progress_panel.w,
            progress_panel.h,
            Color::from_rgba(8, 10, 18, 228),
        );
        draw_rectangle(
            progress_panel.x + 8.0,
            progress_panel.y + 8.0,
            progress_panel.w - 16.0,
            progress_panel.h - 16.0,
            Color::from_rgba(24, 10, 18, 190),
        );
        draw_rectangle_lines(
            progress_panel.x,
            progress_panel.y,
            progress_panel.w,
            progress_panel.h,
            3.0,
            Color::from_rgba(196, 88, 110, 186),
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
            progress_panel.y + 30.0,
            progress_panel.w - 32.0,
            17.0,
            3.0,
            Color::from_rgba(232, 232, 236, 255),
        );
        let save_badge = if self.has_progress() {
            "Сохранение найдено"
        } else {
            "Новый старт"
        };
        let badge_width = measure_game_text(save_badge, None, 16, 1.0).width;
        draw_game_text(
            save_badge,
            progress_panel.x + progress_panel.w - badge_width - 18.0,
            progress_panel.y - 8.0,
            16.0,
            if self.has_progress() {
                Color::from_rgba(255, 214, 126, 255)
            } else {
                Color::from_rgba(220, 104, 128, 255)
            },
        );
        if self.progress.is_expedition_complete() {
            draw_game_text(
                "Финал открыт",
                progress_panel.x + 16.0,
                progress_panel.y - 6.0,
                16.0,
                Color::from_rgba(164, 246, 182, 255),
            );
        }

        let menu_start_y = 410.0;
        let option_height = 68.0;

        for (i, option) in self.options.iter().enumerate() {
            let y = menu_start_y + i as f32 * option_height;
            let is_selected = i == self.selected_option;
            let bg_color = if is_selected {
                Color::from_rgba(110, 26, 44, 242)
            } else {
                Color::from_rgba(16, 18, 28, 208)
            };

            let rect_width = 520.0;
            let rect_x = 112.0;

            draw_rectangle(rect_x, y - 38.0, rect_width, 60.0, bg_color);
            draw_rectangle(
                rect_x + 8.0,
                y - 30.0,
                rect_width - 16.0,
                44.0,
                if is_selected {
                    Color::from_rgba(136, 44, 64, 196)
                } else {
                    Color::from_rgba(22, 24, 36, 154)
                },
            );

            let border_color = if is_selected {
                Color::from_rgba(255, 222, 176, 255)
            } else {
                Color::from_rgba(116, 90, 104, 220)
            };
            draw_rectangle_lines(rect_x, y - 38.0, rect_width, 60.0, 2.0, border_color);

            let text_size = if is_selected { 34.0 } else { 29.0 };
            let text_color = if is_selected {
                Color::from_rgba(255, 244, 228, 255)
            } else {
                Color::from_rgba(194, 188, 194, 255)
            };

            draw_game_text(option, rect_x + 26.0, y - 2.0, text_size, text_color);
            draw_wrapped_game_text(
                self.option_hint(i),
                rect_x + 204.0,
                y + 1.0,
                rect_width - 236.0,
                15.0,
                3.0,
                Color::from_rgba(185, 198, 215, 255),
            );

            if is_selected {
                let pulse = (self.animation_time * 4.4).sin() * 0.5 + 0.5;
                let indicator_color = Color::new(1.0, 0.88, 0.62, 0.72 + pulse * 0.28);
                draw_rectangle(rect_x - 16.0, y - 38.0, 6.0, 60.0, indicator_color);
                draw_game_text(">", rect_x - 42.0, y + 1.0, 28.0, indicator_color);
            }
        }

        let hint = "↑↓ - выбор  |  ENTER - подтвердить  |  ESC - назад";
        let hint_size = 18.0;
        let hint_width = measure_game_text(hint, None, hint_size as u16, 1.0).width;
        draw_game_text(
            hint,
            screen_width() / 2.0 - hint_width / 2.0,
            screen_height() - 30.0,
            hint_size,
            Color::from_rgba(178, 160, 162, 255),
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
                Color::from_rgba(0, 0, 0, 236),
            );

            let panel = Rect::new(90.0, 90.0, screen_width() - 180.0, screen_height() - 180.0);
            draw_rectangle(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                Color::from_rgba(12, 10, 20, 255),
            );
            draw_rectangle(
                panel.x + 10.0,
                panel.y + 10.0,
                panel.w - 20.0,
                panel.h - 20.0,
                Color::from_rgba(30, 16, 22, 188),
            );
            draw_rectangle_lines(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                3.0,
                Color::from_rgba(220, 92, 118, 255),
            );

            draw_game_text(
                "Предыстория",
                panel.x + 26.0,
                panel.y + 44.0,
                34.0,
                Color::from_rgba(255, 234, 190, 255),
            );
            draw_wrapped_game_text(
                "Под Элдорадо скрыт механизм из шести печатей. Каждая печать удерживает один участок города от падения.",
                panel.x + 26.0,
                panel.y + 88.0,
                panel.w - 52.0,
                24.0,
                6.0,
                Color::from_rgba(246, 242, 238, 255),
            );
            draw_wrapped_game_text(
                "Чтобы добраться до ядра хранилища, придётся пройти все испытания по порядку: лабиринт, архив слов, зал памяти, галерею пар, мост над бездной и финальную комнату артефактов.",
                panel.x + 26.0,
                panel.y + 152.0,
                panel.w - 52.0,
                22.0,
                6.0,
                Color::from_rgba(204, 208, 218, 255),
            );
            draw_wrapped_game_text(
                "После первой победы на уровне появляется рычаг, который отключает механизм для повторных посещений.",
                panel.x + 26.0,
                panel.y + 248.0,
                panel.w - 52.0,
                22.0,
                6.0,
                Color::from_rgba(204, 208, 218, 255),
            );
            draw_game_text(
                "ENTER или ESC - закрыть",
                panel.x + 26.0,
                panel.y + panel.h - 28.0,
                20.0,
                Color::from_rgba(255, 214, 126, 255),
            );
        }

        if self.reset_confirm_open {
            draw_rectangle(
                0.0,
                0.0,
                screen_width(),
                screen_height(),
                Color::from_rgba(0, 0, 0, 218),
            );
            let panel = Rect::new(150.0, 180.0, screen_width() - 300.0, 190.0);
            draw_rectangle(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                Color::from_rgba(18, 8, 12, 250),
            );
            draw_rectangle(
                panel.x + 10.0,
                panel.y + 10.0,
                panel.w - 20.0,
                panel.h - 20.0,
                Color::from_rgba(44, 16, 22, 188),
            );
            draw_rectangle_lines(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                3.0,
                Color::from_rgba(232, 114, 96, 255),
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
