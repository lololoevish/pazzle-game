use macroquad::prelude::*;

use crate::audio;
use crate::game_state::{GameState, LevelProgress, ProgressUpdate};
use crate::ui_text::{draw_game_text, draw_wrapped_game_text, measure_game_text};
use crate::visual_assets::{
    draw_sprite, enemy_texture, item_texture, lever_texture, platform_texture, player_texture,
    Facing,
};

use super::puzzles::{
    FinalChallengePuzzle, MazePuzzle, MemoryMatchPuzzle, PatternPuzzle, PlatformerPuzzle,
    WordSearchPuzzle,
};
use super::Scene;

pub struct GameplayScene {
    level: u8,
    level_progress: LevelProgress,
    next_state: Option<GameState>,
    pending_progress_update: Option<ProgressUpdate>,
    report_completed_level: bool,
    current_stage: usize,
    in_puzzle: bool,
    show_instruction_overlay: bool,
    puzzle_solved: bool,
    passage_open: bool,
    cave_animation: f32,
    passage_anim: f32,
    player: Rect,
    altar_rect: Rect,
    lever_rect: Rect,
    exit_rect: Rect,
    status_message: String,
    maze_puzzle: Option<MazePuzzle>,
    wordsearch_puzzle: Option<WordSearchPuzzle>,
    pattern_puzzle: Option<PatternPuzzle>,
    memory_match_puzzle: Option<MemoryMatchPuzzle>,
    platformer_puzzle: Option<PlatformerPuzzle>,
    final_challenge_puzzle: Option<FinalChallengePuzzle>,
    player_facing: Facing,
}

impl GameplayScene {
    pub fn new(level: u8, level_progress: LevelProgress) -> Self {
        let puzzle_solved = level_progress.completed;
        let passage_open = false;
        let mut scene = Self {
            level,
            level_progress,
            next_state: None,
            pending_progress_update: None,
            report_completed_level: false,
            current_stage: 0,
            in_puzzle: false,
            show_instruction_overlay: false,
            puzzle_solved,
            passage_open,
            cave_animation: 0.0,
            passage_anim: 0.0,
            player: Rect::new(94.0, 470.0, 28.0, 40.0),
            altar_rect: Rect::new(282.0, 340.0, 168.0, 118.0),
            lever_rect: Rect::new(538.0, 366.0, 62.0, 112.0),
            exit_rect: Rect::new(666.0, 286.0, 102.0, 202.0),
            status_message: "Осмотрите пещеру: алтарь запускает печать, рычаг после победы открывает проход в следующий зал.".to_string(),
            maze_puzzle: None,
            wordsearch_puzzle: None,
            pattern_puzzle: None,
            memory_match_puzzle: None,
            platformer_puzzle: None,
            final_challenge_puzzle: None,
            player_facing: Facing::Down,
        };

        scene.setup_level();
        scene.sync_status_message();
        scene
    }

    fn setup_level(&mut self) {
        self.maze_puzzle = None;
        self.wordsearch_puzzle = None;
        self.pattern_puzzle = None;
        self.memory_match_puzzle = None;
        self.platformer_puzzle = None;
        self.final_challenge_puzzle = None;

        match (self.level, self.current_stage) {
            (1, _) => self.maze_puzzle = Some(MazePuzzle::new(15, 15)),
            (2, 0) => self.wordsearch_puzzle = Some(WordSearchPuzzle::new()),
            (2, 1) => self.memory_match_puzzle = Some(MemoryMatchPuzzle::new()),
            (3, _) => self.pattern_puzzle = Some(PatternPuzzle::new()),
            (4, _) => self.memory_match_puzzle = Some(MemoryMatchPuzzle::new()),
            (5, _) => self.platformer_puzzle = Some(PlatformerPuzzle::new()),
            (6, _) => self.final_challenge_puzzle = Some(FinalChallengePuzzle::new()),
            _ => {}
        }
    }

    fn stage_count(&self) -> usize {
        if self.level == 2 {
            2
        } else {
            1
        }
    }

