use macroquad::prelude::*;

use crate::game_state::{GameProgress, GameState};
use crate::ui_text::{draw_game_text, draw_wrapped_game_text, measure_game_text};
use crate::visual_assets::{
    draw_sprite, item_texture, npc_texture, platform_texture, player_texture, Facing,
};

use super::Scene;

struct TownNpc {
    rect: Rect,
    name: &'static str,
    role: &'static str,
    color: Color,
}

struct ActiveDialogue {
    npc_index: usize,
    line_index: usize,
    visible_chars: usize,
    lines: Vec<String>,
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
    active_dialogue: Option<ActiveDialogue>,
    player_facing: Facing,
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
                    color: Color::from_rgba(226, 188, 126, 255),
                },
                TownNpc {
                    rect: Rect::new(604.0, 414.0, 26.0, 38.0),
                    name: "Механик Роан",
                    role: "Смотритель механизмов",
                    color: Color::from_rgba(146, 208, 255, 255),
                },
                TownNpc {
                    rect: Rect::new(384.0, 376.0, 26.0, 38.0),
                    name: "Архивариус Тель",
                    role: "Толкователь печатей",
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
            active_dialogue: None,
            player_facing: Facing::Down,
        }
    }

    fn town_entry_level(&self) -> u8 {
        1
    }

    fn current_objective_level(&self) -> u8 {
        self.progress.current_objective_level()
    }

    fn opened_seal_count(&self) -> usize {
        (1..=6)
            .filter(|level| self.progress.is_lever_pulled(*level))
            .count()
    }

    fn level_label(level: u8) -> &'static str {
        match level {
            1 => "лабиринт молчаливых стен",
            2 => "архивную пещеру печатей",
            3 => "грот часовщика",
            4 => "галерею зеркального эха",
            5 => "разлом кристаллов",
            6 => "ядро глубинного хранилища",
            _ => "следующую пещеру",
        }
    }

    fn npc_preview(&self, npc_index: usize) -> String {
        let target_level = self.current_objective_level();
        let opened = self.opened_seal_count();

        match npc_index {
            0 => {
                if opened >= 6 {
                    "Все печати уже открыты. Староста говорит о том, что путь под городом завершён."
                        .to_string()
                } else {
                    format!(
                        "Староста следит за порядком спуска. Сейчас он говорит о пути в {}.",
                        Self::level_label(target_level)
                    )
                }
            }
            1 => {
                if opened == 0 {
                    "Механик объяснит, зачем вообще нужен рычаг после победы.".to_string()
                } else {
                    format!(
                        "Механик видит {} уже открытых печатей и комментирует работу рычагов.",
                        opened
                    )
                }
            }
            2 => {
                if target_level == 2 {
                    "Архивариус особенно разговорчив перед архивной пещерой и памятью о символах."
                        .to_string()
                } else {
                    "Архивариус читает окружение и подсказывает, на что смотреть в текущей пещере."
                        .to_string()
                }
            }
            _ => String::new(),
        }
    }

    fn build_dialogue_lines(&self, npc_index: usize) -> Vec<String> {
        let target_level = self.current_objective_level();
        let opened = self.opened_seal_count();
        let final_open = self.progress.is_lever_pulled(6);

        match npc_index {
            0 => {
                if final_open {
                    vec![
                        "Ты вскрыл все шесть печатей. Для деревни это значит, что Элдорадо больше не висит над пропастью на древних замках.".to_string(),
                        "Теперь мой совет уже не о выживании, а о памяти: не потеряй ощущение пути, который прошёл под нами.".to_string(),
                        "Если снова пойдёшь вниз, смотри на обелиски. Они теперь напоминают не о долге, а о проделанной работе.".to_string(),
                    ]
                } else {
                    vec![
                        "Слушай внимательно: дальше не набор комнат из меню, а один длинный спуск под деревней.".to_string(),
                        format!(
                            "Сейчас тебе нужно пройти через {}. Пока не сорвёшь печать и не опустишь рычаг, дорога глубже не откроется.",
                            Self::level_label(target_level)
                        ),
                        format!(
                            "Уже вскрыто печатей: {} из 6. Обелиски у шахты показывают это честнее любых слов.",
                            opened
                        ),
                    ]
                }
            }
            1 => {
                let mut lines = vec![
                    "Я обслуживаю рычаги внизу. Они не для красоты: именно они двигают каменную дверь после победы.".to_string(),
                ];
                if opened == 0 {
                    lines.push("Сначала почувствуй это на первом спуске: решишь печать, а потом сам услышишь, как рычаг сдвигает породу.".to_string());
                } else {
                    lines.push(format!(
                        "У тебя уже открыто {} печатей. Значит, ты видел, как рычаг фиксирует победу и переводит пещеру в пройденное состояние.",
                        opened
                    ));
                }
                lines.push(
                    "Если печать уже ломал раньше, алтарь тебя узнаёт. На повторном заходе в головоломку нажми L, и механизм позволит не тратить время на старое решение."
                        .to_string(),
                );
                lines
            }
            2 => {
                let second_level_done = self.progress.is_level_completed(2);
                let mut lines = vec![
                    "Печати любят прятать подсказки в окружении. Смотри не только в центр, но и на свет, стены, руны и движение деталей.".to_string(),
                ];
                if target_level == 2 || !second_level_done {
                    lines.push("Архивная пещера особенно коварна: она проверяет не одну мысль, а две подряд. Сначала слово, потом память о форме.".to_string());
                } else {
                    lines.push(format!(
                        "Раз сейчас на очереди {}, ищи в окружении не просто красоту, а ритм, повтор или напряжение механизма.",
                        Self::level_label(target_level)
                    ));
                }
                lines.push(
                    "Если видишь, что окно говорит с тобой как тёплая рамка, это житель. Если как тяжёлая каменная плита, это сама печать."
                        .to_string(),
                );
                lines
            }
            _ => vec!["...".to_string()],
        }
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

    fn start_dialogue(&mut self, npc_index: usize) {
        let lines = self.build_dialogue_lines(npc_index);
        self.active_dialogue = Some(ActiveDialogue {
            npc_index,
            line_index: 0,
            visible_chars: 0,
            lines,
        });
        self.status_message =
            "Диалог открыт. E или ENTER - дальше, SPACE - допечатать строку, ESC - закрыть."
                .to_string();
    }

    fn dialogue_line<'a>(&self, dialogue: &'a ActiveDialogue) -> &'a str {
        &dialogue.lines[dialogue.line_index]
    }

    fn finish_or_advance_dialogue(&mut self) {
        let Some(dialogue) = &mut self.active_dialogue else {
            return;
        };

        let total_chars = dialogue.lines[dialogue.line_index].chars().count();

        if dialogue.visible_chars < total_chars {
            dialogue.visible_chars = total_chars;
            return;
        }

        if dialogue.line_index + 1 < dialogue.lines.len() {
            dialogue.line_index += 1;
            dialogue.visible_chars = 0;
        } else {
            self.active_dialogue = None;
            self.status_message =
                "Диалог завершён. Подойдите к шахте, чтобы продолжить спуск.".to_string();
        }
    }

    fn visible_dialogue_text(&self) -> Option<String> {
        let dialogue = self.active_dialogue.as_ref()?;
        let line = self.dialogue_line(dialogue);
        Some(line.chars().take(dialogue.visible_chars).collect())
    }

    fn interact(&mut self) {
        match self.focus_target() {
            Some(FocusTarget::Entrance) => {
                self.next_state = Some(GameState::Playing(self.town_entry_level()));
            }
            Some(FocusTarget::Npc(index)) => {
                self.start_dialogue(index);
            }
            None => {
                self.status_message = "Подойдите к спуску или к NPC и нажмите E.".to_string();
            }
        }
    }

    fn draw_background(&self) {
        let platform = platform_texture();
        let relic = item_texture();
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
            draw_sprite(
                &platform,
                x + 8.0,
                y + height - 24.0,
                width - 16.0,
                26.0,
                WHITE,
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
            draw_sprite(
                &relic,
                seal.rect.x + seal.rect.w / 2.0 - 12.0,
                seal.rect.y + 44.0,
                24.0,
                24.0,
                if opened {
                    Color::from_rgba(186, 228, 164, 255)
                } else if completed {
                    Color::from_rgba(255, 236, 166, 255)
                } else {
                    Color::from_rgba(144, 154, 176, 220)
                },
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
        let texture = npc_texture();

        draw_ellipse(
            npc.rect.x + npc.rect.w / 2.0,
            y + npc.rect.h + 2.0,
            14.0,
            5.0,
            0.0,
            Color::from_rgba(0, 0, 0, 70),
        );
        draw_sprite(&texture, npc.rect.x - 10.0, y - 6.0, 48.0, 48.0, npc.color);

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
        let texture = player_texture(self.player_facing);
        draw_ellipse(
            self.player.x + self.player.w / 2.0,
            self.player.y + self.player.h + 3.0,
            15.0,
            6.0,
            0.0,
            Color::from_rgba(0, 0, 0, 70),
        );
        draw_sprite(
            &texture,
            self.player.x - 12.0,
            self.player.y - 12.0 - step_bob,
            52.0,
            52.0,
            WHITE,
        );
    }

    fn draw_dialogue_overlay(&self) {
        let Some(dialogue) = &self.active_dialogue else {
            return;
        };

        let npc = &self.npcs[dialogue.npc_index];
        let typed_text = self.visible_dialogue_text().unwrap_or_default();
        let panel = Rect::new(58.0, 356.0, screen_width() - 116.0, 172.0);

        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            screen_height(),
            Color::from_rgba(0, 0, 0, 112),
        );
        draw_rectangle(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            Color::from_rgba(20, 18, 32, 242),
        );
        draw_rectangle(
            panel.x + 8.0,
            panel.y + 8.0,
            panel.w - 16.0,
            panel.h - 16.0,
            Color::from_rgba(42, 28, 18, 88),
        );
        draw_rectangle_lines(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            3.0,
            Color::from_rgba(255, 204, 128, 220),
        );

        draw_circle(panel.x + 42.0, panel.y + 42.0, 18.0, npc.color);
        draw_circle_lines(
            panel.x + 42.0,
            panel.y + 42.0,
            20.0,
            2.0,
            Color::from_rgba(255, 236, 200, 255),
        );
        draw_game_text(
            npc.name,
            panel.x + 76.0,
            panel.y + 34.0,
            26.0,
            Color::from_rgba(255, 232, 182, 255),
        );
        draw_game_text(
            npc.role,
            panel.x + 76.0,
            panel.y + 58.0,
            16.0,
            Color::from_rgba(210, 220, 235, 255),
        );

        draw_wrapped_game_text(
            &typed_text,
            panel.x + 24.0,
            panel.y + 92.0,
            panel.w - 48.0,
            22.0,
            5.0,
            Color::from_rgba(242, 240, 236, 255),
        );

        let progress = format!(
            "Реплика {}/{}",
            dialogue.line_index + 1,
            dialogue.lines.len()
        );
        draw_game_text(
            &progress,
            panel.x + panel.w - 116.0,
            panel.y + 34.0,
            16.0,
            Color::from_rgba(132, 206, 255, 255),
        );
        draw_game_text(
            "E / ENTER - дальше, SPACE - допечатать, ESC - закрыть",
            panel.x + 24.0,
            panel.y + panel.h - 18.0,
            16.0,
            Color::from_rgba(255, 212, 124, 255),
        );
    }
}

