use macroquad::prelude::*;

mod game_state;
mod scenes;
mod entities;
mod utils;

use game_state::{GameState, GameProgress};
use scenes::{Scene, MenuScene, VillageScene, RoomScene, GameplayScene};

const SCREEN_WIDTH: f32 = 800.0;
const SCREEN_HEIGHT: f32 = 600.0;

#[macroquad::main("Приключенческая игра с головоломками")]
async fn main() {
    // Настройка окна
    request_new_screen_size(SCREEN_WIDTH, SCREEN_HEIGHT);
    
    // Загрузка прогресса
    let mut game_progress = GameProgress::load().unwrap_or_default();
    
    // Начальная сцена - меню
    let mut current_scene: Box<dyn Scene> = Box::new(MenuScene::new());
    let mut game_state = GameState::Menu;
    
    loop {
        clear_background(BLACK);
        
        // Обработка событий
        current_scene.handle_input();
        
        // Обновление
        current_scene.update();
        
        // Отрисовка
        current_scene.draw();
        
        // Проверка смены сцены
        if let Some(next_state) = current_scene.get_next_state() {
            game_state = next_state;
            
            current_scene = match game_state {
                GameState::Menu => Box::new(MenuScene::new()),
                GameState::Village => Box::new(VillageScene::new(game_progress.clone())),
                GameState::Room(room_id) => Box::new(RoomScene::new(room_id, game_progress.clone())),
                GameState::Playing(level) => Box::new(GameplayScene::new(level)),
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
