use macroquad::prelude::*;

use crate::game_state::{GameProgress, GameState};
use crate::ui_text::{draw_game_text, draw_wrapped_game_text, measure_game_text};

use super::Scene;

struct TownNpc {
    rect: Rect,
    name: &'static str,
    role: &'static str,
    dialog: &'static str,
    color: Color,
}

struct SealMarker {
    level: u8,
    rect: Rect,
    title: &'static str,
    accent: Color,
}

enum FocusTarget {
    Entrance,
    Npc(usize),
}

pub struct TownScene {
    progress: GameProgress,
    next_state: Option<GameState>,
    animation_time: f32,
    status_message: String,
    player: Rect,
    entrance_rect: Rect,
    npcs: Vec<TownNpc>,
    seals: Vec<SealMarker>,
}

impl TownScene {
    pub fn new(progress: GameProgress) -> Self {
        Self {
            progress,
            next_state: None,
            animation_time: 0.0,
            status_message: "Подойдите к шахтному спуску и нажмите E. Внутри пещеры уровни идут цепочкой один за другим.".to_string(),
            player: Rect::new(388.0, 474.0, 26.0, 40.0),
            entrance_rect: Rect::new(322.0, 176.0, 156.0, 136.0),
            npcs: vec![
                TownNpc {
                    rect: Rect::new(164.0, 416.0, 26.0, 38.0),
                    name: "Староста Иара",
                    role: "Хранитель тропы",
                    dialog: "Дальше не набор отдельных комнат, а один длинный спуск. Каждая печать держит каменную дверь, и только рычаг после победы размыкает проход глубже.",
                    color: Color::from_rgba(226, 188, 126, 255),
                },
                TownNpc {
                    rect: Rect::new(604.0, 414.0, 26.0, 38.0),
                    name: "Механик Роан",
                    role: "Смотритель механизмов",
                    dialog: "Когда уже один раз сломал печать, алтарь тебя помнит. Зайдёшь снова в ту же головоломку, нажмёшь L и сможешь не повторять решение перед рычагом.",
                    color: Color::from_rgba(146, 208, 255, 255),
                },
                TownNpc {
                    rect: Rect::new(384.0, 376.0, 26.0, 38.0),
                    name: "Архивариус Тель",
                    role: "Толкователь печатей",
                    dialog: "Не торопись смотреть только на центр экрана. Стены, свет и механизмы подсказывают, что уже открыто, что ещё спит и где именно ждать следующий поворот хода.",
                    color: Color::from_rgba(198, 168, 232, 255),
                },
            ],
            seals: vec![
                SealMarker {
                    level: 1,
                    rect: Rect::new(88.0, 128.0, 72.0, 138.0),
                    title: "Лабиринт",
                    accent: Color::from_rgba(130, 212, 255, 255),
                },
                SealMarker {
                    level: 2,
                    rect: Rect::new(186.0, 108.0, 72.0, 158.0),
                    title: "Архив",
                    accent: Color::from_rgba(255, 220, 136, 255),
                },
                SealMarker {
                    level: 3,
                    rect: Rect::new(284.0, 92.0, 72.0, 174.0),
                    title: "Ритм",
                    accent: Color::from_rgba(190, 152, 255, 255),
                },
                SealMarker {
                    level: 4,
                    rect: Rect::new(444.0, 92.0, 72.0, 174.0),
                    title: "Пары",
                    accent: Color::from_rgba(255, 150, 184, 255),
                },
                SealMarker {
                    level: 5,
                    rect: Rect::new(542.0, 108.0, 72.0, 158.0),
                    title: "Разлом",
                    accent: Color::from_rgba(132, 244, 192, 255),
                },
                SealMarker {
                    level: 6,
                    rect: Rect::new(640.0, 128.0, 72.0, 138.0),
                    title: "Ядро",
                    accent: Color::from_rgba(255, 132, 132, 255),
                },
            ],
        }
    }

    fn target_level(&self) -> u8 {
        for level in 1..=6 {
            if self.progress.is_level_unlocked(level) && !self.progress.is_lever_pulled(level) {
                return level;
            }
        }

        for level in (1..=6).rev() {
            if self.progress.is_level_unlocked(level) {
                return level;
            }
        }

        1
    }

    fn player_center(&self) -> Vec2 {
        vec2(
            self.player.x + self.player.w / 2.0,
            self.player.y + self.player.h / 2.0,
        )
    }

