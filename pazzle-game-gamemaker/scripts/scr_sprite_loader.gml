/// @description Sprite loader system for asset management
/// @function sprite_load_from_path(path)
/// @param path Path to the sprite file

// Global map for storing loaded sprites
if (!global_exists("g_asset_sprites")) {
    global.g_asset_sprites = ds_map_create();
}

// Player sprite constants
const PLAYER_SPRITE_DOWN_PATH = "assets/sprites/player_down.png";
const PLAYER_SPRITE_UP_PATH = "assets/sprites/player_up.png";
const PLAYER_SPRITE_LEFT_PATH = "assets/sprites/player_left.png";
const PLAYER_SPRITE_RIGHT_PATH = "assets/sprites/player_right.png";

// Item sprite constant
const ITEM_SPRITE_PATH = "assets/sprites/item.png";

// Enemy sprite constant
const ENEMY_SPRITE_PATH = "assets/sprites/enemy.png";

// NPC sprite constants
const NPC_ROAN_PATH = "assets/sprites/npc_roan.png";
const NPC_TELLAH_PATH = "assets/sprites/npc_tellah.png";
const NPC_YORE_PATH = "assets/sprites/npc_yore.png";

// Level element sprite constants
const LEVER_SPRITE_PATH = "assets/sprites/lever.png";
const PLATFORM_SPRITE_PATH = "assets/sprites/platform.png";
const CLOCKWORK_EMBLEM_PATH = "assets/sprites/clockwork_emblem.png";
const MIRROR_SHARD_PATH = "assets/sprites/mirror_shard.png";
const CRYSTAL_CLUSTER_PATH = "assets/sprites/crystal_cluster.png";
const CORE_SPIRE_PATH = "assets/sprites/core_spire.png";

/// Load a sprite by path and store in cache
function sprite_load_from_path(path) {
    var sprite_id = ds_map_find_value(g_asset_sprites, path);
    
    if (sprite_id == undefined) {
        // In actual implementation, this would load the sprite file
        // For now, we'll simulate by creating placeholder sprites
        sprite_id = sprite_add(path, 1); // 1 frame initially
        
        if (sprite_id != -1) {
            ds_map_set(g_asset_sprites, path, sprite_id);
        }
    }
    
    return sprite_id;
}

/// Load all player sprites 
function load_player_sprites() {
    var sprites = array_create(4); // [down, up, left, right]
    sprites[0] = sprite_load_from_path(PLAYER_SPRITE_DOWN_PATH);
    sprites[1] = sprite_load_from_path(PLAYER_SPRITE_UP_PATH);
    sprites[2] = sprite_load_from_path(PLAYER_SPRITE_LEFT_PATH);
    sprites[3] = sprite_load_from_path(PLAYER_SPRITE_RIGHT_PATH);
    
    if (!global_exists("g_player_sprites")) {
        global.g_player_sprites = sprites;
    }
    
    return sprites;
}

/// Load item sprite
function load_item_sprite() {
    var sprite_id = sprite_load_from_path(ITEM_SPRITE_PATH);
    
    if (!global_exists("g_item_sprite")) {
        global.g_item_sprite = sprite_id;
    }
    
    return sprite_id;
}

/// Load enemy sprite
function load_enemy_sprite() {
    var sprite_id = sprite_load_from_path(ENEMY_SPRITE_PATH);
    
    if (!global_exists("g_enemy_sprite")) {
        global.g_enemy_sprite = sprite_id;
    }
    
    return sprite_id;
}

/// Load NPC sprites
function load_npc_sprites() {
    var npc_sprites = array_create(3); // [yore, roan, tellah]
    npc_sprites[0] = sprite_load_from_path(NPC_YORE_PATH);
    npc_sprites[1] = sprite_load_from_path(NPC_ROAN_PATH);
    npc_sprites[2] = sprite_load_from_path(NPC_TELLAH_PATH);
    
    if (!global_exists("g_npc_sprites")) {
        global.g_npc_sprites = npc_sprites;
    }
    
    return npc_sprites;
}

/// Get player sprite by direction
function get_player_sprite_by_direction(direction) {
    var facing = "down";
    switch (string_lower(direction)) {
        case "up": facing = "up"; break;
        case "left": facing = "left"; break;
        case "right": facing = "right"; break;
        case "down":
        default: facing = "down"; break;
    }
    
    var sprites = load_player_sprites();
    switch (facing) {
        case "down": return sprites[0];
        case "up": return sprites[1];
        case "left": return sprites[2];
        case "right": return sprites[3];
        default: return sprites[0];
    }
}

/// Get NPC texture by index
function get_npc_sprite_by_index(index) {
    var sprites = load_npc_sprites();
    if (index >= 0 && index < array_length(sprites)) {
        return sprites[index];
    } else {
        return sprites[0]; // Default to NPC_YORE
    }
}

/// Get item sprite
function get_item_sprite() {
    if (!global_exists("g_item_sprite")) {
        load_item_sprite();
    }
    return global.g_item_sprite;
}

/// Get lever sprite
function get_lever_sprite() {
    return sprite_load_from_path(LEVER_SPRITE_PATH);
}

/// Get platform sprite
function get_platform_sprite() {
    return sprite_load_from_path(PLATFORM_SPRITE_PATH);
}

/// Get enemy sprite
function get_enemy_sprite() {
    if (!global_exists("g_enemy_sprite")) {
        load_enemy_sprite();
    }
    return global.g_enemy_sprite;
}

/// Get clockwork emblem sprite
function get_clockwork_emblem_sprite() {
    return sprite_load_from_path(CLOCKWORK_EMBLEM_PATH);
}

/// Get mirror shard sprite
function get_mirror_shard_sprite() {
    return sprite_load_from_path(MIRROR_SHARD_PATH);
}

/// Get crystal cluster sprite
function get_crystal_cluster_sprite() {
    return sprite_load_from_path(CRYSTAL_CLUSTER_PATH);
}

/// Get core spire sprite
function get_core_spire_sprite() {
    return sprite_load_from_path(CORE_SPIRE_PATH);
}

/// Clean up all loaded sprites
function asset_cleanup() {
    var keys = ds_map_keys(g_asset_sprites);
    for (var i = 0; i < ds_list_size(keys); i++) {
        var key = ds_list_find_value(keys, i);
        var sprite_id = ds_map_find_value(g_asset_sprites, key);
        if (sprite_get_name(sprite_id) != "") {
            sprite_delete(sprite_id);
        }
    }
    ds_map_clear(g_asset_sprites);
    ds_list_destroy(keys);
}