    fn level_title(&self) -> &'static str {
        match self.level {
            1 => "Пещера молчаливых стен",
            2 => "Архивная пещера печатей",
            3 => "Грот часовщика",
            4 => "Галерея зеркального эха",
            5 => "Разлом кристаллов",
            6 => "Ядро глубинного хранилища",
            _ => "Пещера испытаний",
        }
    }

    fn level_goal(&self) -> &'static str {
        match (self.level, self.current_stage) {
            (1, _) => "Алтарь запускает скользящий лабиринт. После решения активируйте рычаг и откройте каменную дверь к следующей пещере.",
            (2, 0) => "Архив принимает первую печать: найдите слова, чтобы открыть вторую камеру в этой же пещере.",
            (2, 1) => "Вторая печать архивной пещеры проверяет память. После неё активируйте рычаг прохода.",
            (3, _) => "Повторите световые последовательности, затем откройте рычагом коридор ниже.",
            (4, _) => "Найдите пары карт без стартового показа и откройте следующий зал.",
            (5, _) => "Соберите кристаллы на платформенных уступах и разблокируйте каменный пролом.",
            (6, _) => "Добудьте артефакты в ядре глубин и завершите цепочку пещер.",
            _ => "",
        }
    }

    fn chapter_label(&self) -> &'static str {
        match self.level {
            1 => "CHAPTER // SILENT WALLS",
            2 => "CHAPTER // ARCHIVE VEIN",
            3 => "CHAPTER // CLOCKWORK GROTTO",
            4 => "CHAPTER // MIRROR ECHO",
            5 => "CHAPTER // CRYSTAL FAULT",
            6 => "CHAPTER // CORE BELOW",
            _ => "CHAPTER // CAVERN",
        }
    }

    fn level_accent(&self) -> Color {
        match self.level {
            1 => Color::from_rgba(120, 204, 255, 255),
            2 => Color::from_rgba(255, 214, 124, 255),
            3 => Color::from_rgba(194, 156, 255, 255),
            4 => Color::from_rgba(255, 146, 192, 255),
            5 => Color::from_rgba(126, 240, 198, 255),
            6 => Color::from_rgba(255, 118, 118, 255),
            _ => Color::from_rgba(196, 206, 224, 255),
        }
    }

    fn current_stage_name(&self) -> &'static str {
        match (self.level, self.current_stage) {
            (2, 0) => "Первая печать",
            (2, 1) => "Вторая печать",
            _ => "Активная печать",
        }
    }

    fn instruction_text(&self) -> &'static str {
        match (self.level, self.current_stage) {
            (1, _) => "Камень этой пещеры скользкий: герой летит в выбранную сторону до первой стены. Доведите путь до выхода лабиринта.",
            (2, 0) => "Архив слов принимает либо drag мышью, либо два клика: сначала первая буква слова, затем последняя.",
            (2, 1) => "Карты закрыты с самого начала. Открывайте по две, запоминайте позиции и ищите пары без подсказки.",
            (3, _) => "Следите за ритмом света. Ошибка сбрасывает текущую попытку, поэтому считывайте порядок внимательно.",
            (4, _) => "Зеркальная печать проверяет память на фигуры и позиции. Никакого предварительного показа нет.",
            (5, _) => "Здесь важны темп прыжка и траектория. Соберите все кристаллы и не сорвитесь в разлом.",
            (6, _) => "Финальная печать совмещает уклонение и сбор артефактов. Двигайтесь быстро, но не жадничайте.",
            _ => "",
        }
    }

    fn sync_status_message(&mut self) {
        self.status_message = if self.passage_open {
            "Каменная дверь уже раскрыта. Подойдите к проходу справа и нажмите E, чтобы спуститься дальше.".to_string()
        } else if self.level_progress.completed {
            "Печать уже знакома вам. Можно перепройти её у алтаря или просто опустить рычаг и открыть дверь заново.".to_string()
        } else if self.puzzle_solved {
            "Печать разрушена. Теперь потяните рычаг у двери, чтобы открыть проход в следующую пещеру.".to_string()
        } else {
            "Алтарь ещё активен. Подойдите к нему и нажмите E, чтобы запустить испытание."
                .to_string()
        };
    }

    fn is_near(&self, rect: Rect, distance: f32) -> bool {
        let center = vec2(
            self.player.x + self.player.w / 2.0,
            self.player.y + self.player.h / 2.0,
        );
        let target = vec2(rect.x + rect.w / 2.0, rect.y + rect.h / 2.0);
        center.distance(target) <= distance
    }

    fn start_puzzle(&mut self) {
        self.in_puzzle = true;
        self.show_instruction_overlay = true;
        audio::play_ui_confirm();
        self.status_message =
            "Вы подошли к печати. Прочитайте плиту, затем начните испытание.".to_string();
    }

    fn mark_puzzle_complete(&mut self) {
        let was_completed = self.level_progress.completed;
        self.puzzle_solved = true;
        self.level_progress.completed = true;
        self.in_puzzle = false;
        self.show_instruction_overlay = false;

        if !was_completed {
            self.report_completed_level = true;
        }

        audio::play_ui_success();
        self.sync_status_message();
    }

    fn advance_stage_or_complete(&mut self) {
        if self.level == 2 && self.current_stage == 0 {
            self.current_stage = 1;
            self.setup_level();
            self.show_instruction_overlay = true;
            audio::play_ui_success();
            self.status_message =
                "Первая архивная печать сорвана. В глубине пещеры открылась вторая камера памяти."
                    .to_string();
        } else {
            self.mark_puzzle_complete();
        }
    }

    fn skip_current_puzzle(&mut self) {
        self.current_stage = self.stage_count().saturating_sub(1);
        self.setup_level();
        self.puzzle_solved = true;
        self.in_puzzle = false;
        self.show_instruction_overlay = false;
        audio::play_ui_confirm();
        self.status_message =
            "Повторное решение пропущено. Подойдите к рычагу и откройте уже заработанный проход."
                .to_string();
    }

    fn pull_lever(&mut self) {
        if !self.puzzle_solved && !self.level_progress.completed {
            audio::play_ui_cancel();
            self.status_message =
                "Рычаг заблокирован. Сначала сорвите печать у алтаря.".to_string();
            return;
        }

        self.passage_open = true;
        self.puzzle_solved = true;
        self.level_progress.lever_pulled = true;
        self.pending_progress_update = Some(ProgressUpdate::LeverPulled {
            level: self.level,
            pulled: true,
        });
        audio::play_lever();
        self.status_message =
            "Скала отступила, и открылся проход вниз. Нажмите E у двери, чтобы перейти дальше."
                .to_string();
    }

    fn active_puzzle_handle_input(&mut self) {
        if let Some(maze) = &mut self.maze_puzzle {
            maze.handle_input();
            if maze.is_solved() {
                self.advance_stage_or_complete();
            }
        }

        if let Some(wordsearch) = &mut self.wordsearch_puzzle {
            wordsearch.handle_input();
            if wordsearch.is_solved() {
                self.advance_stage_or_complete();
            }
        }

        if let Some(pattern) = &mut self.pattern_puzzle {
            pattern.handle_input();
            if pattern.is_solved() {
                self.advance_stage_or_complete();
            }
        }

        if let Some(memory_match) = &mut self.memory_match_puzzle {
            memory_match.handle_input();
            if memory_match.is_solved() {
                self.advance_stage_or_complete();
            }
        }

        if let Some(platformer) = &mut self.platformer_puzzle {
            platformer.handle_input();
            if platformer.is_solved() {
                self.advance_stage_or_complete();
            }
        }

        if let Some(final_challenge) = &mut self.final_challenge_puzzle {
            final_challenge.handle_input();
            if final_challenge.is_solved() {
                self.advance_stage_or_complete();
            }
        }
    }

    fn active_puzzle_update(&mut self) {
        if let Some(maze) = &mut self.maze_puzzle {
            maze.update();
        }
        if let Some(pattern) = &mut self.pattern_puzzle {
            pattern.update();
        }
        if let Some(memory_match) = &mut self.memory_match_puzzle {
            memory_match.update();
        }
        if let Some(platformer) = &mut self.platformer_puzzle {
            platformer.update();
        }
        if let Some(final_challenge) = &mut self.final_challenge_puzzle {
            final_challenge.update();
        }
    }

    fn draw_cave_background(&self) {
        let accent = self.level_accent();
        for i in 0..screen_height() as i32 {
            let t = i as f32 / screen_height();
            let color = Color::new(
                0.02 + t * (0.04 + accent.r * 0.03),
                0.03 + t * (0.06 + accent.g * 0.03),
                0.05 + t * (0.08 + accent.b * 0.04),
                1.0,
            );
            draw_line(0.0, i as f32, screen_width(), i as f32, 1.0, color);
        }

        draw_circle(
            640.0,
            108.0,
            120.0,
            Color::new(accent.r, accent.g, accent.b, 0.09),
        );

        for i in 0..8 {
            let x = i as f32 * 110.0 - 40.0;
            draw_triangle(
                vec2(x, 0.0),
                vec2(x + 74.0, 0.0),
                vec2(x + 36.0, 48.0 + (i % 3) as f32 * 18.0),
                Color::from_rgba(28, 32, 38, 255),
            );
            draw_triangle(
                vec2(x + 36.0, 0.0),
                vec2(x + 102.0, 0.0),
                vec2(x + 68.0, 40.0 + (i % 2) as f32 * 22.0),
                Color::from_rgba(22, 26, 32, 255),
            );
        }

        draw_triangle(
            vec2(-20.0, 520.0),
            vec2(160.0, 250.0),
            vec2(360.0, 520.0),
            Color::from_rgba(22, 36, 46, 170),
        );
        draw_triangle(
            vec2(300.0, 520.0),
            vec2(542.0, 228.0),
            vec2(820.0, 520.0),
            Color::from_rgba(18, 28, 40, 182),
        );
        if self.level >= 4 {
            draw_triangle(
                vec2(500.0, 520.0),
                vec2(720.0, 176.0),
                vec2(880.0, 520.0),
                Color::from_rgba(12, 22, 34, 210),
            );
        }

        draw_rectangle(
            0.0,
            494.0,
            screen_width(),
            106.0,
            Color::from_rgba(54, 42, 30, 255),
        );
        for i in 0..14 {
            let x = i as f32 * 62.0;
            let radius = 18.0 + (i % 3) as f32 * 8.0;
            draw_circle(
                x + 18.0,
                526.0 + (i % 2) as f32 * 10.0,
                radius,
                Color::from_rgba(76, 60, 44, 255),
            );
        }

        for (idx, x) in [84.0, 716.0].iter().enumerate() {
            let flicker = (self.cave_animation * 6.4 + *x).sin() * 4.0 + 11.0;
            let torch_y = 178.0 + idx as f32 * 22.0;
            draw_rectangle(*x, torch_y, 8.0, 58.0, Color::from_rgba(104, 76, 42, 255));
            draw_circle(
                *x + 4.0,
                torch_y - 10.0,
                flicker + 9.0,
                Color::from_rgba(255, 144, 44, 48),
            );
            draw_circle(
                *x + 4.0,
                torch_y - 10.0,
                flicker,
                Color::from_rgba(255, 190, 100, 190),
            );
            draw_triangle(
                vec2(*x + 4.0, torch_y - 30.0),
                vec2(*x - 5.0, torch_y - 2.0),
                vec2(*x + 13.0, torch_y - 4.0),
                Color::from_rgba(255, 226, 132, 255),
            );
        }

        for crystal_x in [208.0, 242.0, 596.0, 628.0] {
            let pulse = (self.cave_animation * 3.0 + crystal_x * 0.02).sin() * 0.5 + 0.5;
            draw_triangle(
                vec2(crystal_x, 486.0),
                vec2(crystal_x + 18.0, 440.0),
                vec2(crystal_x + 34.0, 486.0),
                Color::from_rgba(88, 190, 228, 255),
            );
            draw_triangle(
                vec2(crystal_x + 6.0, 478.0),
                vec2(crystal_x + 18.0, 450.0),
                vec2(crystal_x + 28.0, 478.0),
                Color::from_rgba(220, 248, 255, 180),
            );
            draw_circle(
                crystal_x + 18.0,
                460.0,
                14.0 + pulse * 6.0,
                Color::new(accent.r, accent.g, accent.b, 0.08 + pulse * 0.16),
            );
        }
    }

    fn draw_altar(&self) {
        let relic = item_texture();
        draw_rectangle(
            self.altar_rect.x,
            self.altar_rect.y,
            self.altar_rect.w,
            self.altar_rect.h,
            Color::from_rgba(54, 58, 70, 255),
        );
        draw_rectangle(
            self.altar_rect.x + 18.0,
            self.altar_rect.y + 12.0,
            self.altar_rect.w - 36.0,
            self.altar_rect.h - 26.0,
            Color::from_rgba(36, 40, 52, 255),
        );
        draw_rectangle_lines(
            self.altar_rect.x,
            self.altar_rect.y,
            self.altar_rect.w,
            self.altar_rect.h,
            3.0,
            Color::from_rgba(118, 126, 142, 255),
        );

        let pulse = (self.cave_animation * 2.2).sin() * 0.5 + 0.5;
        let rune_color = if self.puzzle_solved {
            Color::from_rgba(116, 130, 150, 255)
        } else {
            Color::from_rgba(118, 216, 255, 255)
        };
        draw_circle(
            self.altar_rect.x + self.altar_rect.w / 2.0,
            self.altar_rect.y + 28.0,
            16.0 + pulse * 5.0,
            Color::new(
                rune_color.r,
                rune_color.g,
                rune_color.b,
                0.20 + pulse * 0.18,
            ),
        );
        draw_circle_lines(
            self.altar_rect.x + self.altar_rect.w / 2.0,
            self.altar_rect.y + 28.0,
            18.0 + pulse * 3.0,
            2.0,
            rune_color,
        );
        draw_line(
            self.altar_rect.x + 38.0,
            self.altar_rect.y + 76.0,
            self.altar_rect.x + self.altar_rect.w - 38.0,
            self.altar_rect.y + 76.0,
            2.0,
            Color::from_rgba(134, 144, 164, 180),
        );
        draw_line(
            self.altar_rect.x + self.altar_rect.w / 2.0,
            self.altar_rect.y + 50.0,
            self.altar_rect.x + self.altar_rect.w / 2.0,
            self.altar_rect.y + self.altar_rect.h - 18.0,
            2.0,
            Color::from_rgba(134, 144, 164, 180),
        );
        draw_sprite(
            &relic,
            self.altar_rect.x + self.altar_rect.w / 2.0 - 22.0,
            self.altar_rect.y + 38.0,
            44.0,
            44.0,
            if self.puzzle_solved {
                Color::from_rgba(160, 170, 182, 220)
            } else {
                WHITE
            },
        );

        let label = if self.puzzle_solved {
            "Печать погашена"
        } else {
            "Алтарь печати"
        };
        let width = measure_game_text(label, None, 18, 1.0).width;
        draw_game_text(
            label,
            self.altar_rect.x + self.altar_rect.w / 2.0 - width / 2.0,
            self.altar_rect.y + self.altar_rect.h + 22.0,
            18.0,
            Color::from_rgba(222, 228, 236, 255),
        );
    }

    fn draw_lever(&self) {
        if !(self.puzzle_solved || self.passage_open) {
            return;
        }
        let lever = lever_texture();

        draw_rectangle(
            self.lever_rect.x + 6.0,
            self.lever_rect.y + 62.0,
            self.lever_rect.w - 12.0,
            28.0,
            Color::from_rgba(76, 76, 82, 255),
        );
        draw_rectangle(
            self.lever_rect.x + self.lever_rect.w / 2.0 - 5.0,
            self.lever_rect.y + 8.0,
            10.0,
            76.0,
            Color::from_rgba(128, 128, 136, 255),
        );
        let handle_y = if self.passage_open {
            self.lever_rect.y + 64.0
        } else {
            self.lever_rect.y + 18.0
        };
        draw_rectangle(
            self.lever_rect.x + 14.0,
            handle_y,
            self.lever_rect.w - 28.0,
            18.0,
            if self.passage_open {
                Color::from_rgba(176, 182, 96, 255)
            } else {
                Color::from_rgba(232, 178, 92, 255)
            },
        );
        draw_sprite(
            &lever,
            self.lever_rect.x - 8.0,
            self.lever_rect.y + 2.0,
            76.0,
            76.0,
            WHITE,
        );
        let label = if self.passage_open {
            "Рычаг опущен"
        } else {
            "Рычаг двери"
        };
        let width = measure_game_text(label, None, 18, 1.0).width;
        draw_game_text(
            label,
            self.lever_rect.x + self.lever_rect.w / 2.0 - width / 2.0,
            self.lever_rect.y + self.lever_rect.h + 18.0,
            18.0,
            Color::from_rgba(240, 210, 144, 255),
        );
    }

    fn draw_exit(&self) {
        let pulse = (self.cave_animation * 3.6).sin() * 0.5 + 0.5;

        draw_rectangle(
            self.exit_rect.x - 10.0,
            self.exit_rect.y - 12.0,
            self.exit_rect.w + 20.0,
            self.exit_rect.h + 24.0,
            Color::from_rgba(64, 58, 50, 255),
        );
        draw_rectangle(
            self.exit_rect.x,
            self.exit_rect.y,
            self.exit_rect.w,
            self.exit_rect.h,
            Color::from_rgba(20, 16, 18, 255),
        );
        draw_rectangle_lines(
            self.exit_rect.x,
            self.exit_rect.y,
            self.exit_rect.w,
            self.exit_rect.h,
            3.0,
            Color::from_rgba(122, 112, 98, 255),
        );

        let open_height = self.exit_rect.h * self.passage_anim;
        if open_height > 4.0 {
            draw_rectangle(
                self.exit_rect.x + 10.0,
                self.exit_rect.y + self.exit_rect.h - open_height,
                self.exit_rect.w - 20.0,
                open_height - 10.0,
                Color::from_rgba(26, 36, 52, 255),
            );
            draw_circle(
                self.exit_rect.x + self.exit_rect.w / 2.0,
                self.exit_rect.y + self.exit_rect.h / 2.0,
                18.0 + pulse * 20.0,
                Color::from_rgba(118, 220, 255, (36.0 + pulse * 54.0) as u8),
            );
        }

        let label = if self.passage_open {
            "Проход в следующую пещеру"
        } else {
            "Запечатанная дверь"
        };
        let width = measure_game_text(label, None, 18, 1.0).width;
        draw_game_text(
            label,
            self.exit_rect.x + self.exit_rect.w / 2.0 - width / 2.0,
            self.exit_rect.y - 16.0,
            18.0,
            if self.passage_open {
                Color::from_rgba(144, 226, 255, 255)
            } else {
                LIGHTGRAY
            },
        );
    }

    fn draw_player(&self) {
        let bob = if self.in_puzzle {
            0.0
        } else {
            (self.cave_animation * 8.2).sin().abs() * 2.2
        };
        let texture = player_texture(self.player_facing);
        draw_ellipse(
            self.player.x + self.player.w / 2.0,
            self.player.y + self.player.h + 4.0,
            16.0,
            6.0,
            0.0,
            Color::from_rgba(0, 0, 0, 74),
        );
        draw_sprite(
            &texture,
            self.player.x - 12.0,
            self.player.y - 12.0 - bob,
            54.0,
            54.0,
            WHITE,
        );
    }

    fn draw_world_ui(&self) {
        let accent = self.level_accent();
        let title = format!("{}  |  {}", self.level_title(), self.current_stage_name());
        draw_game_text(
            self.chapter_label(),
            18.0,
            18.0,
            16.0,
            Color::from_rgba(255, 210, 132, 255),
        );
        draw_game_text(
            &title,
            18.0,
            42.0,
            28.0,
            Color::from_rgba(255, 232, 180, 255),
        );
        draw_wrapped_game_text(
            self.level_goal(),
            18.0,
            70.0,
            screen_width() - 220.0,
            17.0,
            3.0,
            Color::from_rgba(190, 205, 224, 255),
        );

        let context_hint = if self.is_near(self.exit_rect, 96.0) && self.passage_open {
            "E - пройти в следующую пещеру"
        } else if self.is_near(self.lever_rect, 84.0) && self.puzzle_solved && !self.passage_open {
            "E - опустить рычаг"
        } else if self.is_near(self.altar_rect, 90.0) && !self.passage_open {
            "E - открыть печать"
        } else {
            "WASD - движение, E - взаимодействие, ESC - в деревню"
        };
        let hint_width = measure_game_text(context_hint, None, 16, 1.0).width;
        draw_game_text(
            context_hint,
            screen_width() - hint_width - 18.0,
            26.0,
            16.0,
            Color::from_rgba(152, 172, 194, 255),
        );

        draw_rectangle(
            18.0,
            518.0,
            screen_width() - 36.0,
            60.0,
            Color::from_rgba(4, 10, 18, 218),
        );
        draw_rectangle(
            26.0,
            526.0,
            screen_width() - 52.0,
            44.0,
            Color::new(accent.r * 0.18, accent.g * 0.12, accent.b * 0.12, 0.26),
        );
        draw_rectangle_lines(
            18.0,
            518.0,
            screen_width() - 36.0,
            60.0,
            3.0,
            Color::new(accent.r, accent.g, accent.b, 0.44),
        );
        draw_wrapped_game_text(
            &self.status_message,
            34.0,
            540.0,
            screen_width() - 68.0,
            18.0,
            3.0,
            Color::from_rgba(220, 228, 238, 255),
        );
    }

    fn draw_vignette(&self) {
        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            74.0,
            Color::from_rgba(0, 0, 0, 118),
        );
        draw_rectangle(
            0.0,
            screen_height() - 88.0,
            screen_width(),
            88.0,
            Color::from_rgba(0, 0, 0, 132),
        );
        draw_rectangle(
            0.0,
            0.0,
            48.0,
            screen_height(),
            Color::from_rgba(0, 0, 0, 72),
        );
        draw_rectangle(
            screen_width() - 48.0,
            0.0,
            48.0,
            screen_height(),
            Color::from_rgba(0, 0, 0, 72),
        );
    }

    fn draw_world_detail(&self) {
        let mist = (self.cave_animation * 0.8).sin() * 0.5 + 0.5;
        let platform = platform_texture();
        let relic = item_texture();
        let gargoyle = enemy_texture();
        draw_ellipse(
            228.0,
            332.0,
            210.0,
            74.0,
            0.0,
            Color::from_rgba(36, 68, 92, (22.0 + mist * 26.0) as u8),
        );
        draw_ellipse(
            604.0,
            342.0,
            188.0,
            66.0,
            0.0,
            Color::from_rgba(28, 54, 78, (18.0 + mist * 20.0) as u8),
        );

        for x in [152.0, 492.0, 642.0] {
            draw_rectangle(x, 304.0, 14.0, 196.0, Color::from_rgba(40, 40, 46, 180));
            draw_rectangle(
                x - 8.0,
                294.0,
                30.0,
                18.0,
                Color::from_rgba(70, 66, 60, 190),
            );
        }

        for x in [154.0, 266.0, 510.0, 622.0] {
            draw_sprite(&platform, x, 452.0, 78.0, 36.0, WHITE);
        }

        draw_sprite(
            &gargoyle,
            120.0,
            236.0,
            56.0,
            56.0,
            Color::from_rgba(186, 180, 198, 220),
        );
        draw_sprite(
            &gargoyle,
            618.0,
            232.0,
            56.0,
            56.0,
            Color::from_rgba(186, 180, 198, 220),
        );
        draw_sprite(
            &relic,
            206.0,
            430.0,
            28.0,
            28.0,
            Color::from_rgba(170, 232, 255, 220),
        );
        draw_sprite(
            &relic,
            596.0,
            430.0,
            28.0,
            28.0,
            Color::from_rgba(170, 232, 255, 220),
        );

        draw_circle(
            self.altar_rect.x + self.altar_rect.w / 2.0,
            self.altar_rect.y + self.altar_rect.h / 2.0,
            96.0,
            Color::from_rgba(96, 180, 255, if self.puzzle_solved { 18 } else { 36 }),
        );
    }

    fn draw_puzzle_shell(&self) {
        let accent = self.level_accent();
        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            screen_height(),
            Color::from_rgba(3, 6, 12, 206),
        );

        let top_panel = Rect::new(14.0, 14.0, screen_width() - 28.0, 90.0);
        draw_rectangle(
            top_panel.x,
            top_panel.y,
            top_panel.w,
            top_panel.h,
            Color::from_rgba(10, 18, 28, 245),
        );
        draw_rectangle(
            top_panel.x + 8.0,
            top_panel.y + 8.0,
            top_panel.w - 16.0,
            top_panel.h - 16.0,
            Color::from_rgba(24, 32, 44, 228),
        );
        draw_rectangle_lines(
            top_panel.x,
            top_panel.y,
            top_panel.w,
            top_panel.h,
            3.0,
            Color::new(accent.r, accent.g, accent.b, 0.86),
        );

        let title = format!("{} | {}", self.level_title(), self.current_stage_name());
        draw_game_text(
            self.chapter_label(),
            top_panel.x + 18.0,
            top_panel.y + 18.0,
            15.0,
            Color::from_rgba(255, 210, 132, 255),
        );
        draw_game_text(
            &title,
            top_panel.x + 18.0,
            top_panel.y + 42.0,
            24.0,
            Color::from_rgba(255, 230, 182, 255),
        );
        draw_wrapped_game_text(
            self.level_goal(),
            top_panel.x + 18.0,
            top_panel.y + 64.0,
            top_panel.w - 36.0,
            16.0,
            3.0,
            Color::from_rgba(204, 214, 228, 255),
        );

        let frame = Rect::new(14.0, 110.0, screen_width() - 28.0, screen_height() - 194.0);
        draw_rectangle(
            frame.x,
            frame.y,
            frame.w,
            frame.h,
            Color::from_rgba(4, 10, 18, 180),
        );
        draw_rectangle_lines(
            frame.x,
            frame.y,
            frame.w,
            frame.h,
            2.0,
            Color::new(accent.r, accent.g, accent.b, 0.36),
        );

        let footer = Rect::new(14.0, screen_height() - 76.0, screen_width() - 28.0, 62.0);
        draw_rectangle(
            footer.x,
            footer.y,
            footer.w,
            footer.h,
            Color::from_rgba(8, 12, 20, 232),
        );
        draw_rectangle_lines(
            footer.x,
            footer.y,
            footer.w,
            footer.h,
            2.0,
            Color::new(accent.r, accent.g, accent.b, 0.46),
        );

        let footer_text = if self.level_progress.completed {
            "ESC - выйти из головоломки, L - пропустить повторное решение"
        } else {
            "ESC - выйти из головоломки"
        };
        draw_game_text(
            footer_text,
            footer.x + 18.0,
            footer.y + 22.0,
            16.0,
            Color::from_rgba(255, 214, 126, 255),
        );
        draw_wrapped_game_text(
            &self.status_message,
            footer.x + 18.0,
            footer.y + 46.0,
            footer.w - 36.0,
            16.0,
            3.0,
            Color::from_rgba(220, 228, 238, 255),
        );
    }

    fn draw_instruction_overlay(&self) {
        if !self.show_instruction_overlay {
            return;
        }

        let accent = self.level_accent();

        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            screen_height(),
            Color::from_rgba(0, 0, 0, 176),
        );

        let panel = Rect::new(76.0, 82.0, screen_width() - 152.0, 210.0);
        draw_triangle(
            vec2(panel.x - 18.0, panel.y + 18.0),
            vec2(panel.x + panel.w + 18.0, panel.y + 2.0),
            vec2(panel.x + panel.w - 12.0, panel.y + panel.h + 18.0),
            Color::from_rgba(44, 42, 42, 255),
        );
        draw_rectangle(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            Color::from_rgba(78, 74, 66, 252),
        );
        draw_rectangle(
            panel.x + 10.0,
            panel.y + 10.0,
            panel.w - 20.0,
            panel.h - 20.0,
            Color::from_rgba(98, 92, 82, 250),
        );
        draw_rectangle_lines(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            3.0,
            Color::new(
                accent.r * 0.9 + 0.1,
                accent.g * 0.8 + 0.1,
                accent.b * 0.7 + 0.2,
                1.0,
            ),
        );

        for (x, y) in [
            (panel.x + 14.0, panel.y + 14.0),
            (panel.x + panel.w - 14.0, panel.y + 14.0),
            (panel.x + 14.0, panel.y + panel.h - 14.0),
            (panel.x + panel.w - 14.0, panel.y + panel.h - 14.0),
        ] {
            draw_circle(x, y, 5.0, Color::from_rgba(50, 44, 40, 255));
            draw_circle_lines(x, y, 5.0, 1.0, Color::from_rgba(220, 206, 164, 255));
        }

        draw_game_text(
            "Каменная плита печати",
            panel.x + 22.0,
            panel.y + 34.0,
            28.0,
            Color::from_rgba(255, 232, 182, 255),
        );
        draw_game_text(
            self.chapter_label(),
            panel.x + 22.0,
            panel.y + 54.0,
            14.0,
            Color::from_rgba(126, 92, 66, 255),
        );
        draw_wrapped_game_text(
            self.instruction_text(),
            panel.x + 22.0,
            panel.y + 84.0,
            panel.w - 44.0,
            20.0,
            5.0,
            Color::from_rgba(244, 242, 236, 255),
        );

        let footer = if self.level_progress.completed {
            "ENTER / SPACE - начать, L - пропустить повтор, ESC - выйти"
        } else {
            "ENTER / SPACE - начать, ESC - выйти"
        };
        draw_game_text(
            footer,
            panel.x + 22.0,
            panel.y + panel.h - 20.0,
            17.0,
            Color::from_rgba(255, 214, 126, 255),
        );
    }
}

