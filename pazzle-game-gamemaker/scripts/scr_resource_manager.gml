/// @description Resource management system for game assets
/// @function resource_preload_all()

// Resource types
const RESOURCE_TYPE_SPRITE = 0;
const RESOURCE_TYPE_SOUND = 1;
const RESOURCE_TYPE_BACKGROUND = 2;
const RESOURCE_TYPE_FONT = 3;
const RESOURCE_TYPE_PATH = 4;
const RESOURCE_TYPE_SCRIPT = 5;

// Resource manager structure
function ResourceManager() {
    var rm = {};
    rm.assets = ds_map_create();           // Complete asset storage
    rm.sprite_cache = ds_map_create();     // Sprite-specific cache
    rm.sound_cache = ds_map_create();      // Sound-specific cache
    rm.font_cache = ds_map_create();       // Font-specific cache
    rm.loading_queue = ds_list_create();   // Resources to load
    rm.loaded_count = 0;
    rm.total_count = 0;
    rm.loading_complete = false;
    
    // Animation time tracking (similar to Rust animation_time)
    rm.animation_time = 0;
    
    return rm;
}

// Global resource manager instance
if (!global_exists("g_resource_manager")) {
    global.g_resource_manager = ResourceManager();
}

/// Initialize the resource manager
function resource_manager_init() {
    if (!global_exists("g_resource_manager")) {
        global.g_resource_manager = ResourceManager();
    }
    return global.g_resource_manager;
}

/// Preload all essential resources
function resource_preload_all() {
    var rm = resource_manager_init();
    
    // Load all player sprites
    load_player_sprites();
    
    // Load NPC sprites
    load_npc_sprites();
    
    // Load other essential sprites
    load_item_sprite();
    load_enemy_sprite();
    
    // Preload other essential resources
    var essential_paths = [
        "assets/sprites/player_down.png", "assets/sprites/player_up.png", 
        "assets/sprites/player_left.png", "assets/sprites/player_right.png",
        "assets/sprites/npc_roan.png", "assets/sprites/npc_tellah.png", 
        "assets/sprites/npc_yore.png", "assets/sprites/item.png",
        "assets/sprites/enemy.png", "assets/sprites/lever.png",
        "assets/sprites/platform.png", "assets/sprites/clockwork_emblem.png",
        "assets/sprites/mirror_shard.png", "assets/sprites/crystal_cluster.png",
        "assets/sprites/core_spire.png"
    ];
    
    rm.total_count = array_length(essential_paths);
    rm.loaded_count = 0;
    
    for (var i = 0; i < array_length(essential_paths); i++) {
        resource_load_sprite(essential_paths[i]);
        rm.loaded_count++;
    }
    
    rm.loading_complete = true;
    return rm.loaded_count;
}

/// Load a sprite resource
function resource_load_sprite(path) {
    var rm = resource_manager_init();
    
    // Check if already cached
    if (ds_map_exists(rm.sprite_cache, path)) {
        return ds_map_find_value(rm.sprite_cache, path);
    }
    
    // In practice, this would load the actual resource
    // For now, we'll simulate by creating a placeholder
    var sprite_id = sprite_add(path, 1);
    
    if (sprite_id != -1) {
        ds_map_set(rm.sprite_cache, path, sprite_id);
        ds_map_set(rm.assets, path, {
            type: RESOURCE_TYPE_SPRITE,
            id: sprite_id,
            path: path,
            loaded: true
        });
        return sprite_id;
    }
    
    return -1;
}

/// Load a sound resource
function resource_load_sound(path) {
    var rm = resource_manager_init();
    
    // Check if already cached
    if (ds_map_exists(rm.sound_cache, path)) {
        return ds_map_find_value(rm.sound_cache, path);
    }
    
    // In practice, this would load the actual sound resource
    // For now, we'll simulate by generating an ID
    var sound_id = audio_sound_create(path);
    
    if (sound_id != -1) {
        ds_map_set(rm.sound_cache, path, sound_id);
        ds_map_set(rm.assets, path, {
            type: RESOURCE_TYPE_SOUND,
            id: sound_id,
            path: path,
            loaded: true
        });
        return sound_id;
    }
    
    return -1;
}

