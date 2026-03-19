use std::cell::RefCell;

use macroquad::audio::{load_sound_from_bytes, play_sound, stop_sound, PlaySoundParams, Sound};

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum MusicTrack {
    Menu,
    Town,
    Cave,
    Victory,
}

struct SoundBank {
    ui_move: Option<Sound>,
    ui_confirm: Option<Sound>,
    ui_cancel: Option<Sound>,
    ui_success: Option<Sound>,
    lever: Option<Sound>,
    music_menu: Option<Sound>,
    music_town: Option<Sound>,
    music_cave: Option<Sound>,
    music_victory: Option<Sound>,
    current_music: Option<MusicTrack>,
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
        music_menu: load_sound_from_bytes(include_bytes!("../assets/audio/music_menu.wav"))
            .await
            .ok(),
        music_town: load_sound_from_bytes(include_bytes!("../assets/audio/music_town.wav"))
            .await
            .ok(),
        music_cave: load_sound_from_bytes(include_bytes!("../assets/audio/music_cave.wav"))
            .await
            .ok(),
        music_victory: load_sound_from_bytes(include_bytes!("../assets/audio/music_victory.wav"))
            .await
            .ok(),
        current_music: None,
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

fn stop(sound: &Option<Sound>) {
    if let Some(sound) = sound {
        stop_sound(sound);
    }
}

pub fn play_music(track: MusicTrack) {
    SOUND_BANK.with(|slot| {
        let mut binding = slot.borrow_mut();
        let Some(bank) = binding.as_mut() else {
            return;
        };

        if bank.current_music == Some(track) {
            return;
        }

        stop(&bank.music_menu);
        stop(&bank.music_town);
        stop(&bank.music_cave);
        stop(&bank.music_victory);

        let sound = match track {
            MusicTrack::Menu => &bank.music_menu,
            MusicTrack::Town => &bank.music_town,
            MusicTrack::Cave => &bank.music_cave,
            MusicTrack::Victory => &bank.music_victory,
        };

        if let Some(sound) = sound {
            play_sound(
                sound,
                PlaySoundParams {
                    looped: true,
                    volume: 0.26,
                },
            );
            bank.current_music = Some(track);
        } else {
            bank.current_music = None;
        }
    });
}

pub fn stop_music() {
    SOUND_BANK.with(|slot| {
        let mut binding = slot.borrow_mut();
        let Some(bank) = binding.as_mut() else {
            return;
        };

        stop(&bank.music_menu);
        stop(&bank.music_town);
        stop(&bank.music_cave);
        stop(&bank.music_victory);
        bank.current_music = None;
    });
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