    fn focus_target(&self) -> Option<FocusTarget> {
        let center = self.player_center();
        let entrance_center = vec2(
            self.entrance_rect.x + self.entrance_rect.w / 2.0,
            self.entrance_rect.y + self.entrance_rect.h / 2.0,
        );
        let mut best: Option<(f32, FocusTarget)> = None;

        let entrance_distance = center.distance(entrance_center);
        if entrance_distance < 96.0 {
            best = Some((entrance_distance, FocusTarget::Entrance));
        }

        for (index, npc) in self.npcs.iter().enumerate() {
            let npc_center = vec2(npc.rect.x + npc.rect.w / 2.0, npc.rect.y + npc.rect.h / 2.0);
            let distance = center.distance(npc_center);
            if distance < 66.0 {
                if best
                    .as_ref()
                    .map(|(best_dist, _)| distance < *best_dist)
                    .unwrap_or(true)
                {
                    best = Some((distance, FocusTarget::Npc(index)));
                }
            }
        }

        best.map(|(_, target)| target)
    }

    fn interact(&mut self) {
        match self.focus_target() {
            Some(FocusTarget::Entrance) => {
                let target_level = self.target_level();
                self.next_state = Some(GameState::Playing(target_level));
            }
            Some(FocusTarget::Npc(index)) => {
                let npc = &self.npcs[index];
                self.status_message = format!("{}: {}", npc.name, npc.dialog);
            }
            None => {
                self.status_message = "Подойдите к спуску или к NPC и нажмите E.".to_string();
            }
        }
    }

    fn draw_background(&self) {
        for i in 0..screen_height() as i32 {
            let t = i as f32 / screen_height();
            let color = Color::new(0.03 + t * 0.08, 0.08 + t * 0.14, 0.17 + t * 0.14, 1.0);
            draw_line(0.0, i as f32, screen_width(), i as f32, 1.0, color);
        }

        draw_circle(660.0, 94.0, 58.0, Color::from_rgba(255, 224, 144, 32));
        draw_circle(660.0, 94.0, 34.0, Color::from_rgba(255, 224, 144, 160));

        draw_triangle(
            vec2(-30.0, 470.0),
            vec2(220.0, 224.0),
            vec2(420.0, 470.0),
            Color::from_rgba(28, 46, 58, 210),
        );
        draw_triangle(
            vec2(280.0, 470.0),
            vec2(514.0, 188.0),
            vec2(790.0, 470.0),
            Color::from_rgba(22, 36, 48, 220),
        );

        let ground_y = 470.0;
        draw_rectangle(
            0.0,
            ground_y,
            screen_width(),
            screen_height() - ground_y,
            Color::from_rgba(66, 46, 34, 255),
        );
        draw_rectangle(
            0.0,
            ground_y + 24.0,
            screen_width(),
            54.0,
            Color::from_rgba(102, 80, 58, 255),
        );

        for idx in 0..5 {
            let x = 24.0 + idx as f32 * 154.0;
            let width = 90.0 + (idx % 2) as f32 * 12.0;
            let height = 88.0 + idx as f32 * 12.0;
            let y = 446.0 - height;
            draw_rectangle(x, y, width, height, Color::from_rgba(34, 42, 62, 236));
            draw_triangle(
                vec2(x - 10.0, y),
                vec2(x + width + 10.0, y),
                vec2(x + width / 2.0, y - 38.0),
                Color::from_rgba(70, 42, 36, 245),
            );
        }

        draw_rectangle(
            self.entrance_rect.x - 28.0,
            self.entrance_rect.y + 82.0,
            self.entrance_rect.w + 56.0,
            160.0,
            Color::from_rgba(42, 44, 48, 255),
        );
        draw_triangle(
            vec2(self.entrance_rect.x - 44.0, self.entrance_rect.y + 82.0),
            vec2(
                self.entrance_rect.x + self.entrance_rect.w + 44.0,
                self.entrance_rect.y + 82.0,
            ),
            vec2(
                self.entrance_rect.x + self.entrance_rect.w / 2.0,
                self.entrance_rect.y - 24.0,
            ),
            Color::from_rgba(82, 70, 60, 255),
        );

        let pulse = (self.animation_time * 2.4).sin() * 0.5 + 0.5;
        draw_rectangle(
            self.entrance_rect.x,
            self.entrance_rect.y,
            self.entrance_rect.w,
            self.entrance_rect.h,
            Color::from_rgba(8, 12, 18, 255),
        );
        draw_circle(
            self.entrance_rect.x + self.entrance_rect.w / 2.0,
            self.entrance_rect.y + self.entrance_rect.h / 2.0,
            28.0 + pulse * 18.0,
            Color::from_rgba(122, 216, 255, (36.0 + pulse * 54.0) as u8),
        );
        draw_rectangle_lines(
            self.entrance_rect.x,
            self.entrance_rect.y,
            self.entrance_rect.w,
            self.entrance_rect.h,
            3.0,
            Color::from_rgba(164, 214, 255, 220),
        );

        for (index, seal) in self.seals.iter().enumerate() {
            let completed = self.progress.is_level_completed(seal.level);
            let opened = self.progress.is_lever_pulled(seal.level);
            let base = if opened {
                Color::from_rgba(182, 210, 118, 255)
            } else if completed {
                Color::from_rgba(248, 210, 126, 255)
            } else {
                Color::from_rgba(84, 92, 112, 255)
            };
            let glow = (self.animation_time * 1.8 + index as f32).sin() * 0.5 + 0.5;
            draw_rectangle(
                seal.rect.x,
                seal.rect.y,
                seal.rect.w,
                seal.rect.h,
                Color::from_rgba(24, 30, 44, 228),
            );
            draw_rectangle_lines(
                seal.rect.x,
                seal.rect.y,
                seal.rect.w,
                seal.rect.h,
                2.0,
                base,
            );
            draw_circle(
                seal.rect.x + seal.rect.w / 2.0,
                seal.rect.y + 30.0,
                8.0 + glow * 4.0,
                Color::new(base.r, base.g, base.b, 0.18 + glow * 0.20),
            );
            draw_circle(
                seal.rect.x + seal.rect.w / 2.0,
                seal.rect.y + 30.0,
                6.0,
                if completed { seal.accent } else { base },
            );
            let title_width = measure_game_text(seal.title, None, 14, 1.0).width;
            draw_game_text(
                seal.title,
                seal.rect.x + seal.rect.w / 2.0 - title_width / 2.0,
                seal.rect.y + seal.rect.h + 18.0,
                14.0,
                Color::from_rgba(220, 226, 236, 255),
            );
        }
    }

