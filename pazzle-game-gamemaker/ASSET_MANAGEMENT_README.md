# Asset Management System for GM Studio 2

This asset management system replicates the functionality of the Rust version with sprite loading, animation handling, and resource management capabilities tailored for GameMaker Studio 2.

## Scripts Overview

### 1. `scr_sprite_loader.gml`
Handles loading and caching of sprites. Includes:
- Functions for loading player, NPC, item, and environment sprites
- Directional sprite support (up, down, left, right)
- Sprite caching and cleanup

### 2. `scr_animation_system.gml`
Provides animation functionality including:
- Animation controller for managing multiple animations per object
- Frame-based animation updates
- Specialized animation functions (pulse, bobbing, step animations)
- Loop and playback controls

### 3. `scr_resource_manager.gml`
Complete resource lifecycle management:
- Loading queue system
- Asset caching by type
- Animation time tracking
- Loading progress monitoring

### 4. `scr_draw_utils.gml`
Drawing utilities with special effects:
- Direct sprite drawing functions
- Animation-enhanced drawing (pulsing, bobbing, etc.)
- Color modulation and state-based rendering

### 5. `scr_asset_demo.gml`
Example implementations showing how to use the system
- Usage patterns for common scenarios
- Animated entity examples

### 6. `scr_asset_manager_master.gml`
Master integration script that ties all systems together
- Single initialization function
- Unified update and cleanup methods

## Usage

### Initialization
```gml
// In your game's initialization code
asset_manager_initialize();
```

### Per-Frame Updates
```gml
// In your main game object's Step event
asset_manager_update();
```

### Drawing Assets
```gml
// Draw player with step animation
demo_draw_player(player_x, player_y, "down");

// Draw NPC with bobbing animation
demo_draw_npc(npc_x, npc_y, 0);

// Draw item with pulse effect
demo_draw_item_with_pulse(item_x, item_y);
```

### Creation/Destroy Events
```gml
// In Create event
var obj = asset_manager_example_usage_CreateObject();

// In Destroy event
asset_manager_cleanup();
```

## Key Features

1. **Sprite Loading**: Automatic caching and retrieval of sprites
2. **Animation Support**: Frame-based and time-based animations
3. **Memory Management**: Proper cleanup of loaded assets
4. **Performance Optimized**: Cached resource retrieval
5. **Rust-like Animations**: Replicates the pulsing, bobbing, and other animation effects from the Rust version
6. **Directional Sprites**: Support for different sprites based on facing direction

## Animation Effects Available

- Pulse animations (like items floating in the Rust game)
- Bobbing animations (like NPCs in the town scene)
- Step animations (like character movement)
- Custom animation parameters for fine-tuning