impl Scene for GameplayScene {
    fn handle_input(&mut self) {
        if self.in_puzzle {
            if self.show_instruction_overlay {
                if self.level_progress.completed && is_key_pressed(KeyCode::L) {
                    self.skip_current_puzzle();
                    return;
                }

                if is_key_pressed(KeyCode::Enter)
                    || is_key_pressed(KeyCode::Space)
                    || is_key_pressed(KeyCode::E)
                {
                    audio::play_ui_confirm();
                    self.show_instruction_overlay = false;
                }
                if is_key_pressed(KeyCode::Escape) {
                    audio::play_ui_cancel();
                    self.in_puzzle = false;
                    self.show_instruction_overlay = false;
                    self.sync_status_message();
                }
                return;
            }

            if self.level_progress.completed && is_key_pressed(KeyCode::L) {
                self.skip_current_puzzle();
                return;
            }

            if is_key_pressed(KeyCode::Escape) {
                audio::play_ui_cancel();
                self.in_puzzle = false;
                self.status_message =
                    "Вы отошли от печати. Возвращайтесь к алтарю, когда будете готовы.".to_string();
                return;
            }

            self.active_puzzle_handle_input();
            return;
        }

        if is_key_pressed(KeyCode::Escape) {
            audio::play_ui_cancel();
            self.next_state = Some(GameState::Town);
            return;
        }

        if is_key_pressed(KeyCode::E) {
            if self.is_near(self.altar_rect, 94.0) && !self.passage_open {
                self.start_puzzle();
            } else if self.is_near(self.lever_rect, 82.0) {
                self.pull_lever();
            } else if self.is_near(self.exit_rect, 102.0) {
                if self.passage_open {
                    audio::play_ui_confirm();
                    self.next_state = if self.level < 6 {
                        Some(GameState::Playing(self.level + 1))
                    } else {
                        Some(GameState::Victory)
                    };
                } else {
                    audio::play_ui_cancel();
                    self.status_message =
                        "Дверь не двигается. Сначала решите печать и опустите рычаг.".to_string();
                }
            } else {
                audio::play_ui_cancel();
                self.status_message =
                    "Здесь нечего трогать. Осмотрите алтарь, рычаг или запечатанную дверь."
                        .to_string();
            }
        }
    }

