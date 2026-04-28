/// @description Master asset management system combining all components
/// @function asset_manager_initialize()
/// @function asset_manager_update()
/// @function asset_manager_cleanup()

// Initialize the complete asset management system
function asset_manager_initialize() {
    // Initialize the resource manager
    resource_manager_init();
    
    // Initialize global variables for sprites if they don't exist yet
    if (!variable_global_exists("g_asset_sprites")) {
        global.g_asset_sprites = ds_map_create();
    }
    
    // Preload essential assets
    resource_preload_all();
    
    show_debug_message("Asset Management System initialized successfully.");
    return true;
}

// Update the asset management system (call in Step event)
function asset_manager_update() {
    // Update animation timing
    resource_update_animation_time();
    
    // Process any queued resource loads
    resource_queue_process();
    
    // Return loading completion status
    return resource_is_loading_complete();
}

// Clean up the asset management system
function asset_manager_cleanup() {
    // Clean up all resources
    resource_cleanup();
    
    // Clean up sprite cache
    if (variable_global_exists("g_asset_sprites")) {
        var keys = ds_map_keys(global.g_asset_sprites);
        for (var i = 0; i < ds_list_size(keys); i++) {
            var key = ds_list_find_value(keys, i);
            var sprite_id = ds_map_find_value(global.g_asset_sprites, key);
            if (sprite_id != -1 && sprite_exists(sprite_id)) {
                sprite_delete(sprite_id);
            }
        }
        ds_map_destroy(global.g_asset_sprites);
    }
    
    show_debug_message("Asset Management System cleaned up successfully.");
    return true;
}

// Get loading progress percentage
function asset_manager_get_progress() {
    return resource_get_loading_progress();
}

// Check if initialization is complete
function asset_manager_is_ready() {
    return resource_is_loading_complete();
}

// Preload specific category of assets
function asset_manager_preload_category(category) {
    switch (category) {
        case "player":
            return load_player_sprites();
        case "npc":
            return load_npc_sprites();
        case "items":
            return load_item_sprite();
        case "enemies":
            return load_enemy_sprite();
        default:
            return resource_preload_all();
    }
}

// Helper function to create an animated object
function asset_manager_create_animated_object(sprite_id, animation_speed, loop) {
    var controller = anim_controller_create();
    var frame_count = sprite_get_number(sprite_id);
    
    // Add a default animation
    anim_controller_add(controller, "default", sprite_id, frame_count, animation_speed);
    anim_controller_switch(controller, "default");
    anim_controller_set_loop(ds_map_find_value(controller.animations, "default"), loop);
    
    return controller;
}

// Draw an animated object
function asset_manager_draw_animated_object(controller, x, y, width, height, color, alpha) {
    anim_controller_update(controller);
    
    var sprite_id = anim_controller_get_sprite(controller);
    var frame = anim_controller_get_frame(controller);
    
    if (sprite_id != -1) {
        draw_sprite_stretched_ext(sprite_id, frame, x, y, width, height, color, alpha);
    }
}

// Create a sprite with animation properties
function asset_manager_create_sprite_with_animations(sprite_root, directions) {
    var sprite_set = {};
    
    for (var dir_index = 0; dir_index < array_length(directions); dir_index++) {
        var direction = directions[dir_index];
        var sprite_id = get_player_sprite_by_direction(direction);
        sprite_set[direction] = sprite_id;
    }
    
    return sprite_set;
}

// Get sprite by direction from a sprite set
function asset_manager_get_directional_sprite(sprite_set, direction) {
    if (ds_map_exists(sprite_set, direction)) {
        return ds_map_find_value(sprite_set, direction);
    }
    
    // Default to 'down' if direction not found
    return ds_map_find_value(sprite_set, "down");
}

// Utility function for drawing sprites with Rust-style animations
function asset_manager_draw_rust_style_element(x, y, sprite_id, width, height, base_color, anim_type, anim_params) {
    draw_animated_sprite_at(x, y, sprite_id, 0, width, height, base_color, 1.0, anim_type, anim_params);
}

// Example usage functions
function asset_manager_example_usage_CreateObject() {
    // This would typically be called in the Create event of an object
    var obj = {};
    obj.animation_controller = asset_manager_create_animated_object(
        get_player_sprite_by_direction("down"), 
        0.5, 
        true
    );
    obj.x = 100;
    obj.y = 100;
    obj.width = 48;
    obj.height = 48;
    
    return obj;
}

function asset_manager_example_usage_Draw(obj) {
    // This would typically be called in the Draw event of an object
    asset_manager_draw_animated_object(
        obj.animation_controller, 
        obj.x, 
        obj.y, 
        obj.width, 
        obj.height, 
        c_white, 
        1.0
    );
}

function asset_manager_example_usage_Step(obj) {
    // This would typically be called in the Step event of an object
    anim_controller_update(obj.animation_controller);
}