impl Scene for TownScene {
    fn handle_input(&mut self) {
        if self.active_dialogue.is_some() {
            if is_key_pressed(KeyCode::Escape) {
                self.active_dialogue = None;
                self.status_message =
                    "Диалог закрыт. Подойдите к шахте, чтобы продолжить спуск.".to_string();
                return;
            }

            if is_key_pressed(KeyCode::Space)
                || is_key_pressed(KeyCode::Enter)
                || is_key_pressed(KeyCode::E)
            {
                self.finish_or_advance_dialogue();
            }
            return;
        }

        if is_key_pressed(KeyCode::E) {
            self.interact();
        }

        if is_key_pressed(KeyCode::Escape) {
            self.next_state = Some(GameState::Menu);
        }
    }

    fn update(&mut self) {
        self.animation_time += get_frame_time();

        if let Some(dialogue) = &mut self.active_dialogue {
            let total_chars = dialogue.lines[dialogue.line_index].chars().count();
            if dialogue.visible_chars < total_chars {
                let reveal = (get_frame_time() * 42.0).ceil() as usize;
                dialogue.visible_chars = (dialogue.visible_chars + reveal).min(total_chars);
            }
            return;
        }

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
            if movement.x.abs() > movement.y.abs() {
                self.player_facing = if movement.x > 0.0 {
                    Facing::Right
                } else {
                    Facing::Left
                };
            } else {
                self.player_facing = if movement.y > 0.0 {
                    Facing::Down
                } else {
                    Facing::Up
                };
            }
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
            if self.progress.is_expedition_complete() {
                "Подземная цепочка полностью раскрыта. Теперь деревня живёт без печатного замка, а вы можете спускаться повторно ради отдельных испытаний."
            } else {
                "Отсюда начинается один непрерывный спуск. Следующая пещера встречается не в меню, а за открытой дверью внутри предыдущей."
            },
            52.0,
            78.0,
            screen_width() - 104.0,
            18.0,
            4.0,
            Color::from_rgba(192, 208, 226, 255),
        );
        let objective_panel = Rect::new(44.0, 102.0, screen_width() - 88.0, 44.0);
        draw_rectangle(
            objective_panel.x,
            objective_panel.y,
            objective_panel.w,
            objective_panel.h,
            Color::from_rgba(10, 16, 26, 170),
        );
        draw_rectangle_lines(
            objective_panel.x,
            objective_panel.y,
            objective_panel.w,
            objective_panel.h,
            2.0,
            Color::from_rgba(108, 162, 208, 120),
        );
        let objective_text = if self.progress.is_expedition_complete() {
            format!(
                "Экспедиция завершена | Открыто печатей: {}/6 | Решено: {}/6",
                self.opened_seal_count(),
                self.progress.completed_count()
            )
        } else {
            format!(
                "Цель экспедиции: уровень {} | Открыто печатей: {}/6 | Решено: {}/6",
                self.current_objective_level(),
                self.opened_seal_count(),
                self.progress.completed_count()
            )
        };
        draw_wrapped_game_text(
            &objective_text,
            objective_panel.x + 16.0,
            objective_panel.y + 18.0,
            objective_panel.w - 32.0,
            16.0,
            3.0,
            Color::from_rgba(224, 232, 240, 255),
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
                let target_level = self.current_objective_level();
                let relic = item_texture();
                draw_game_text(
                    "Шахтный спуск",
                    panel.x + 18.0,
                    panel.y + 30.0,
                    24.0,
                    Color::from_rgba(132, 220, 255, 255),
                );
                draw_sprite(
                    &relic,
                    panel.x + panel.w - 64.0,
                    panel.y + 18.0,
                    34.0,
                    34.0,
                    WHITE,
                );
                draw_wrapped_game_text(
                    "Шахта всегда начинается с первой пещеры, а дальше путь идёт цепочкой через внутренние двери.",
                    panel.x + 18.0,
                    panel.y + 60.0,
                    panel.w - 36.0,
                    18.0,
                    4.0,
                    WHITE,
                );
                draw_wrapped_game_text(
                    &format!(
                        "Текущая цель по прогрессу: уровень {}. Если ранние пещеры уже решены, внутри можно быстро открыть их рычаги заново и пройти дальше.",
                        target_level
                    ),
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
                    &self.npc_preview(index),
                    panel.x + 18.0,
                    panel.y + 82.0,
                    panel.w - 36.0,
                    16.0,
                    4.0,
                    LIGHTGRAY,
                );
                draw_game_text(
                    "E - говорить",
                    panel.x + 18.0,
                    panel.y + 134.0,
                    16.0,
                    Color::from_rgba(255, 214, 126, 255),
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

        self.draw_dialogue_overlay();
    }

    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }
}
