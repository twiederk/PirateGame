# Feature: Save and Load Game

## Overview

Implement a complete save/load system for the Pirate Game that allows players to:
- Start a new game from a start menu
- Save their game progress at any time
- Load previously saved games
- Manage multiple save slots (3 slots)
- Gracefully transition between menus and gameplay

This feature introduces the **Start GUI** as the main entry point to the game, similar to the MathDungeon architecture.

---

## Data Model

### Save File Structure (JSON Format)

Each save file will contain:
```json
{
  "version": "1.0",
  "timestamp": "ISO-8601 datetime",
  "player": {
    "position": {"x": 0, "y": 0},
    "inventory": {
      "gold": 100,
      "items": [...]
    },
    "statistics": {
      "trades_completed": 0,
      "total_distance_traveled": 0
    }
  },
  "world": {
    "map_state": {...},
    "game_time": 0
  },
  "towns": [
    {
      "town_id": "town_1",
      "visited": true,
      "resources": {...}
    }
  ]
}
```

### Save File Location
- **Directory**: `user://saves/`
- **File naming**: `save_slot_1.json`, `save_slot_2.json`, `save_slot_3.json`
- **Max slots**: 3

---

## Implementation Phases

### Phase 1: Start GUI Scene (UI Foundation)

**Objective**: Create the main menu interface and scene structure.

#### 1.1 Create Start GUI Scene
- **File**: `gui/start_gui.tscn`
- **Structure**:
  ```
  StartGUI (Control)
    ├── StartMenu (Control/Panel)
    │   ├── BackgroundImage (TextureRect)
    │   ├── TitleLabel (Label) - "Pirate Game"
    │   ├── MenuButtons (VBoxContainer)
    │   │   ├── NewGameButton
    │   │   ├── LoadGameButton
    │   │   └── QuitButton
    │   └── VersionWidget (imported from gui/version_widget.tscn)
  ```

#### 1.2 Scene Design Details
- **Background**: Use existing world.png or similar texture
- **Title**: Centered, prominent font
- **Buttons**: Vertical stack layout with consistent spacing
- **Version Widget**: Positioned in lower left corner
- **Version Widget Script**: `gui/version_widget.gd` (reusable component)

#### 1.3 Script: `gui/start_gui.gd`
- Handles button signals (New Game, Load Game, Quit)
- Manages scene transitions
- Initialize with default state (highlight "New Game" button)

#### 1.4 Refactoring
- **Remove** `version_widget` from `world/main.tscn`
- **Add** `version_widget` instance to `gui/debug_screen.tscn`
- Create `version_widget.tscn` as an instanced scene (currently only `.gd` file exists)

#### 1.5 Scene Transitions
- Implement `SceneManager` singleton or use Godot's built-in scene management
- Start GUI → Main Game: Load `world/main.tscn` when "New Game" selected
- Main Game → Start GUI: Return to start menu when quitting

---

### Phase 2: Save/Load System Implementation

**Objective**: Implement core save/load mechanics and data persistence.

#### 2.1 Create SaveManager Singleton
- **File**: `src/save_manager.gd` (or `addons/save_manager/save_manager.gd`)
- **Responsibilities**:
  - Save current game state to JSON file
  - Load game state from JSON file
  - Manage save slots (list, delete, validate)
  - Handle file I/O and error handling
  
#### 2.2 Create GameState Class
- **File**: `src/game_state.gd`
- **Responsibilities**:
  - Serialize/deserialize game state
  - Collect data from all relevant game systems (player, world, towns)
  - Version management for save compatibility

#### 2.3 Data Collection Points
- **Player System**: Position, inventory, statistics
- **World System**: Map state, game time
- **Town System**: Visited status, resource states
- **Inventory System**: Items, gold, resources

#### 2.4 Implementation Details
- Create autosave mechanism (optional: save on entering towns, after trades)
- Implement save slot validation (check for corrupt files)
- Add timestamp to each save for display in load menu
- Error handling for file I/O failures

---

### Phase 3: Pause Menu & Load Menu

**Objective**: Add in-game pause functionality and load game selection UI.

#### 3.1 Pause Menu Scene
- **File**: `gui/pause_menu.tscn`
- **Features**:
  - Resume Game button
  - Save Game button (with slot selection)
  - Load Game button
  - Settings (future expansion)
  - Return to Main Menu button
  - Quit to Desktop button

#### 3.2 Load Game Menu Scene
- **File**: `gui/load_game_menu.tscn`
- **Features**:
  - Display all 3 save slots with:
    - Slot number
    - Save timestamp
    - Player level/progress indicator
  - Select slot to load
  - Delete save option
  - Cancel/Back button

#### 3.3 Integration
- Pause Menu accessible via ESC key during gameplay
- Pause Menu pauses game time and physics
- Load Menu accessible from Start GUI and Pause Menu

---

## Technical Requirements

### File Structure Changes
```
gui/
  ├── start_gui.tscn (NEW)
  ├── start_gui.gd (NEW)
  ├── start_menu.tscn (NEW - subscene or part of start_gui)
  ├── pause_menu.tscn (NEW - Phase 3)
  ├── load_game_menu.tscn (NEW - Phase 3)
  ├── version_widget.tscn (NEW - convert from .gd only)
  └── [existing files]

src/
  ├── save_manager.gd (NEW - Phase 2)
  ├── game_state.gd (NEW - Phase 2)
  └── [existing files]

world/
  ├── main.gd (MODIFY - remove version_widget reference)
  ├── main.tscn (MODIFY - remove version_widget node)
  └── [existing files]
```

### Dependencies
- Godot 4.x built-in JSON support
- GUT for testing save/load functionality

### Performance Considerations
- Save files should be < 1 MB each
- Save operation should complete in < 500ms
- Load operation should complete in < 1 second

---

## Testing Strategy

### Unit Tests (TDD)
- SaveManager: save/load mechanics, slot management, error handling
- GameState: serialization/deserialization
- Boundary conditions: empty saves, corrupted files, invalid slots

### Integration Tests
- Scene transitions (Start GUI → Main → Pause → Load)
- Data consistency: Save → Load → Verify state matches
- Multiple save slots functionality

### Manual Testing
- UI responsiveness in pause menu
- Scene transitions feel smooth
- Save/load works with all game systems

---

## Dependencies & References

### Existing Assets
- `gui/version_widget.gd` - version display component
- `world/world.png` - potential background for start menu
- `gui/MessageLabelTheme.tres` - UI theme for consistency

### Similar Implementation
- MathDungeon save/load architecture (reference design)

---

## Phase Timeline

| Phase | Scope | Priority |
|-------|-------|----------|
| **Phase 1** | Start GUI Scene creation | 🔴 High |
| **Phase 2** | Save/Load system implementation | 🔴 High |
| **Phase 3** | Pause Menu & Load UI | 🟡 Medium |

---

## Success Criteria

- ✅ Start GUI scene displays correctly with all buttons functional
- ✅ Player can start new game from Start GUI
- ✅ Player can save game state to 3 different slots
- ✅ Player can load game state from any slot
- ✅ All game data persists correctly through save/load cycle
- ✅ Version widget appears in lower left corner of start GUI
- ✅ Version widget no longer in main scene
- ✅ All existing tests continue to pass
- ✅ New save/load tests have > 80% code coverage

