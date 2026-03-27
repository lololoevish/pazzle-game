# Migration Guide: Current Structure to Optimized Structure

## Overview
This document provides a step-by-step guide to migrate the current GameMaker project structure to the optimized folder structure outlined in the best practices document.

## Current vs. Target Structure

### Current Structure
```
pazzle-game-gamemaker/
├── assets/
│   ├── effects/
│   ├── fonts/
│   ├── music/
│   ├── sounds/
│   └── sprites/
├── objects/
├── rooms/
│   └── rm_caves/
├── scripts/
│   └── puzzle_scripts/
├── test_scenarios/
├── project_config.txt
├── README.md
├── TESTING.md
└── UNIT_TESTS.md
```

### Target Structure
```
pazzle-game-gamemaker/
├── datafiles/
├── fonts/
│   ├── ui/
│   └── game/
├── objects/
│   ├── core/
│   ├── player/
│   ├── npcs/
│   ├── puzzles/
│   ├── ui/
│   └── utilities/
├── options/
├── rooms/
│   ├── menus/
│   ├── hubs/
│   ├── levels/
│   │   ├── maze/
│   │   ├── wordsearch/
│   │   ├── rhythm/
│   │   ├── pairs/
│   │   ├── platformer/
│   │   └── final/
│   └── special/
├── scripts/
│   ├── core/
│   ├── managers/
│   ├── puzzle_systems/
│   ├── utils/
│   └── puzzle_scripts/
├── shaders/
├── sounds/
│   ├── sfx/
│   │   ├── ui/
│   │   ├── puzzles/
│   │   ├── interactions/
│   │   └── ambience/
│   └── music/
│       ├── menus/
│       ├── hubs/
│       └── levels/
├── sprites/
│   ├── characters/
│   │   ├── player/
│   │   └── npcs/
│   ├── items/
│   ├── ui/
│   │   ├── buttons/
│   │   ├── icons/
│   │   └── backgrounds/
│   ├── environment/
│   │   ├── decorations/
│   │   ├── platforms/
│   │   └── interactables/
│   ├── effects/
│   └── puzzles/
│       ├── maze/
│       ├── wordsearch/
│       ├── rhythm/
│       ├── pairs/
│       ├── platformer/
│       └── final/
├── timelines/
├── triggers/
└── project.gmx
```

## Migration Steps

### Phase 1: Setup New Structure
1. Create all the new directories in the target structure
2. Preserve the original directories temporarily during transition

```bash
# Create the new directory structure
mkdir -p pazzle-game-gamemaker/{datafiles,fonts/{ui,game},objects/{core,player,npcs,puzzles,ui,utilities},options/{extensions,main},rooms/{menus,hubs,levels/{maze,wordsearch,rhythm,pairs,platformer,final},special},scripts/{core,managers,puzzle_systems,utils},shaders,sounds/{sfx/{ui,puzzles,interactions,ambience},music/{menus,hubs,levels}},sprites/{characters/{player/{down,up,left,right},npcs},items,ui/{buttons,icons,backgrounds},environment/{decorations,platforms,interactables},effects,puzzles/{maze,wordsearch,rhythm,pairs,platformer,final}},timelines,triggers}
```

### Phase 2: Migrate Assets by Type

#### Fonts Migration
- Move all font files from `assets/fonts/` to `fonts/game/`
- Create font subcategories if needed

#### Sounds Migration
- Move all music files from `assets/music/` to `sounds/music/levels/`
- Move all sound files from `assets/sounds/` to `sounds/sfx/interactions/`
- Categorize sounds appropriately (UI, puzzles, interactions, ambience)

#### Sprites Migration
- Move player-related sprites to `sprites/characters/player/`
- Move NPC sprites from `assets/sprites/` to `sprites/characters/npcs/`
- Move UI sprites to `sprites/ui/` and categorize further
- Move environmental sprites to `sprites/environment/`
- Move puzzle-specific sprites to `sprites/puzzles/{puzzle-type}/`
- Move effect sprites to `sprites/effects/`

#### Effects Migration
- Move files from `assets/effects/` to `sprites/effects/`

### Phase 3: Migrate Logic Components

#### Objects Migration
- Move `obj_game_manager` to `objects/core/`
- Move `obj_player` to `objects/player/`
- Move `obj_npc` to `objects/npcs/`
- Move `obj_puzzle` and puzzle-specific objects to `objects/puzzles/`
- Move `obj_interactable` and `obj_lever` to `objects/interactables/`
- Update all object file paths in the project

#### Scripts Migration
- Move manager scripts (audio, UI, save system) to `scripts/managers/`
- Move core logic scripts to `scripts/core/`
- Move utility scripts to `scripts/utils/`
- Keep puzzle scripts in `scripts/puzzle_scripts/`
- Create `scripts/puzzle_systems/` for shared puzzle logic

#### Rooms Migration
- Move `rm_menu` to `rooms/menus/`
- Move `rm_town` to `rooms/hubs/`
- Move `rm_victory` to `rooms/special/`
- Move cave rooms to appropriate category folders under `rooms/levels/`
- Use the following mapping:
  - `rm_cave_maze` → `rooms/levels/maze/`
  - `rm_cave_archive` (word search) → `rooms/levels/wordsearch/`
  - `rm_cave_rhythm` → `rooms/levels/rhythm/`
  - `rm_cave_pairs` → `rooms/levels/pairs/`
  - `rm_cave_platformer` → `rooms/levels/platformer/`
  - `rm_cave_final` → `rooms/levels/final/`

### Phase 4: Update Internal References

1. **Update file paths in scripts**: Search for hardcoded asset paths and update them to reflect the new structure
2. **Update resource names**: Ensure that resource names match the new organization
3. **Verify object inheritance**: Confirm that extended objects can still find their parents
4. **Test all functionality**: Ensure nothing is broken by the migration

### Phase 5: Clean Up

1. After verifying all functionality works correctly:
   - Remove the old `assets/` directory structure
   - Update documentation to reflect new structure
   - Update any build scripts that reference old paths

## Pre-Migration Checklist

- [ ] Backup the entire project
- [ ] Commit all changes to version control
- [ ] Document current working state
- [ ] Verify all game functionality works before starting
- [ ] Create a test build to ensure everything runs

## Post-Migration Checklist

- [ ] All rooms load without errors
- [ ] All sprites display correctly
- [ ] All sounds play correctly
- [ ] All puzzles function as expected
- [ ] Save/load works
- [ ] All UI elements appear correctly
- [ ] Players can navigate between all areas
- [ ] NPCs interact properly
- [ ] Build process still works
- [ ] Update version control with new structure

## Potential Issues to Watch For

1. **Hardcoded paths**: Look for scripts that reference specific file paths and update them
2. **Resource loading**: Ensure that GameMaker can still locate all resources after moving them
3. **Animation sequences**: Verify that multi-frame animations and state transitions work properly
4. **Inheritance chains**: Confirm that object inheritance relationships are maintained
5. **Collision masks**: Ensure collision properties are preserved after sprite movement

## Reversibility

If issues arise during migration:
1. The original directory structure can serve as a backup until all references are updated
2. Use version control to roll back changes if needed
3. Migrate incrementally and test frequently to isolate issues