    fn draw_npc(&self, npc: &TownNpc, is_focused: bool) {
        let bob = (self.animation_time * 2.3 + npc.rect.x * 0.018).sin() * 3.0;
        let y = npc.rect.y + bob;

        draw_ellipse(
            npc.rect.x + npc.rect.w / 2.0,
            y + npc.rect.h + 2.0,
            14.0,
            5.0,
            0.0,
            Color::from_rgba(0, 0, 0, 70),
        );
        draw_circle(npc.rect.x + npc.rect.w / 2.0, y + 9.0, 10.0, npc.color);
        draw_rectangle(
            npc.rect.x,
            y + 14.0,
            npc.rect.w,
            npc.rect.h - 14.0,
            Color::from_rgba(76, 60, 56, 255),
        );
        draw_rectangle(
            npc.rect.x + 5.0,
            y + 18.0,
            npc.rect.w - 10.0,
            npc.rect.h - 24.0,
            Color::from_rgba(216, 230, 244, 70),
        );

        if is_focused {
            draw_circle_lines(npc.rect.x + npc.rect.w / 2.0, y + 9.0, 15.0, 2.0, WHITE);
        }

        draw_game_text(
            npc.name,
            npc.rect.x - 20.0,
            y - 12.0,
            14.0,
            Color::from_rgba(246, 228, 174, 255),
        );
    }

    fn draw_player(&self) {
        let step_bob = (self.animation_time * 8.0).sin().abs() * 2.2;
        draw_ellipse(
            self.player.x + self.player.w / 2.0,
            self.player.y + self.player.h + 3.0,
            15.0,
            6.0,
            0.0,
            Color::from_rgba(0, 0, 0, 70),
        );
        draw_rectangle(
            self.player.x,
            self.player.y - step_bob,
            self.player.w,
            self.player.h,
            Color::from_rgba(122, 182, 255, 255),
        );
        draw_rectangle(
            self.player.x + 5.0,
            self.player.y + 7.0 - step_bob,
            self.player.w - 10.0,
            9.0,
            Color::from_rgba(236, 244, 255, 255),
        );
        draw_circle(self.player.x + 8.0, self.player.y - step_bob, 3.0, BLACK);
        draw_circle(
            self.player.x + self.player.w - 8.0,
            self.player.y - step_bob,
            3.0,
            BLACK,
        );
    }
}

impl Scene for TownScene {
    fn handle_input(&mut self) {
        if is_key_pressed(KeyCode::E) {
            self.interact();
        }

        if is_key_pressed(KeyCode::Escape) {
            self.next_state = Some(GameState::Menu);
        }
    }

    fn update(&mut self) {
        self.animation_time += get_frame_time();

        let mut movement = Vec2::ZERO;
        if is_key_down(KeyCode::A) || is_key_down(KeyCode::Left) {
            movement.x -= 1.0;
        }
        if is_key_down(KeyCode::D) || is_key_down(KeyCode::Right) {
            movement.x += 1.0;
        }
        if is_key_down(KeyCode::W) || is_key_down(KeyCode::Up) {
            movement.y -= 1.0;
        }
        if is_key_down(KeyCode::S) || is_key_down(KeyCode::Down) {
            movement.y += 1.0;
        }

        if movement.length_squared() > 0.0 {
            let step = movement.normalize() * 170.0 * get_frame_time();
            self.player.x =
                (self.player.x + step.x).clamp(24.0, screen_width() - self.player.w - 24.0);
            self.player.y =
                (self.player.y + step.y).clamp(120.0, screen_height() - self.player.h - 34.0);
        }
    }

