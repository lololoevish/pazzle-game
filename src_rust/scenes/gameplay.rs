use macroquad::prelude::*;

use crate::game_state::{GameState, LevelProgress};

use super::puzzles::{
    FinalChallengePuzzle, MazePuzzle, MemoryMatchPuzzle, PatternPuzzle, PlatformerPuzzle,
    WordSearchPuzzle,
};
use super::Scene;

pub struct GameplayScene {
    level: u8,
    level_progress: LevelProgress,
    next_state: Option<GameState>,
    puzzle_solved: bool,
    completed_level_reported: bool,
    puzzle_disabled_by_lever: bool,
    maze_puzzle: Option<MazePuzzle>,
    wordsearch_puzzle: Option<WordSearchPuzzle>,
    pattern_puzzle: Option<PatternPuzzle>,
    memory_match_puzzle: Option<MemoryMatchPuzzle>,
    platformer_puzzle: Option<PlatformerPuzzle>,
    final_challenge_puzzle: Option<FinalChallengePuzzle>,
}

impl GameplayScene {
    pub fn new(level: u8, level_progress: LevelProgress) -> Self {
        let puzzle_disabled_by_lever = level_progress.completed && level_progress.lever_pulled;
        let mut scene = Self {
            level,
            level_progress,
            next_state: None,
            puzzle_solved: puzzle_disabled_by_lever,
            completed_level_reported: puzzle_disabled_by_lever,
            puzzle_disabled_by_lever,
            maze_puzzle: None,
            wordsearch_puzzle: None,
            pattern_puzzle: None,
            memory_match_puzzle: None,
            platformer_puzzle: None,
            final_challenge_puzzle: None,
        };

        scene.setup_level();
        scene
    }

    fn setup_level(&mut self) {
        if self.puzzle_disabled_by_lever {
            return;
        }

        match self.level {
            1 => self.maze_puzzle = Some(MazePuzzle::new(15, 15)),
            2 => self.wordsearch_puzzle = Some(WordSearchPuzzle::new()),
            3 => self.pattern_puzzle = Some(PatternPuzzle::new()),
            4 => self.memory_match_puzzle = Some(MemoryMatchPuzzle::new()),
            5 => self.platformer_puzzle = Some(PlatformerPuzzle::new()),
            6 => self.final_challenge_puzzle = Some(FinalChallengePuzzle::new()),
            _ => {}
        }
    }

    fn level_title(&self) -> &'static str {
        match self.level {
            1 => "Лабиринт молчаливых стен",
            2 => "Архив забытых слов",
            3 => "Зал памяти часовщика",
            4 => "Галерея зеркальных пар",
            5 => "Прыжок над бездной",
            6 => "Сердце древнего хранилища",
            _ => "Испытание",
        }
    }

    fn level_story(&self) -> &'static str {
        match self.level {
            1 => "Первый проход учит двигаться без колебаний: здесь ошибку может остановить только стена.",
            2 => "В архивах сохранились слова-печати, открывающие второй круг подземного города.",
            3 => "Часовщик оставил световой ритм, который узнают лишь внимательные.",
            4 => "Зеркальная галерея проверяет, насколько хорошо вы замечаете совпадения.",
            5 => "Над разломом остались только платформы и кристаллы-проводники.",
            6 => "В центре хранилища артефакты питают защиту. Соберите их быстрее, чем замкнётся контур.",
            _ => "",
        }
    }

    fn level_goal(&self) -> &'static str {
        match self.level {
            1 => "Скользите по коридорам до стены и доберитесь до красного выхода.",
            2 => "Выделите все слова мышью по горизонтали или вертикали.",
            3 => "Повторите все световые последовательности без ошибок.",
            4 => "Откройте все пары карточек за минимальное число попыток.",
            5 => "Соберите кристаллы и не падайте в пропасть.",
            6 => "Соберите артефакты и избегайте ловушек до конца таймера.",
            _ => "",
        }
    }

    fn draw_header(&self) {
        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            96.0,
            Color::from_rgba(8, 14, 28, 210),
        );
        draw_rectangle(
            0.0,
            96.0,
            screen_width(),
            2.0,
            Color::from_rgba(255, 210, 120, 180),
        );

        let label = format!("Уровень {}  |  {}", self.level, self.level_title());
        draw_text(
            &label,
            20.0,
            34.0,
            30.0,
            Color::from_rgba(255, 230, 185, 255),
        );
        draw_text(
            self.level_story(),
            20.0,
            60.0,
            18.0,
            Color::from_rgba(180, 198, 220, 255),
        );
        draw_text(
            self.level_goal(),
            20.0,
            84.0,
            18.0,
            Color::from_rgba(120, 210, 255, 255),
        );

        if self.level_progress.completed {
            draw_text(
                "Уровень уже пройден",
                screen_width() - 210.0,
                34.0,
                22.0,
                Color::from_rgba(130, 235, 170, 255),
            );
        }

        if self.level_progress.lever_pulled {
            draw_text(
                "Рычаг опущен",
                screen_width() - 170.0,
                62.0,
                22.0,
                Color::from_rgba(255, 210, 120, 255),
            );
        }
    }
}

