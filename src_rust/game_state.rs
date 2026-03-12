use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum GameState {
    Menu,
    Town,
    Playing(u8),
    Quit,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LevelProgress {
    pub completed: bool,
    pub lever_pulled: bool,
}

impl Default for LevelProgress {
    fn default() -> Self {
        Self {
            completed: false,
            lever_pulled: false,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GameProgress {
    pub levels: HashMap<u8, LevelProgress>,
    pub gold: i32,
    pub items: Vec<String>,
}

impl Default for GameProgress {
    fn default() -> Self {
        let mut levels = HashMap::new();
        for i in 1..=6 {
            levels.insert(i, LevelProgress::default());
        }
        
        Self {
            levels,
            gold: 100,
            items: Vec::new(),
        }
    }
}

impl GameProgress {
    pub fn save(&self) -> Result<(), Box<dyn std::error::Error>> {
        let json = serde_json::to_string_pretty(self)?;
        fs::write("savegame.json", json)?;
        Ok(())
    }
    
    pub fn load() -> Result<Self, Box<dyn std::error::Error>> {
        let json = fs::read_to_string("savegame.json")?;
        let progress = serde_json::from_str(&json)?;
        Ok(progress)
    }
    
    pub fn is_level_unlocked(&self, level: u8) -> bool {
        if level == 1 {
            return true;
        }
        
        if let Some(prev_level) = self.levels.get(&(level - 1)) {
            prev_level.completed
        } else {
            false
        }
    }
    
    pub fn complete_level(&mut self, level: u8) {
        if let Some(progress) = self.levels.get_mut(&level) {
            progress.completed = true;
        }
    }
}
