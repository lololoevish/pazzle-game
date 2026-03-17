use macroquad::prelude::*;
use std::fs;

mod audio;
mod game_state;
mod scenes;
mod ui_text;
mod visual_assets;

use game_state::{GameProgress, GameState};
use scenes::{GameplayScene, MenuScene, Scene, TownScene, VictoryScene};

const SCREEN_WIDTH: f32 = 800.0;
const SCREEN_HEIGHT: f32 = 600.0;
const TRANSITION_SPEED: f32 = 3.2;

enum SceneTransition {
    FadeOut { next_state: GameState, alpha: f32 },
    FadeIn { alpha: f32 },
}

fn build_scene(state: GameState, progress: &GameProgress) -> Box<dyn Scene> {
    match state {
        GameState::Menu => Box::new(MenuScene::new(progress.clone())),
        GameState::Town => Box::new(TownScene::new(progress.clone())),
        GameState::Playing(level) => {
            Box::new(GameplayScene::new(level, progress.level_progress(level)))
        }
        GameState::Victory => Box::new(VictoryScene::new(progress.clone())),
        GameState::ResetGame => Box::new(MenuScene::new(progress.clone())),
        GameState::Quit => Box::new(MenuScene::new(progress.clone())),
    }
}

fn draw_transition_overlay(alpha: f32, time: f32) {
    if alpha <= 0.0 {
        return;
    }

    draw_rectangle(
        0.0,
        0.0,
        screen_width(),
        screen_height(),
        Color::new(0.01, 0.02, 0.04, alpha.clamp(0.0, 1.0)),
    );

    let glow_alpha = alpha * 0.32;
    let pulse = (time * 3.0).sin() * 0.5 + 0.5;
    draw_circle(
        screen_width() * 0.5,
        screen_height() * 0.5,
        70.0 + pulse * 26.0,
        Color::new(0.84, 0.72, 0.34, glow_alpha * 0.35),
    );
    draw_circle_lines(
        screen_width() * 0.5,
        screen_height() * 0.5,
        44.0 + pulse * 18.0,
        3.0,
        Color::new(0.96, 0.84, 0.48, glow_alpha),
    );
    draw_circle_lines(
        screen_width() * 0.5,
        screen_height() * 0.5,
        96.0 + pulse * 22.0,
        2.0,
        Color::new(0.52, 0.78, 1.0, glow_alpha * 0.7),
    );
}

#[macroquad::main("Приключенческая игра с головоломками")]
async fn main() {
    // Настройка окна
    request_new_screen_size(SCREEN_WIDTH, SCREEN_HEIGHT);
    ui_text::init().await;
    audio::init().await;

    // Загрузка прогресса
    let mut game_progress = GameProgress::load().unwrap_or_default();

    // Начальная сцена - меню
    let mut current_scene: Box<dyn Scene> = Box::new(MenuScene::new(game_progress.clone()));
    let mut transition: Option<SceneTransition> = None;
    let mut transition_time = 0.0;
    loop {
        clear_background(BLACK);
        let frame_time = get_frame_time();
        transition_time += frame_time;

        if transition.is_none() {
            // Обработка событий
            current_scene.handle_input();

            // Обновление
            current_scene.update();

            if let Some(completed_level) = current_scene.take_completed_level() {
                game_progress.complete_level(completed_level);
                game_progress.save().ok();
            }

            if let Some(update) = current_scene.take_progress_update() {
                game_progress.apply_update(update);
                game_progress.save().ok();
            }

            // Проверка смены сцены
            if let Some(next_state) = current_scene.get_next_state() {
                transition = Some(SceneTransition::FadeOut {
                    next_state,
                    alpha: 0.0,
                });
            }
        }

        // Отрисовка
        current_scene.draw();

        // Сохранение прогресса
        if is_key_pressed(KeyCode::F5) {
            game_progress.save().ok();
        }

        let mut should_quit = false;
        if let Some(active_transition) = &mut transition {
            match active_transition {
                SceneTransition::FadeOut { next_state, alpha } => {
                    *alpha = (*alpha + frame_time * TRANSITION_SPEED).min(1.0);
                    draw_transition_overlay(*alpha, transition_time);

                    if *alpha >= 1.0 {
                        if *next_state == GameState::Quit {
                            should_quit = true;
                        } else if *next_state == GameState::ResetGame {
                            game_progress = GameProgress::default();
                            let _ = fs::remove_file("savegame.json");
                            game_progress.save().ok();
                            current_scene = Box::new(TownScene::new(game_progress.clone()));
                            transition = Some(SceneTransition::FadeIn { alpha: 1.0 });
                        } else {
                            current_scene = build_scene(*next_state, &game_progress);
                            transition = Some(SceneTransition::FadeIn { alpha: 1.0 });
                        }
                    }
                }
                SceneTransition::FadeIn { alpha } => {
                    draw_transition_overlay(*alpha, transition_time);
                    *alpha = (*alpha - frame_time * TRANSITION_SPEED).max(0.0);
                    if *alpha <= 0.0 {
                        transition = None;
                    }
                }
            }
        }

        if should_quit {
            break;
        }

        next_frame().await
    }

    // Сохранение при выходе
    game_progress.save().ok();
}
