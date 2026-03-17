use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum GameState {
    Menu,
    Town,
    Playing(u8),
    Victory,
    ResetGame,
    Quit,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ProgressUpdate {
    LeverPulled { level: u8, pulled: bool },
    MechanicTrainingCompleted,
    ArchivistQuizCompleted,
    ElderTrialCompleted,
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
    #[serde(default)]
    pub mechanic_training_completed: bool,
    #[serde(default)]
    pub archivist_quiz_completed: bool,
    #[serde(default)]
    pub elder_trial_completed: bool,
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
            mechanic_training_completed: false,
            archivist_quiz_completed: false,
            elder_trial_completed: false,
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

    pub fn opened_count(&self) -> usize {
        (1..=6).filter(|level| self.is_lever_pulled(*level)).count()
    }

    pub fn completed_count(&self) -> usize {
        (1..=6)
            .filter(|level| self.is_level_completed(*level))
            .count()
    }

    pub fn current_objective_level(&self) -> u8 {
        for level in 1..=6 {
            if self.is_level_unlocked(level) && !self.is_lever_pulled(level) {
                return level;
            }
        }

        6
    }

    pub fn is_expedition_complete(&self) -> bool {
        self.is_lever_pulled(6)
    }

    pub fn is_mechanic_training_completed(&self) -> bool {
        self.mechanic_training_completed
    }

    pub fn item_count(&self) -> usize {
        self.items.len()
    }

    pub fn is_archivist_quiz_completed(&self) -> bool {
        self.archivist_quiz_completed
    }

    pub fn is_elder_trial_completed(&self) -> bool {
        self.elder_trial_completed
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
            ProgressUpdate::MechanicTrainingCompleted => {
                if !self.mechanic_training_completed {
                    self.mechanic_training_completed = true;
                    self.gold += 35;
                    let reward = "Ключ механика".to_string();
                    if !self.items.iter().any(|item| item == &reward) {
                        self.items.push(reward);
                    }
                }
            }
            ProgressUpdate::ArchivistQuizCompleted => {
                if !self.archivist_quiz_completed {
                    self.archivist_quiz_completed = true;
                    self.gold += 25;
                    let reward = "Печать архивариуса".to_string();
                    if !self.items.iter().any(|item| item == &reward) {
                        self.items.push(reward);
                    }
                }
            }
            ProgressUpdate::ElderTrialCompleted => {
                if !self.elder_trial_completed {
                    self.elder_trial_completed = true;
                    self.gold += 30;
                    let reward = "Талисман старосты".to_string();
                    if !self.items.iter().any(|item| item == &reward) {
                        self.items.push(reward);
                    }
                }
            }
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

    #[test]
    fn expedition_is_complete_only_after_final_lever() {
        let mut progress = GameProgress::default();
        for level in 1..=5 {
            progress.complete_level(level);
            progress.set_lever_pulled(level, true);
        }

        assert!(!progress.is_expedition_complete());

        progress.complete_level(6);
        progress.set_lever_pulled(6, true);

        assert!(progress.is_expedition_complete());
    }

    #[test]
    fn mechanic_training_reward_is_applied_only_once() {
        let mut progress = GameProgress::default();

        progress.apply_update(super::ProgressUpdate::MechanicTrainingCompleted);
        progress.apply_update(super::ProgressUpdate::MechanicTrainingCompleted);

        assert!(progress.is_mechanic_training_completed());
        assert_eq!(progress.gold, 135);
        assert_eq!(progress.items.len(), 1);
        assert_eq!(progress.items[0], "Ключ механика");
    }

    #[test]
    fn archivist_quiz_reward_is_applied_only_once() {
        let mut progress = GameProgress::default();

        progress.apply_update(super::ProgressUpdate::ArchivistQuizCompleted);
        progress.apply_update(super::ProgressUpdate::ArchivistQuizCompleted);

        assert!(progress.is_archivist_quiz_completed());
        assert_eq!(progress.gold, 125);
        assert_eq!(progress.items.len(), 1);
        assert_eq!(progress.items[0], "Печать архивариуса");
    }

    #[test]
    fn elder_trial_reward_is_applied_only_once() {
        let mut progress = GameProgress::default();

        progress.apply_update(super::ProgressUpdate::ElderTrialCompleted);
        progress.apply_update(super::ProgressUpdate::ElderTrialCompleted);

        assert!(progress.is_elder_trial_completed());
        assert_eq!(progress.gold, 130);
        assert_eq!(progress.items.len(), 1);
        assert_eq!(progress.items[0], "Талисман старосты");
    }
}
