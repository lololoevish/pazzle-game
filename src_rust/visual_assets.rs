use std::cell::RefCell;

use macroquad::prelude::*;

#[derive(Clone, Copy)]
pub enum Facing {
    Down,
    Up,
    Left,
    Right,
}

struct VisualAssets {
    player_down: Texture2D,
    player_up: Texture2D,
    player_left: Texture2D,
    player_right: Texture2D,
    npc_roan: Texture2D,
    npc_tellah: Texture2D,
    npc_yore: Texture2D,
    lever: Texture2D,
    item: Texture2D,
    platform: Texture2D,
    enemy: Texture2D,
    clockwork_emblem: Texture2D,
    mirror_shard: Texture2D,
    crystal_cluster: Texture2D,
    core_spire: Texture2D,
}

thread_local! {
    static ASSETS: RefCell<Option<VisualAssets>> = const { RefCell::new(None) };
}

fn load_texture(bytes: &[u8]) -> Texture2D {
    let texture = Texture2D::from_file_with_format(bytes, Some(ImageFormat::Png));
    texture.set_filter(FilterMode::Nearest);
    texture
}

fn with_assets<R>(f: impl FnOnce(&VisualAssets) -> R) -> R {
    ASSETS.with(|slot| {
        if slot.borrow().is_none() {
            let assets = VisualAssets {
                player_down: load_texture(include_bytes!("../assets/sprites/player_down.png")),
                player_up: load_texture(include_bytes!("../assets/sprites/player_up.png")),
                player_left: load_texture(include_bytes!("../assets/sprites/player_left.png")),
                player_right: load_texture(include_bytes!("../assets/sprites/player_right.png")),
                npc_roan: load_texture(include_bytes!("../assets/sprites/npc_roan.png")),
                npc_tellah: load_texture(include_bytes!("../assets/sprites/npc_tellah.png")),
                npc_yore: load_texture(include_bytes!("../assets/sprites/npc_yore.png")),
                lever: load_texture(include_bytes!("../assets/sprites/lever.png")),
                item: load_texture(include_bytes!("../assets/sprites/item.png")),
                platform: load_texture(include_bytes!("../assets/sprites/platform.png")),
                enemy: load_texture(include_bytes!("../assets/sprites/enemy.png")),
                clockwork_emblem: load_texture(include_bytes!(
                    "../assets/sprites/clockwork_emblem.png"
                )),
                mirror_shard: load_texture(include_bytes!("../assets/sprites/mirror_shard.png")),
                crystal_cluster: load_texture(include_bytes!(
                    "../assets/sprites/crystal_cluster.png"
                )),
                core_spire: load_texture(include_bytes!("../assets/sprites/core_spire.png")),
            };
            *slot.borrow_mut() = Some(assets);
        }

        let borrow = slot.borrow();
        let assets = borrow.as_ref().expect("visual assets initialized");
        f(assets)
    })
}

pub fn player_texture(facing: Facing) -> Texture2D {
    with_assets(|assets| match facing {
        Facing::Down => assets.player_down.clone(),
        Facing::Up => assets.player_up.clone(),
        Facing::Left => assets.player_left.clone(),
        Facing::Right => assets.player_right.clone(),
    })
}

pub fn npc_roan_texture() -> Texture2D {
    with_assets(|assets| assets.npc_roan.clone())
}

pub fn npc_tellah_texture() -> Texture2D {
    with_assets(|assets| assets.npc_tellah.clone())
}

pub fn npc_yore_texture() -> Texture2D {
    with_assets(|assets| assets.npc_yore.clone())
}

pub fn npc_texture_by_index(index: usize) -> Texture2D {
    match index {
        0 => npc_yore_texture(),   // Староста Иара
        1 => npc_roan_texture(),   // Механик Роан
        2 => npc_tellah_texture(), // Архивариус Тель
        _ => npc_yore_texture(),
    }
}

pub fn lever_texture() -> Texture2D {
    with_assets(|assets| assets.lever.clone())
}

pub fn item_texture() -> Texture2D {
    with_assets(|assets| assets.item.clone())
}

pub fn platform_texture() -> Texture2D {
    with_assets(|assets| assets.platform.clone())
}

pub fn enemy_texture() -> Texture2D {
    with_assets(|assets| assets.enemy.clone())
}

pub fn clockwork_emblem_texture() -> Texture2D {
    with_assets(|assets| assets.clockwork_emblem.clone())
}

pub fn mirror_shard_texture() -> Texture2D {
    with_assets(|assets| assets.mirror_shard.clone())
}

pub fn crystal_cluster_texture() -> Texture2D {
    with_assets(|assets| assets.crystal_cluster.clone())
}

pub fn core_spire_texture() -> Texture2D {
    with_assets(|assets| assets.core_spire.clone())
}

pub fn draw_sprite(texture: &Texture2D, x: f32, y: f32, width: f32, height: f32, tint: Color) {
    draw_texture_ex(
        texture,
        x,
        y,
        tint,
        DrawTextureParams {
            dest_size: Some(vec2(width, height)),
            ..Default::default()
        },
    );
}
