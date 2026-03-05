// Система спрайтов для игры
// Здесь можно заменить спрайты на свои

use macroquad::prelude::*;

// Пути к спрайтам игрока (анимация ходьбы)
pub const PLAYER_SPRITE_DOWN: &str = "assets/sprites/player_down.png";
pub const PLAYER_SPRITE_UP: &str = "assets/sprites/player_up.png";
pub const PLAYER_SPRITE_LEFT: &str = "assets/sprites/player_left.png";
pub const PLAYER_SPRITE_RIGHT: &str = "assets/sprites/player_right.png";

// Пути к спрайтам предмета
pub const ITEM_SPRITE_PATH: &str = "assets/sprites/item.png";

// Пути к спрайтам врага
pub const ENEMY_SPRITE_PATH: &str = "assets/sprites/enemy.png";

// Пути к спрайтам NPC
pub const NPC_SPRITE_PATH: &str = "assets/sprites/npc.png";

// Пути к спрайтам платформы
pub const PLATFORM_SPRITE_PATH: &str = "assets/sprites/platform.png";

// Пути к спрайтам рычага
pub const LEVER_SPRITE_PATH: &str = "assets/sprites/lever.png";

// Загрузка всех спрайтов игрока
pub async fn load_player_sprites() -> (Option<Texture2D>, Option<Texture2D>, Option<Texture2D>, Option<Texture2D>) {
    let down = load_texture(PLAYER_SPRITE_DOWN).await.ok();
    let up = load_texture(PLAYER_SPRITE_UP).await.ok();
    let left = load_texture(PLAYER_SPRITE_LEFT).await.ok();
    let right = load_texture(PLAYER_SPRITE_RIGHT).await.ok();
    (down, up, left, right)
}

// Загрузка спрайта предмета
pub async fn load_item_sprite() -> Option<Texture2D> {
    load_texture(ITEM_SPRITE_PATH).await.ok()
}

// Загрузка спрайта врага
pub async fn load_enemy_sprite() -> Option<Texture2D> {
    load_texture(ENEMY_SPRITE_PATH).await.ok()
}

// Загрузка спрайта NPC
pub async fn load_npc_sprite() -> Option<Texture2D> {
    load_texture(NPC_SPRITE_PATH).await.ok()
}

// Загрузка спрайта платформы
pub async fn load_platform_sprite() -> Option<Texture2D> {
    load_texture(PLATFORM_SPRITE_PATH).await.ok()
}

// Загрузка спрайта рычага
pub async fn load_lever_sprite() -> Option<Texture2D> {
    load_texture(LEVER_SPRITE_PATH).await.ok()
}

// Пример функции отрисовки спрайта игрока
pub fn draw_player_sprite(texture: &Texture2D, x: f32, y: f32, width: f32, height: f32) {
    draw_texture_ex(
        texture,
        x,
        y,
        WHITE,
        DrawTextureParams {
            dest_size: Some(Vec2::new(width, height)),
            ..Default::default()
        },
    );
}

// Пример функции отрисовки спрайта предмета
pub fn draw_item_sprite(texture: &Texture2D, x: f32, y: f32, size: f32) {
    draw_texture_ex(
        texture,
        x,
        y,
        WHITE,
        DrawTextureParams {
            dest_size: Some(Vec2::new(size, size)),
            ..Default::default()
        },
    );
}
