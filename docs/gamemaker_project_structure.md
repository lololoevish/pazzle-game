# GameMaker Studio 2 Project Structure Best Practices

## Recommended Folder Structure

### Overview
This document outlines the ideal project structure for GameMaker Studio 2 projects following industry best practices and ensuring efficient asset management.

### Detailed Structure

```
project-name/
├── datafiles/                    # External data files
│   ├── configs/                  # Configuration files
│   └── saves/                    # Save game templates
├── fonts/                        # Font resources
│   ├── ui/                       # UI fonts
│   └── game/                     # In-game fonts
├── objects/                      # Game objects
│   ├── core/                     # Core game objects
│   ├── player/                   # Player-related objects
│   ├── npcs/                     # NPC objects
│   ├── puzzles/                  # Puzzle-specific objects
│   ├── ui/                       # UI objects
│   └── utilities/                # Utility objects
├── options/                      # Platform options
│   ├── extensions/               # Extension configurations
│   └── main/                     # Main settings
├── rooms/                        # Game rooms
│   ├── menus/                    # Menu screens
│   ├── hubs/                     # Hub areas (town)
│   ├── levels/                   # Puzzle levels
│   │   ├── maze/                 # Maze level related
│   │   ├── wordsearch/           # Word search level
│   │   ├── rhythm/               # Rhythm level
│   │   ├── pairs/                # Pairs level
│   │   ├── platformer/           # Platformer level
│   │   └── final/                # Final challenge level
│   └── special/                  # Victory screen, etc.
├── scripts/                      # Script files
│   ├── core/                     # Core system scripts
│   ├── managers/                 # Manager scripts
│   ├── puzzle_systems/           # Puzzle system logic
│   ├── utils/                    # Utility scripts
│   └── puzzle_scripts/           # Individual puzzle scripts
├── shaders/                      # Shader programs
├── sounds/                       # Audio files
│   ├── sfx/                      # Sound effects
│   │   ├── ui/                   # UI sounds
│   │   ├── puzzles/              # Puzzle sounds
│   │   ├── interactions/         # Interaction sounds
│   │   └── ambience/             # Ambient sounds
│   └── music/                    # Background music
│       ├── menus/                # Menu music
│       ├── hubs/                 # Town/hub music
│       └── levels/               # Level-specific music
├── sprites/                      # Sprite resources
│   ├── characters/               # Character sprites
│   │   ├── player/               # Player sprites
│   │   │   ├── down/             # Down-facing animations
│   │   │   ├── up/               # Up-facing animations
│   │   │   ├── left/             # Left-facing animations
│   │   │   └── right/            # Right-facing animations
│   │   └── npcs/                 # NPC sprites
│   ├── items/                    # Collectible items
│   ├── ui/                       # UI elements
│   │   ├── buttons/              # Button sprites
│   │   ├── icons/                # Icon sprites
│   │   └── backgrounds/          # Background UI
│   ├── environment/              # Environmental objects
│   │   ├── decorations/          # Decorative elements
│   │   ├── platforms/            # Platform elements
│   │   └── interactables/        # Interactive objects
│   ├── effects/                  # Visual effect sprites
│   └── puzzles/                  # Puzzle-specific graphics
│       ├── maze/                 # Maze puzzle graphics
│       ├── wordsearch/           # Word search graphics
│       ├── rhythm/               # Rhythm puzzle graphics
│       ├── pairs/                # Pairs puzzle graphics
│       ├── platformer/           # Platformer graphics
│       └── final/                # Final challenge graphics
├── timelines/                    # Timeline resources
├── triggers/                     # Trigger scripts
└── project.gmx                   # Project definition file
```

## Benefits of This Structure

### 1. Enhanced Asset Organization
- Better categorization of assets by function and type
- Subdivision of sprites by character, environment, UI, and puzzles
- Clear separation of audio into SFX and music with functional categories

### 2. Logical Grouping
- Objects organized by role and functionality
- Scripts organized by purpose and system
- Rooms organized by game flow and type

### 3. Scalability Considerations
- Easy to add new puzzle types with dedicated folders
- Room organization supports expansion of level count
- Modular script organization allows for easy extensions

### 4. Best Practice Compliance
- Follows GameMaker Studio 2 project organization standards
- Maintains clear separation of concerns
- Facilitates team collaboration through clear project structure

### 5. Asset Management Benefits
- Faster asset lookup through logical categorization
- Reduced naming conflicts with structured hierarchy
- Improved maintainability and debugging

## Implementation Guidelines

### Migration Strategy
1. Create new folder structure alongside existing assets
2. Gradually migrate assets to appropriate folders
3. Update references in code to reflect new paths
4. Test functionality after each migration step
5. Remove old structure once migration is complete

### Naming Conventions
- Use descriptive names that clearly indicate asset purpose
- Follow consistent prefixing: `obj_`, `spr_`, `snd_`, `mus_`, `rm_`, `scr_`
- Use underscores to separate words in names
- Avoid special characters in filenames

### Team Collaboration
- Establish clear ownership of different asset categories
- Maintain a shared documentation of the asset structure
- Regular reviews to ensure structure remains consistent
- Version control practices for managing asset changes

## Specific Recommendations for Puzzle Game

### Object Organization
- `objects/core/`: `obj_game_manager`, `obj_player`, `obj_input_handler`
- `objects/player/`: `obj_player_movement`, `obj_player_controller`
- `objects/npcs/`: Separate objects for each NPC type
- `objects/puzzles/`: Puzzle-specific object variants
- `objects/ui/`: `obj_ui_manager`, `obj_button`, `obj_hud`

### Script Organization
- `scripts/core/`: `scr_game_state`, `scr_save_system`
- `scripts/managers/`: `scr_audio_manager`, `scr_ui_manager`
- `scripts/puzzle_systems/`: Base puzzle logic
- `scripts/puzzle_scripts/`: Individual puzzle implementations
- `scripts/utils/`: Helper functions and constants

### Room Organization
- `rooms/menus/`: `rm_main_menu`, `rm_pause_menu`, `rm_settings`
- `rooms/hubs/`: `rm_town`
- `rooms/levels/`: Organized by puzzle type as shown above
- `rooms/special/`: `rm_victory`, `rm_credits`

## Conclusion

Adopting this structured approach will significantly improve the maintainability and scalability of the GameMaker project. The logical categorization ensures that team members can quickly locate and modify assets, while the scalable design accommodates future growth without requiring restructuring.