use std::cell::RefCell;

use macroquad::audio::{load_sound_from_bytes, play_sound, PlaySoundParams, Sound};

struct SoundBank {
    ui_move: Option<Sound>,
    ui_confirm: Option<Sound>,
    ui_cancel: Option<Sound>,
    ui_success: Option<Sound>,
    lever: Option<Sound>,
}

thread_local! {
    static SOUND_BANK: RefCell<Option<SoundBank>> = const { RefCell::new(None) };
}

pub async fn init() {
    let bank = SoundBank {
        ui_move: load_sound_from_bytes(include_bytes!("../assets/audio/ui_move.wav"))
            .await
            .ok(),
        ui_confirm: load_sound_from_bytes(include_bytes!("../assets/audio/ui_confirm.wav"))
            .await
            .ok(),
        ui_cancel: load_sound_from_bytes(include_bytes!("../assets/audio/ui_cancel.wav"))
            .await
            .ok(),
        ui_success: load_sound_from_bytes(include_bytes!("../assets/audio/ui_success.wav"))
            .await
            .ok(),
        lever: load_sound_from_bytes(include_bytes!("../assets/audio/lever.wav"))
            .await
            .ok(),
    };

    SOUND_BANK.with(|slot| {
        *slot.borrow_mut() = Some(bank);
    });
}

fn play(sound: &Option<Sound>, volume: f32) {
    if let Some(sound) = sound {
        play_sound(
            sound,
            PlaySoundParams {
                looped: false,
                volume,
            },
        );
    }
}

pub fn play_ui_move() {
    SOUND_BANK.with(|slot| {
        if let Some(bank) = slot.borrow().as_ref() {
            play(&bank.ui_move, 0.45);
        }
    });
}

pub fn play_ui_confirm() {
    SOUND_BANK.with(|slot| {
        if let Some(bank) = slot.borrow().as_ref() {
            play(&bank.ui_confirm, 0.55);
        }
    });
}

pub fn play_ui_cancel() {
    SOUND_BANK.with(|slot| {
        if let Some(bank) = slot.borrow().as_ref() {
            play(&bank.ui_cancel, 0.50);
        }
    });
}

pub fn play_ui_success() {
    SOUND_BANK.with(|slot| {
        if let Some(bank) = slot.borrow().as_ref() {
            play(&bank.ui_success, 0.58);
        }
    });
}

pub fn play_lever() {
    SOUND_BANK.with(|slot| {
        if let Some(bank) = slot.borrow().as_ref() {
            play(&bank.lever, 0.62);
        }
    });
}
