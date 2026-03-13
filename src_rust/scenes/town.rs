use macroquad::prelude::*;

use crate::game_state::{GameProgress, GameState, ProgressUpdate};

use super::Scene;

pub struct TownScene {
    selected_level: usize,
    progress: GameProgress,
    next_state: Option<GameState>,
    animation_time: f32,
    status_message: String,
    pending_progress_update: Option<ProgressUpdate>,
}

impl TownScene {
    pub fn new(progress: GameProgress) -> Self {
        Self {
            selected_level: 0,
            progress,
            next_state: None,
            animation_time: 0.0,
            status_message:
                "Идите по уровням по порядку. После первой победы можно опустить рычаг клавишей L."
                    .to_string(),
            pending_progress_update: None,
        }
    }

    fn get_level_info(&self, level: u8) -> (&'static str, &'static str, &'static str) {
        match level {
            1 => (
                "Подземелье I - Лабиринт",
                "Пройдите до красного выхода",
                "Скользящее движение до стены",
            ),
            2 => (
                "Подземелье II - Поиск слов",
                "Найдите все слова",
                "Архив открывает вторую печать",
            ),
            3 => (
                "Подземелье III - Память",
                "Повторите последовательность",
                "Часовой механизм проверяет ритм",
            ),
            4 => (
                "Подземелье IV - Пары",
                "Найдите одинаковые карточки",
                "Зеркала включают защиту ворот",
            ),
            5 => (
                "Подземелье V - Платформер",
                "Соберите кристаллы",
                "Над пропастью держат только прыжки",
            ),
            6 => (
                "Подземелье VI - Финал",
                "Соберите артефакты",
                "Последняя печать охраняет ядро",
            ),
            _ => ("Неизвестно", "", ""),
        }
    }