impl Scene for GameplayScene {
    fn handle_input(&mut self) {
        if is_key_pressed(KeyCode::Escape) {
            self.next_state = Some(GameState::Town);
            return;
        }

        if self.puzzle_disabled_by_lever {
            if is_key_pressed(KeyCode::Enter) || is_key_pressed(KeyCode::Space) {
                self.next_state = Some(GameState::Town);
            }
            return;
        }

        if let Some(maze) = &mut self.maze_puzzle {
            maze.handle_input();
            if !self.puzzle_solved && maze.is_solved() {
                self.puzzle_solved = true;
            }
        }

        if let Some(wordsearch) = &mut self.wordsearch_puzzle {
            wordsearch.handle_input();
            if !self.puzzle_solved && wordsearch.is_solved() {
                self.puzzle_solved = true;
            }
        }

        if let Some(pattern) = &mut self.pattern_puzzle {
            pattern.handle_input();
            if !self.puzzle_solved && pattern.is_solved() {
                self.puzzle_solved = true;
            }
        }

        if let Some(memory_match) = &mut self.memory_match_puzzle {
            memory_match.handle_input();
            if !self.puzzle_solved && memory_match.is_solved() {
                self.puzzle_solved = true;
            }
        }

        if let Some(platformer) = &mut self.platformer_puzzle {
            platformer.handle_input();
            if !self.puzzle_solved && platformer.is_solved() {
                self.puzzle_solved = true;
            }
        }

        if let Some(final_challenge) = &mut self.final_challenge_puzzle {
            final_challenge.handle_input();
            if !self.puzzle_solved && final_challenge.is_solved() {
                self.puzzle_solved = true;
            }
        }

        if self.puzzle_solved && is_key_pressed(KeyCode::Enter) {
            self.next_state = Some(GameState::Town);
        }
    }

    fn update(&mut self) {
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

    fn draw(&self) {
        clear_background(Color::from_rgba(30, 40, 60, 255));
        self.draw_header();

        if self.puzzle_disabled_by_lever {
            let panel = Rect::new(110.0, 170.0, screen_width() - 220.0, 240.0);
            draw_rectangle(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                Color::from_rgba(18, 28, 46, 230),
            );
            draw_rectangle_lines(
                panel.x,
                panel.y,
                panel.w,
                panel.h,
                3.0,
                Color::from_rgba(255, 210, 120, 255),
            );
            draw_text(
                "Рычаг уже отключил механизм уровня.",
                panel.x + 26.0,
                panel.y + 60.0,
                30.0,
                Color::from_rgba(255, 230, 180, 255),
            );
            draw_text(
                "Головоломка пропущена, путь к следующему уровню остаётся открытым.",
                panel.x + 26.0,
                panel.y + 100.0,
                22.0,
                Color::from_rgba(195, 210, 230, 255),
            );
            draw_text(
                "Нажмите ENTER, чтобы вернуться в город.",
                panel.x + 26.0,
                panel.y + 150.0,
                22.0,
                Color::from_rgba(120, 210, 255, 255),
            );
            draw_text(
                "Чтобы снова проходить уровень вручную, поднимите рычаг в городе клавишей L.",
                panel.x + 26.0,
                panel.y + 194.0,
                18.0,
                LIGHTGRAY,
            );
            draw_text("ESC - выход", 20.0, screen_height() - 20.0, 18.0, GRAY);
            return;
        }

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

        if self.puzzle_solved {
            let overlay_color = Color::from_rgba(0, 0, 0, 180);
            draw_rectangle(0.0, 0.0, screen_width(), screen_height(), overlay_color);

            let win_text = "ГОЛОВОЛОМКА РЕШЕНА!";
            let text_size = 48.0;
            let text_width = measure_text(win_text, None, text_size as u16, 1.0).width;

            draw_text(
                win_text,
                screen_width() / 2.0 - text_width / 2.0,
                screen_height() / 2.0,
                text_size,
                Color::from_rgba(255, 215, 0, 255),
            );

            let hint = "Нажмите ENTER для возврата";
            let hint_size = 24.0;
            let hint_width = measure_text(hint, None, hint_size as u16, 1.0).width;

            draw_text(
                hint,
                screen_width() / 2.0 - hint_width / 2.0,
                screen_height() / 2.0 + 50.0,
                hint_size,
                WHITE,
            );
        }

        draw_text("ESC - выход", 20.0, screen_height() - 20.0, 18.0, GRAY);
    }

    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }

    fn take_completed_level(&mut self) -> Option<u8> {
        if self.puzzle_solved && !self.completed_level_reported {
            self.completed_level_reported = true;
            Some(self.level)
        } else {
            None
        }
    }
}
