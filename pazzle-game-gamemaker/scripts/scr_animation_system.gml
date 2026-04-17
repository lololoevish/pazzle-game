/// @description Animation system for managing animated sprites
/// @function anim_create(sprite_id, frames, speed)
/// @param sprite_id The sprite to animate
/// @param frames Number of frames in the animation
/// @param speed Animation speed

// Animation structure
function Animation() {
    var anim = {};
    anim.sprite_id = -1;
    anim.frame_count = 1;
    anim.speed = 1.0;
    anim.current_frame = 0;
    anim.timer = 0;
    anim.completed = false;
    anim.loop = true;
    anim.playing = true;
    return anim;
}

/// Create a new animation
function anim_create(sprite_id, frames, speed) {
    var anim = Animation();
    anim.sprite_id = sprite_id;
    anim.frame_count = frames > 0 ? frames : sprite_get_number(sprite_id);
    anim.speed = speed;
    anim.current_frame = 0;
    anim.timer = 0;
    anim.completed = false;
    return anim;
}

/// Update animation
function anim_update(anim) {
    if (!anim.playing) {
        return anim;
    }
    
    anim.timer += anim.speed;
    
    if (anim.timer >= 1) {
        var frame_increment = floor(anim.timer);
        anim.current_frame += frame_increment;
        anim.timer -= frame_increment;
        
        // Check if animation is completed
        if (anim.current_frame >= anim.frame_count) {
            if (anim.loop) {
                anim.current_frame = anim.current_frame mod anim.frame_count;
            } else {
                anim.current_frame = anim.frame_count - 1;
                anim.completed = true;
                anim.playing = false;
            }
        }
    }
    
    return anim;
}

/// Get current frame for animation
function anim_get_frame(anim) {
    return anim.current_frame;
}

/// Reset animation
function anim_reset(anim) {
    anim.current_frame = 0;
    anim.timer = 0;
    anim.completed = false;
    anim.playing = true;
    return anim;
}

/// Set animation loop
function anim_set_loop(anim, loop) {
    anim.loop = loop;
    return anim;
}

/// Animation controller for objects
function AnimationController() {
    var controller = {};
    controller.animations = ds_map_create();  // Map of animation names to animation objects
    controller.current_animation = "";
    controller.animation_speed = 1.0;
    return controller;
}

/// Create an animation controller
function anim_controller_create() {
    return AnimationController();
}

/// Add animation to controller
function anim_controller_add(controller, name, sprite_id, frames, speed) {
    var anim = anim_create(sprite_id, frames, speed * controller.animation_speed);
    ds_map_set(controller.animations, name, anim);
    
    if (controller.current_animation == "") {
        controller.current_animation = name;
    }
    
    return controller;
}

/// Switch to different animation
function anim_controller_switch(controller, name) {
    if (ds_map_exists(controller.animations, name)) {
        controller.current_animation = name;
        
        // Reset the new animation
        var anim = ds_map_find_value(controller.animations, name);
        anim = anim_reset(anim);
        ds_map_replace(controller.animations, name, anim);
    }
    
    return controller;
}

/// Update animation controller
function anim_controller_update(controller) {
    if (controller.current_animation != "" && 
        ds_map_exists(controller.animations, controller.current_animation)) {
        
        var anim = ds_map_find_value(controller.animations, controller.current_animation);
        anim = anim_update(anim);
        ds_map_replace(controller.animations, controller.current_animation, anim);
    }
    
    return controller;
}

/// Get current animation frame
function anim_controller_get_frame(controller) {
    if (controller.current_animation != "" && 
        ds_map_exists(controller.animations, controller.current_animation)) {
        
        var anim = ds_map_find_value(controller.animations, controller.current_animation);
        return anim_get_frame(anim);
    }
    
    return 0;
}

/// Get current animation sprite
function anim_controller_get_sprite(controller) {
    if (controller.current_animation != "" && 
        ds_map_exists(controller.animations, controller.current_animation)) {
        
        var anim = ds_map_find_value(controller.animations, controller.current_animation);
        return anim.sprite_id;
    }
    
    return -1;
}

/// Destroy animation controller
function anim_controller_destroy(controller) {
    var keys = ds_map_keys(controller.animations);
    for (var i = 0; i < ds_list_size(keys); i++) {
        var key = ds_list_find_value(keys, i);
        ds_map_delete(controller.animations, key);
    }
    ds_map_destroy(controller.animations);
    ds_list_destroy(keys);
}

/// Simple animation utility for pulsing effects (like in Rust code)
function calculate_pulse_animation(time, speed, amplitude, offset) {
    return sin(time * speed + offset) * amplitude + 1.0;
}

/// Calculate bobbing animation (like NPC bobbing in Rust code)
function calculate_bobbing_animation(time, speed, amplitude, phase_offset) {
    return sin(time * speed + phase_offset) * amplitude;
}

/// Calculate step animation (like player step in Rust code)
function calculate_step_animation(time, speed) {
    return abs(sin(time * speed)) * 2.2;
}