    fn draw_background(&self) {
        for i in 0..screen_height() as i32 {
            let t = i as f32 / screen_height();
            let color = Color::new(0.05 + t * 0.12, 0.10 + t * 0.18, 0.18 + t * 0.22, 1.0);
            draw_line(0.0, i as f32, screen_width(), i as f32, 1.0, color);
        }

        draw_circle(660.0, 100.0, 52.0, Color::from_rgba(255, 220, 150, 40));
        draw_circle(660.0, 100.0, 34.0, Color::from_rgba(255, 220, 150, 165));

        for idx in 0..5 {
            let x = 40.0 + idx as f32 * 150.0;
            let w = 90.0 + (idx % 2) as f32 * 20.0;
            let h = 90.0 + idx as f32 * 18.0;
            let y = 470.0 - h;
            draw_rectangle(x, y, w, h, Color::from_rgba(36, 42, 58, 220));
            draw_rectangle(
                x + w * 0.35,
                y - 24.0,
                16.0,
                24.0,
                Color::from_rgba(45, 51, 68, 220),
            );
        }

        let ground_y = screen_height() - 120.0;
        draw_rectangle(
            0.0,
            ground_y,
            screen_width(),
            120.0,
            Color::from_rgba(50, 39, 31, 255),
        );
        draw_rectangle(
            0.0,
            ground_y,
            screen_width(),
            14.0,
            Color::from_rgba(94, 67, 46, 255),
        );
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
                self.next_state = Some(GameState::Menu);
            } else {
                let level = (self.selected_level + 1) as u8;
                if self.progress.is_level_unlocked(level) {
                    self.next_state = Some(GameState::Playing(level));
                } else {
                    self.status_message = format!(
                        "Сначала завершите уровень {}, чтобы открыть следующий проход.",
                        level - 1
                    );
                }
            }
        }

        if self.selected_level < 6 && is_key_pressed(KeyCode::L) {
            let level = (self.selected_level + 1) as u8;
            if self.progress.can_use_lever(level) {
                let pulled = !self.progress.is_lever_pulled(level);
                self.progress.set_lever_pulled(level, pulled);
                self.pending_progress_update = Some(ProgressUpdate::LeverPulled { level, pulled });
                self.status_message = if pulled {
                    format!(
                        "Рычаг уровня {} опущен. Повторное посещение отключит головоломку.",
                        level
                    )
                } else {
                    format!("Рычаг уровня {} поднят. Испытание снова активно.", level)
                };
            } else {
                self.status_message =
                    "Рычаг появляется только после первого честного прохождения уровня."
                        .to_string();
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
        self.draw_background();

        let title = "ГОРОД ЭЛЬДОРАДО";
        let title_size = 48.0;
        let title_width = measure_text(title, None, title_size as u16, 1.0).width;
        draw_text(
            title,
            screen_width() / 2.0 - title_width / 2.0 + 3.0,
            53.0,
            title_size,
            Color::from_rgba(30, 20, 10, 255),
        );
        draw_text(
            title,
            screen_width() / 2.0 - title_width / 2.0,
            50.0,
            title_size,
            Color::from_rgba(255, 230, 180, 255),
        );

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

        draw_text(
            "Шесть печатей открываются только по порядку. Завершите уровень, затем при желании отключайте его рычагом.",
            40.0,
            102.0,
            18.0,
            Color::from_rgba(190, 205, 225, 255),
        );

        let start_y = 130.0;
        let item_height = 58.0;

        for i in 0..7 {
            let y = start_y + i as f32 * item_height;
            let is_selected = i == self.selected_level;
            let (name, desc, flavor) = if i < 6 {
                self.get_level_info((i + 1) as u8)
            } else {
                ("Вернуться в меню", "", "")
            };

            let is_unlocked = if i < 6 {
                self.progress.is_level_unlocked((i + 1) as u8)
            } else {
                true
            };

            let is_completed = if i < 6 {
                self.progress.is_level_completed((i + 1) as u8)
            } else {
                false
            };

            let lever_pulled = if i < 6 {
                self.progress.is_lever_pulled((i + 1) as u8)
            } else {
                false
            };

            let bg_color = if !is_unlocked {
                Color::from_rgba(50, 40, 40, 200)
            } else if is_selected {
                Color::from_rgba(60, 80, 100, 200)
            } else {
                Color::from_rgba(40, 50, 60, 180)
            };

            let rect_x = 50.0;
            let rect_width = 360.0;
            draw_rectangle(rect_x, y, rect_width, 52.0, bg_color);

            let border_color = if is_selected {
                Color::from_rgba(100, 150, 200, 255)
            } else {
                Color::from_rgba(80, 90, 100, 255)
            };
            draw_rectangle_lines(rect_x, y, rect_width, 52.0, 2.0, border_color);

            let status_x = rect_x + 20.0;
            if i < 6 {
                let (status_text, status_color) = if lever_pulled {
                    ("РЫЧАГ ОПУЩЕН", Color::from_rgba(255, 210, 120, 255))
                } else if is_completed {
                    ("ПРОЙДЕНО", Color::from_rgba(100, 200, 100, 255))
                } else if is_unlocked {
                    ("ДОСТУПНО", Color::from_rgba(100, 200, 100, 255))
                } else {
                    ("ЗАБЛОКИРОВАНО", Color::from_rgba(150, 50, 50, 255))
                };
                draw_text(status_text, status_x, y + 18.0, 14.0, status_color);
            }

            let text_color = if is_unlocked {
                Color::from_rgba(200, 200, 200, 255)
            } else {
                Color::from_rgba(120, 120, 120, 255)
            };
            draw_text(name, status_x, y + 36.0, 20.0, text_color);

            if !desc.is_empty() {
                draw_text(
                    desc,
                    status_x + 178.0,
                    y + 18.0,
                    14.0,
                    Color::from_rgba(145, 155, 170, 255),
                );
                draw_text(
                    flavor,
                    status_x + 178.0,
                    y + 37.0,
                    14.0,
                    Color::from_rgba(120, 130, 145, 255),
                );
            }
        }

        if self.selected_level < 6 {
            let level = (self.selected_level + 1) as u8;
            let (name, desc, flavor) = self.get_level_info(level);
            let panel = Rect::new(440.0, 165.0, 320.0, 250.0);
            draw_rectangle(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                Color::from_rgba(16, 24, 38, 220),
            );
            draw_rectangle_lines(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                3.0,
                Color::from_rgba(255, 210, 120, 220),
            );

            draw_text(
                name,
                panel.x + 20.0,
                panel.y + 38.0,
                24.0,
                Color::from_rgba(255, 228, 180, 255),
            );
            draw_text(desc, panel.x + 20.0, panel.y + 72.0, 20.0, WHITE);
            draw_text(flavor, panel.x + 20.0, panel.y + 102.0, 18.0, LIGHTGRAY);

            let unlock_text = if self.progress.is_level_unlocked(level) {
                "Проход открыт"
            } else {
                "Проход закрыт предыдущей печатью"
            };
            draw_text(
                unlock_text,
                panel.x + 20.0,
                panel.y + 142.0,
                20.0,
                Color::from_rgba(120, 210, 255, 255),
            );

            let lever_text = if self.progress.can_use_lever(level) {
                if self.progress.is_lever_pulled(level) {
                    "L - поднять рычаг и снова включить испытание"
                } else {
                    "L - опустить рычаг и отключить повторное испытание"
                }
            } else {
                "Рычаг появится после первого прохождения"
            };
            draw_text(
                lever_text,
                panel.x + 20.0,
                panel.y + 182.0,
                18.0,
                Color::from_rgba(255, 210, 120, 255),
            );
            draw_text(
                "ENTER - войти на уровень",
                panel.x + 20.0,
                panel.y + 214.0,
                18.0,
                WHITE,
            );
        }

        draw_rectangle(
            32.0,
            444.0,
            screen_width() - 64.0,
            70.0,
            Color::from_rgba(14, 18, 28, 180),
        );
        draw_rectangle_lines(
            32.0,
            444.0,
            screen_width() - 64.0,
            70.0,
            2.0,
            Color::from_rgba(100, 150, 200, 120),
        );
        draw_text(
            &self.status_message,
            52.0,
            485.0,
            22.0,
            Color::from_rgba(220, 228, 238, 255),
        );

        let hint = "↑↓ для выбора, ENTER для входа, L - рычаг, ESC - в меню";
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

    fn take_progress_update(&mut self) -> Option<ProgressUpdate> {
        self.pending_progress_update.take()
    }
}
