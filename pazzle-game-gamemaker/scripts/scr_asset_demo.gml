/// @description Demo script showing how to use the asset management system
/// @function asset_demo_example()

/// Example function showing how to set up and use the asset management system
function asset_demo_setup() {
    // Initialize the resource manager
    resource_manager_init();
    
    // Preload all assets
    resource_preload_all();
    
    // Or load individual assets as needed
    load_player_sprites();
    load_npc_sprites();
    
    show_debug_message("Asset management system initialized and assets loaded.");
}

/// Example of how to draw player with animations
function demo_draw_player(x, y, direction) {
    var animation_time = resource_get_animation_time();
    
    // Draw player with step animation (like in Rust town scene)
    var step_bob = calculate_step_animation(animation_time, 8.0);
    draw_player_sprite_at(x, y + step_bob, direction, 48, 48, c_white, 1.0);
}

/// Example of how to draw NPCs with bobbing animation
function demo_draw_npc(x, y, index) {
    var animation_time = resource_get_animation_time();
    
    // Draw NPC with bobbing animation (like in Rust town scene)
    var bob = calculate_bobbing_animation(animation_time, 2.3, 3.0, x * 0.018);
    var npc_sprite = get_npc_sprite_by_index(index);
    
    if (npc_sprite != -1) {
        // Determine color based on NPC index
        var npc_colors = [ 
            $E2BC7E,  // NPC_YORE color (226, 188, 126)
            $92D0FF,  // NPC_ROAN color (146, 208, 255) 
            $C6A8E8   // NPC_TELLAH color (198, 168, 232)
        ];
        
        var color = c_white;
        if (index < array_length(npc_colors)) {
            color = npc_colors[index];
        }
        
        draw_sprite_stretched_ext(npc_sprite, 0, x, y + bob, 48, 48, color, 1.0);
    }
}

/// Example of how to draw items with pulse animation
function demo_draw_item_with_pulse(x, y) {
    var animation_time = resource_get_animation_time();
    
    // Draw item with pulse animation (like in Rust scenes)
    var pulse = (animation_time * 2.4).sin() * 0.5 + 0.5;
    
    draw_item_sprite_at(x, y, 44, c_white, pulse);
}

/// Example of how to use animated entities
function demo_entity_system() {
    // Create an animation controller for an entity
    var controller = anim_controller_create();
    
    // Add animations to the controller
    var idle_sprite = get_player_sprite_by_direction("down");
    var walk_down_sprite = get_player_sprite_by_direction("down"); // Same for demo
    
    anim_controller_add(controller, "idle", idle_sprite, 1, 0.5);
    anim_controller_add(controller, "walk", walk_down_sprite, sprite_get_number(walk_down_sprite), 1.0);
    
    // Update the controller
    anim_controller_update(controller);
    
    // Get current animation info
    var current_sprite = anim_controller_get_sprite(controller);
    var current_frame = anim_controller_get_frame(controller);
    
    // Use for drawing...
    if (current_sprite != -1) {
        draw_sprite(current_sprite, current_frame, 100, 100);
    }
    
    // Don't forget to destroy when done
    // anim_controller_destroy(controller);
}

/// Example of resource loading progress
function demo_show_loading_progress() {
    var progress = resource_get_loading_progress();
    var complete = resource_is_loading_complete();
    
    draw_text(10, 10, "Loading: " + string(progress) + "%");
    
    if (complete) {
        draw_text(10, 30, "Loading Complete!");
    }
}

/// Cleanup function to free resources
function asset_demo_cleanup() {
    // Clean up the resource manager
    resource_cleanup();
    
    // Clean up asset sprites
    asset_cleanup();
    
    show_debug_message("Asset management system cleaned up.");
}

/// Main demo function
function asset_demo_example() {
    // Initialize system
    if (!global.asset_system_initialized) {
        asset_demo_setup();
        global.asset_system_initialized = true;
    }
    
    // Update animation time (call this in Step event)
    resource_update_animation_time();
    
    // Example drawing calls
    demo_draw_player(100, 100, "down");
    demo_draw_npc(200, 150, 0);
    demo_draw_item_with_pulse(300, 200);
    demo_entity_system();
    
    // Show loading progress
    demo_show_loading_progress();
}