/// Get cached resource by path
function resource_get(path) {
    var rm = resource_manager_init();
    
    // Check sprite cache
    if (ds_map_exists(rm.sprite_cache, path)) {
        return ds_map_find_value(rm.sprite_cache, path);
    }
    
    // Check sound cache
    if (ds_map_exists(rm.sound_cache, path)) {
        return ds_map_find_value(rm.sound_cache, path);
    }
    
    // Check general asset cache
    if (ds_map_exists(rm.assets, path)) {
        var asset = ds_map_find_value(rm.assets, path);
        return asset.id;
    }
    
    return -1;
}

/// Check if resource is loaded
function resource_is_loaded(path) {
    var rm = resource_manager_init();
    return ds_map_exists(rm.assets, path);
}

/// Update animation time (should be called in Step event)
function resource_update_animation_time() {
    var rm = resource_manager_init();
    rm.animation_time += delta_time;  // Using delta_time for smooth animation
    return rm.animation_time;
}

/// Get current animation time
function resource_get_animation_time() {
    var rm = resource_manager_init();
    return rm.animation_time;
}

/// Get pulse value for animations (similar to Rust's pulsing effects)
function resource_get_pulse(speed, amplitude) {
    var time = resource_get_animation_time();
    return (sin(time * speed) * amplitude) + 1.0;
}

/// Get oscillating value for animations
function resource_get_oscillation(speed, amplitude, offset) {
    var time = resource_get_animation_time();
    return sin(time * speed + offset) * amplitude;
}

/// Clean up all resources
function resource_cleanup() {
    var rm = resource_manager_init();
    
    // Clear sprite cache
    var sprite_keys = ds_map_keys(rm.sprite_cache);
    for (var i = 0; i < ds_list_size(sprite_keys); i++) {
        var path = ds_list_find_value(sprite_keys, i);
        var sprite_id = ds_map_find_value(rm.sprite_cache, path);
        if (sprite_id != -1 && sprite_exists(sprite_id)) {
            sprite_delete(sprite_id);
        }
    }
    ds_map_clear(rm.sprite_cache);
    ds_list_destroy(sprite_keys);
    
    // Clear sound cache
    var sound_keys = ds_map_keys(rm.sound_cache);
    for (var i = 0; i < ds_list_size(sound_keys); i++) {
        var path = ds_list_find_value(sound_keys, i);
        var sound_id = ds_map_find_value(rm.sound_cache, path);
        if (sound_id != -1) {
            audio_delete_sound(sound_id);
        }
    }
    ds_map_clear(rm.sound_cache);
    ds_list_destroy(sound_keys);
    
    // Clear assets map
    ds_map_clear(rm.assets);
    
    // Reset counters
    rm.loaded_count = 0;
    rm.total_count = 0;
    rm.loading_complete = false;
    rm.animation_time = 0;
}

/// Get loading progress percentage
function resource_get_loading_progress() {
    var rm = resource_manager_init();
    if (rm.total_count <= 0) return 100;
    return (rm.loaded_count / rm.total_count) * 100;
}

/// Check if loading is complete
function resource_is_loading_complete() {
    var rm = resource_manager_init();
    return rm.loading_complete;
}

/// Add resource to loading queue
function resource_queue_add(path, type) {
    var rm = resource_manager_init();
    ds_list_add(rm.loading_queue, {
        path: path,
        type: type,
        priority: 0,
        status: "pending"
    });
}

/// Process loading queue
function resource_queue_process() {
    var rm = resource_manager_init();
    var queue_size = ds_list_size(rm.loading_queue);
    
    for (var i = 0; i < queue_size; i++) {
        var item = ds_list_find_value(rm.loading_queue, i);
        if (item.status == "pending") {
            switch (item.type) {
                case RESOURCE_TYPE_SPRITE:
                    resource_load_sprite(item.path);
                    break;
                case RESOURCE_TYPE_SOUND:
                    resource_load_sound(item.path);
                    break;
            }
            item.status = "loaded";
            rm.loaded_count++;
        }
    }
    
    return rm.loaded_count;
}