// Аудио менеджер для GameMaker
// Управляет музыкой и звуковыми эффектами

// Группы аудио
var audio_groups = {
    sfx: {},
    music: {}
};

// Загрузка аудио файлов
function initialize_audio() {
    // Звуки UI
    audio_groups.sfx.confirm = sound_find("ui_confirm");
    audio_groups.sfx.cancel = sound_find("ui_cancel");
    audio_groups.sfx.move = sound_find("ui_move");
    audio_groups.sfx.success = sound_find("ui_success");
    audio_groups.sfx.lever = sound_find("lever");
    
    // Музыкальные темы
    audio_groups.music.menu = sound_find("music_menu");
    audio_groups.music.town = sound_find("music_town");
    audio_groups.music.cave = sound_find("music_cave");
    audio_groups.music.victory = sound_find("music_victory");
    
    return audio_groups;
}

// Проигрывание SFX
function play_sfx(sound_name) {
    var sound_id = audio_groups.sfx[sound_name];
    if (sound_id != undefined) {
        audio_play_sound(sound_id, 0, false);
    }
}

// Проигрывание музыки
function play_music(music_name, looping = true) {
    // Остановить текущую музыку
    audio_stop_all();
    
    var music_id = audio_groups.music[music_name];
    if (music_id != undefined) {
        audio_play_sound(music_id, 0, looping);
    }
}

// Остановка музыки
function stop_music() {
    // Остановить все музыкальные треки
    audio_stop_all();
}