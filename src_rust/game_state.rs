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

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ProgressUpdate {
    LeverPulled { level: u8, pulled: bool },
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
            prev_level.lever_pulled
        } else {
            false
        }
    }

    pub fn level_progress(&self, level: u8) -> LevelProgress {
        self.levels.get(&level).cloned().unwrap_or_default()
    }

    pub fn is_level_completed(&self, level: u8) -> bool {
        self.levels
            .get(&level)
            .map(|progress| progress.completed)
            .unwrap_or(false)
    }

    pub fn is_lever_pulled(&self, level: u8) -> bool {
        self.levels
            .get(&level)
            .map(|progress| progress.lever_pulled)
            .unwrap_or(false)
    }

    pub fn complete_level(&mut self, level: u8) {
        if let Some(progress) = self.levels.get_mut(&level) {
            progress.completed = true;
        }
    }

    pub fn set_lever_pulled(&mut self, level: u8, pulled: bool) {
        if let Some(progress) = self.levels.get_mut(&level) {
            if progress.completed {
                progress.lever_pulled = pulled;
            } else if !pulled {
                progress.lever_pulled = false;
            }
        }
    }

    pub fn apply_update(&mut self, update: ProgressUpdate) {
        match update {
            ProgressUpdate::LeverPulled { level, pulled } => self.set_lever_pulled(level, pulled),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::GameProgress;

    #[test]
    fn only_first_level_is_unlocked_in_new_save() {
        let progress = GameProgress::default();

        assert!(progress.is_level_unlocked(1));
        assert!(!progress.is_level_unlocked(2));
        assert!(!progress.is_level_unlocked(3));
    }

    #[test]
    fn completing_a_level_without_lever_does_not_unlock_the_next_one() {
        let mut progress = GameProgress::default();
        progress.complete_level(1);
        progress.complete_level(2);

        assert!(!progress.is_level_unlocked(2));
        assert!(!progress.is_level_unlocked(3));
    }

    #[test]
    fn pulling_the_lever_unlocks_the_next_level() {
        let mut progress = GameProgress::default();
        progress.complete_level(1);
        progress.set_lever_pulled(1, true);
        progress.complete_level(2);
        progress.set_lever_pulled(2, true);

        assert!(progress.is_level_unlocked(2));
        assert!(progress.is_level_unlocked(3));
        assert!(!progress.is_level_unlocked(4));
    }

    #[test]
    fn lever_cannot_be_enabled_before_completion() {
        let mut progress = GameProgress::default();
        progress.set_lever_pulled(1, true);

        assert!(!progress.is_lever_pulled(1));
    }

    #[test]
    fn completed_level_can_store_lever_state() {
        let mut progress = GameProgress::default();
        progress.complete_level(1);
        progress.set_lever_pulled(1, true);

        assert!(progress.is_lever_pulled(1));
        assert!(progress.is_level_unlocked(2));
    }
}
