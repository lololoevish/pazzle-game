/// @description Drawing utilities for sprites and animated elements
/// @function draw_sprite_at(x, y, sprite_id, frame, width, height, color, alpha)
/// @param x X position to draw
/// @param y Y position to draw
/// @param sprite_id Sprite to draw
/// @param frame Frame of the sprite to draw
/// @param width Width to scale to
/// @param height Height to scale to
/// @param color Color to tint
/// @param alpha Alpha transparency

/// Draw a sprite at a specific position with scaling
function draw_sprite_at(x, y, sprite_id, frame, width, height, color, alpha) {
    if (sprite_exists(sprite_id)) {
        var sprite_w = sprite_get_width(sprite_id);
        var sprite_h = sprite_get_height(sprite_id);
        
        var scaleX = (width / sprite_w);
        var scaleY = (height / sprite_h);
        
        draw_sprite_stretched_ext(sprite_id, frame, x, y, width, height, color, alpha);
    }
}

/// Draw a player sprite (similar to Rust version)
function draw_player_sprite_at(x, y, direction, width, height, color, alpha) {
    var sprite_id = get_player_sprite_by_direction(direction);
    var frame = 0; // For simple directional sprites, use frame 0
    
    if (sprite_id != -1) {
        draw_sprite_stretched_ext(sprite_id, frame, x, y, width, height, color, alpha);
    }
}

/// Draw an item sprite
function draw_item_sprite_at(x, y, size, color, alpha) {
    var sprite_id = get_item_sprite();
    var frame = 0;
    
    if (sprite_id != -1) {
        draw_sprite_stretched_ext(sprite_id, frame, x, y, size, size, color, alpha);
    }
}

/// Draw an NPC sprite by index
function draw_npc_sprite_at(x, y, index, width, height, color, alpha) {
    var sprite_id = get_npc_sprite_by_index(index);
    var frame = 0;
    
    if (sprite_id != -1) {
        draw_sprite_stretched_ext(sprite_id, frame, x, y, width, height, color, alpha);
    }
}

/// Draw a lever sprite
function draw_lever_sprite_at(x, y, width, height, color, alpha) {
    var sprite_id = get_lever_sprite();
    var frame = 0;
    
    if (sprite_id != -1) {
        draw_sprite_stretched_ext(sprite_id, frame, x, y, width, height, color, alpha);
    }
}

/// Draw a platform sprite
function draw_platform_sprite_at(x, y, width, height, color, alpha) {
    var sprite_id = get_platform_sprite();
    var frame = 0;
    
    if (sprite_id != -1) {
        draw_sprite_stretched_ext(sprite_id, frame, x, y, width, height, color, alpha);
    }
}

/// Draw an enemy sprite
function draw_enemy_sprite_at(x, y, width, height, color, alpha) {
    var sprite_id = get_enemy_sprite();
    var frame = 0;
    
    if (sprite_id != -1) {
        draw_sprite_stretched_ext(sprite_id, frame, x, y, width, height, color, alpha);
    }
}

/// Draw a sprite with pulsing effect (like in Rust animations)
function draw_sprite_with_pulse(x, y, sprite_id, frame, base_width, base_height, speed, amplitude, color, alpha) {
    var pulse_factor = resource_get_pulse(speed, amplitude);
    var width = base_width * pulse_factor;
    var height = base_height * pulse_factor;
    
    if (sprite_exists(sprite_id)) {
        draw_sprite_stretched_ext(sprite_id, frame, x, y, width, height, color, alpha);
    }
}

/// Draw a sprite with vertical bobbing motion
function draw_sprite_with_bobbing(x, y, sprite_id, frame, width, height, speed, amplitude, phase_offset, color, alpha) {
    var bob_amount = calculate_bobbing_animation(resource_get_animation_time(), speed, amplitude, phase_offset);
    var final_y = y + bob_amount;
    
    if (sprite_exists(sprite_id)) {
        draw_sprite_stretched_ext(sprite_id, frame, x, final_y, width, height, color, alpha);
    }
}

/// Draw a sprite with step-based animation (like player stepping in Rust)
function draw_sprite_with_step(x, y, sprite_id, frame, width, height, speed, color, alpha) {
    var step_amount = calculate_step_animation(resource_get_animation_time(), speed);
    var final_y = y + step_amount;
    
    if (sprite_exists(sprite_id)) {
        draw_sprite_stretched_ext(sprite_id, frame, x, final_y, width, height, color, alpha);
    }
}

/// Draw with custom animation parameters
function draw_animated_sprite_at(x, y, sprite_id, frame, width, height, color, alpha, animation_type, params) {
    var final_x = x;
    var final_y = y;
    var final_width = width;
    var final_height = height;
    
    switch (animation_type) {
        case "pulse":
            var pulse_factor = resource_get_pulse(params.speed, params.amplitude);
            final_width = width * pulse_factor;
            final_height = height * pulse_factor;
            break;
            
        case "bobbing":
            var bob_amount = calculate_bobbing_animation(
                resource_get_animation_time(), 
                params.speed, 
                params.amplitude, 
                params.phase_offset
            );
            final_y = y + bob_amount;
            break;
            
        case "step":
            var step_amount = calculate_step_animation(resource_get_animation_time(), params.speed);
            final_y = y + step_amount;
            break;
            
        case "glow":
            // Use pulse for glow effect
            var pulse_factor = resource_get_pulse(params.speed, params.amplitude);
            alpha *= pulse_factor;
            break;
    }
    
    if (sprite_exists(sprite_id)) {
        draw_sprite_stretched_ext(sprite_id, frame, final_x, final_y, final_width, final_height, color, alpha);
    }
}

/// Convert hex color to GameMaker color
function hex_to_gml_color(hex_string) {
    // Remove # if present
    if (string_char_at(hex_string, 1) == "#") {
        hex_string = string_copy(hex_string, 2, string_length(hex_string) - 1);
    }
    
    // Convert hex to decimal
    return $hex + string_upper(hex_string);
}

/// Draw with calculated color modulation
function draw_sprite_with_modulated_color(x, y, sprite_id, frame, width, height, base_color, modulation_factor) {
    var modulated_alpha = (color_get_blue(base_color) / 255.0) * modulation_factor;
    var final_color = base_color;
    var final_alpha = min(max(modulated_alpha, 0), 1);
    
    draw_sprite_at(x, y, sprite_id, frame, width, height, final_color, final_alpha);
}

/// Draw a sprite with tint based on state
function draw_state_tinted_sprite(x, y, sprite_id, frame, width, height, state) {
    var color = c_white;
    var alpha = 1.0;
    
    switch (state) {
        case "normal":
            color = c_white;
            alpha = 1.0;
            break;
        case "highlighted":
            color = c_yellow;
            alpha = 1.0;
            break;
        case "selected":
            color = c_green;
            alpha = 1.0;
            break;
        case "disabled":
            color = c_gray;
            alpha = 0.5;
            break;
        case "pulse":
            alpha = resource_get_pulse(4.0, 0.5) * 0.5 + 0.5; // Range 0.5-1.0
            break;
    }
    
    draw_sprite_at(x, y, sprite_id, frame, width, height, color, alpha);
}