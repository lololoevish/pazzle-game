use crate::game_state::GameState;

pub mod menu;
pub mod town;
pub mod gameplay;
pub mod puzzles;

pub use menu::MenuScene;
pub use town::TownScene;
pub use gameplay::GameplayScene;

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

    /// Забрать завершённый уровень для обновления сохранения.
    fn take_completed_level(&mut self) -> Option<u8> {
        None
    }
}
