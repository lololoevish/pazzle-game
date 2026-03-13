use macroquad::prelude::*;

mod game_state;
mod scenes;
mod ui_text;

use game_state::{GameProgress, GameState};
use scenes::{GameplayScene, MenuScene, Scene, TownScene};

const SCREEN_WIDTH: f32 = 800.0;
const SCREEN_HEIGHT: f32 = 600.0;

#[macroquad::main("Приключенческая игра с головоломками")]
async fn main() {
    // Настройка окна
    request_new_screen_size(SCREEN_WIDTH, SCREEN_HEIGHT);
    ui_text::init().await;

    // Загрузка прогресса
    let mut game_progress = GameProgress::load().unwrap_or_default();

    // Начальная сцена - меню
    let mut current_scene: Box<dyn Scene> = Box::new(MenuScene::new());
    loop {
        clear_background(BLACK);

        // Обработка событий
        current_scene.handle_input();

        // Обновление
        current_scene.update();

        // Отрисовка
        current_scene.draw();

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
            current_scene = match next_state {
                GameState::Menu => Box::new(MenuScene::new()),
                GameState::Town => Box::new(TownScene::new(game_progress.clone())),
                GameState::Playing(level) => Box::new(GameplayScene::new(
                    level,
                    game_progress.level_progress(level),
                )),
                GameState::Quit => break,
            };
        }

        // Сохранение прогресса
        if is_key_pressed(KeyCode::F5) {
            game_progress.save().ok();
        }

        next_frame().await
    }

    // Сохранение при выходе
    game_progress.save().ok();
}