    fn draw(&self) {
        self.draw_background();

        let title = "ДЕРЕВНЯ ЭЛЬДОРАДО";
        let title_width = measure_game_text(title, None, 42, 1.0).width;
        draw_game_text(
            title,
            screen_width() / 2.0 - title_width / 2.0,
            48.0,
            42.0,
            Color::from_rgba(255, 232, 180, 255),
        );
        draw_wrapped_game_text(
            "Отсюда начинается один непрерывный спуск. Следующая пещера встречается не в меню, а за открытой дверью внутри предыдущей.",
            52.0,
            78.0,
            screen_width() - 104.0,
            18.0,
            4.0,
            Color::from_rgba(192, 208, 226, 255),
        );

        for npc in &self.npcs {
            let focused = matches!(self.focus_target(), Some(FocusTarget::Npc(index)) if self.npcs[index].name == npc.name);
            self.draw_npc(npc, focused);
        }

        self.draw_player();

        let focus = self.focus_target();
        let panel = Rect::new(498.0, 302.0, 278.0, 154.0);
        draw_rectangle(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            Color::from_rgba(18, 26, 40, 238),
        );
        draw_rectangle(
            panel.x + 8.0,
            panel.y + 8.0,
            panel.w - 16.0,
            panel.h - 16.0,
            Color::from_rgba(30, 18, 12, 72),
        );
        draw_rectangle_lines(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            2.0,
            Color::from_rgba(255, 204, 120, 200),
        );

        match focus {
            Some(FocusTarget::Entrance) => {
                let target_level = self.target_level();
                draw_game_text(
                    "Шахтный спуск",
                    panel.x + 18.0,
                    panel.y + 30.0,
                    24.0,
                    Color::from_rgba(132, 220, 255, 255),
                );
                draw_wrapped_game_text(
                    &format!("Следующая активная пещера: уровень {}.", target_level),
                    panel.x + 18.0,
                    panel.y + 60.0,
                    panel.w - 36.0,
                    18.0,
                    4.0,
                    WHITE,
                );
                draw_wrapped_game_text(
                    "После решения печати потяните рычаг уже внутри пещеры. Только он открывает следующий проход.",
                    panel.x + 18.0,
                    panel.y + 90.0,
                    panel.w - 36.0,
                    16.0,
                    4.0,
                    LIGHTGRAY,
                );
                draw_game_text(
                    "E - спуститься",
                    panel.x + 18.0,
                    panel.y + 134.0,
                    16.0,
                    Color::from_rgba(255, 214, 126, 255),
                );
            }
            Some(FocusTarget::Npc(index)) => {
                let npc = &self.npcs[index];
                draw_game_text(npc.name, panel.x + 18.0, panel.y + 30.0, 24.0, npc.color);
                draw_game_text(
                    npc.role,
                    panel.x + 18.0,
                    panel.y + 56.0,
                    16.0,
                    Color::from_rgba(210, 220, 235, 255),
                );
                draw_wrapped_game_text(
                    npc.dialog,
                    panel.x + 18.0,
                    panel.y + 82.0,
                    panel.w - 36.0,
                    16.0,
                    4.0,
                    LIGHTGRAY,
                );
            }
            None => {
                draw_game_text(
                    "Площадь перед шахтой",
                    panel.x + 18.0,
                    panel.y + 30.0,
                    24.0,
                    Color::from_rgba(255, 228, 180, 255),
                );
                draw_wrapped_game_text(
                    "Подойдите к шахтному спуску, чтобы продолжить цепочку пещер, или поговорите с жителями за подсказками.",
                    panel.x + 18.0,
                    panel.y + 62.0,
                    panel.w - 36.0,
                    18.0,
                    4.0,
                    WHITE,
                );
                draw_wrapped_game_text(
                    "WASD/стрелки - движение. E - взаимодействие. ESC - меню.",
                    panel.x + 18.0,
                    panel.y + 116.0,
                    panel.w - 36.0,
                    16.0,
                    4.0,
                    Color::from_rgba(120, 210, 255, 255),
                );
            }
        }

        draw_rectangle(
            22.0,
            520.0,
            screen_width() - 44.0,
            54.0,
            Color::from_rgba(8, 12, 20, 205),
        );
        draw_rectangle_lines(
            22.0,
            520.0,
            screen_width() - 44.0,
            54.0,
            2.0,
            Color::from_rgba(98, 152, 208, 120),
        );
        draw_wrapped_game_text(
            &self.status_message,
            38.0,
            542.0,
            screen_width() - 76.0,
            18.0,
            3.0,
            Color::from_rgba(220, 228, 238, 255),
        );
    }

    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }
}