    fn update(&mut self) {
        self.cave_animation += get_frame_time();

        if self.in_puzzle {
            if !self.show_instruction_overlay {
                self.active_puzzle_update();
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
                (self.player.y + step.y).clamp(144.0, screen_height() - self.player.h - 44.0);
        }

        let target = if self.passage_open { 1.0 } else { 0.0 };
        let speed = 1.8 * get_frame_time();
        if self.passage_anim < target {
            self.passage_anim = (self.passage_anim + speed).min(target);
        } else if self.passage_anim > target {
            self.passage_anim = (self.passage_anim - speed).max(target);
        }
    }

    fn draw(&self) {
        self.draw_cave_background();
        self.draw_world_detail();
        self.draw_vignette();
        self.draw_altar();
        self.draw_lever();
        self.draw_exit();
        self.draw_player();

        if self.in_puzzle {
            self.draw_puzzle_shell();

            if let Some(maze) = &self.maze_puzzle {
                maze.draw();
            }
            if let Some(wordsearch) = &self.wordsearch_puzzle {
                wordsearch.draw();
            }
            if let Some(pattern) = &self.pattern_puzzle {
                pattern.draw();
            }
            if let Some(memory_match) = &self.memory_match_puzzle {
                memory_match.draw();
            }
            if let Some(platformer) = &self.platformer_puzzle {
                platformer.draw();
            }
            if let Some(final_challenge) = &self.final_challenge_puzzle {
                final_challenge.draw();
            }

            self.draw_instruction_overlay();
        } else {
            self.draw_world_ui();
        }
    }

    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }

    fn take_completed_level(&mut self) -> Option<u8> {
        if self.report_completed_level {
            self.report_completed_level = false;
            Some(self.level)
        } else {
            None
        }
    }

    fn take_progress_update(&mut self) -> Option<ProgressUpdate> {
        self.pending_progress_update.take()
    }
}
