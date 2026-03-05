use crate::game_state::GameState;

pub mod menu;
pub mod town;
pub mod gameplay;
pub mod village;
pub mod room;
pub mod puzzles;

pub use menu::MenuScene;
pub use town::TownScene;
pub use gameplay::GameplayScene;
pub use village::VillageScene;
pub use room::RoomScene;

/// Трейт для всех игровых сцен
pub trait Scene {
    /// Обработка ввода
    fn handle_input(&mut self);
    
    /// Обновление логики
    fn update(&mut self);
    
    /// Отрисовка
    fn draw(&self);
    
    /// Получить следующее состояние (если нужно сменить сцену)
    fn get_next_state(&self) -> Option<GameState>;
}
