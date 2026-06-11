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

### Critical Data to Save

The following data must be persisted for proper save/load functionality:

1. **Player State**
   - Position coordinates
   - Inventory contents (gold, items)
   - Ship state

2. **World State**
   - **World generation seed**
   - Game time/progression

3. **Towns State**
   - Inventory

### Save File Location
- **Directory**: `user://saves/`
- **File naming**: `save_slot_1.json`, `save_slot_2.json`, `save_slot_3.json`
- **Max slots**: 3
- **Format**: JSON

---

## Implementation Phases

### Phase 1: Start GUI Scene (UI Foundation)

**Objective**: Create the main menu interface as the game entry point.

**Implementation Steps**:

1. Create scene structure
   - Create `gui/start_gui.tscn` with Control root
   - Contains `gui/start_menu.tscn`
   - Contains `gui/version_widget.gd`

2. Create Start menu scene

3. Create Start GUI script (`gui/start_gui.gd`)
   - Handle "New Game" button → loads `world/main.tscn`
   - Handle "Load Game" button → placeholder (implemented in Phase 3)
   - Handle "Quit" button → quits application

4. Refactor existing scenes
   - Remove `version_widget` node from `world/main.tscn`
   - Remove `version_widget` reference from `world/main.gd`
   - Add `version_widget.tscn` instance to `gui/debug_screen.tscn`

5. Scene transition setup
   - Set `gui/start_gui.tscn` as the initial scene in project settings, OR
   - Keep `world/main.tscn` startable via F6 in editor (for development testing)
   - Implement proper scene switching logic for menu → game transitions

---

### Phase 2: Save/Load System Implementation

**Objective**: Implement core save/load mechanics with focus on preserving the world seed.

**Implementation Steps**:

1. Create SaveManager singleton
   - Create `src/save_manager.gd`
   - Implement `save_game(slot_number: int) -> bool`
   - Implement `load_game(slot_number: int) -> bool`
   - Handle file I/O to `user://saves/` directory

2. Create GameState helper
   - Create `src/game_state.gd`
   - Implement data collection from all game systems:
     - **World seed** from `ProcGenWorld` (priority: CRITICAL)
     - Player position and state
     - Inventory data
     - Town/resource states
     - Game progression data

3. Integrate with ProcGenWorld
   - Modify `world/proc_gen_world.gd` to expose seed getter
   - Ensure seed is passed to load functions to regenerate identical world
   - Verify world regeneration produces exact same layout

4. Add save/load trigger points
   - Call `SaveManager.save_game(slot)` when player initiates save
   - Call `SaveManager.load_game(slot)` when player selects load
   - Handle errors gracefully (file not found, corrupted data, etc.)

5. Testing
   - Create tests for save/load cycle
   - Verify world seed is correctly saved and restored
   - Verify all game state persists through save/load

---

### Phase 3: Pause Menu & Load Menu

**Objective**: Add in-game pause functionality and save/load selection UI.

**Implementation Steps**:

1. Create Pause Menu scene (`gui/pause_menu.tscn`)
   - Resume Game button
   - Save Game button (with slot selection)
   - Load Game button
   - Return to Main Menu button
   - Create corresponding script (`gui/pause_menu.gd`)

2. Create Load Game Menu scene (`gui/load_game_menu.tscn`)
   - Display all 3 save slots with:
     - Slot number and timestamp
     - Quick preview of saved state (optional)
   - Select slot to load
   - Delete save option
   - Cancel button
   - Create corresponding script (`gui/load_game_menu.gd`)

3. Integrate pause menu into Main scene
   - Listen for ESC key press during gameplay
   - Toggle pause menu visibility
   - Pause game time/physics when menu active
   - Resume on menu close

4. Connect save/load to UI
   - "Save Game" button opens slot selector → calls SaveManager
   - "Load Game" button opens load menu → calls SaveManager
   - Handle success/error feedback to player

5. Testing
   - Test pause/unpause mechanics
   - Test save slot selection and save operation
   - Test load game from various save slots
   - Verify seed is preserved and world regenerates correctly

---

## Technical Requirements

### Development Constraint ⚠️

The `world/main.tscn` scene **must remain startable as a separate scene** in the Godot Editor (F6) for development and testing purposes. This allows developers to test gameplay without going through the menu.

### File Structure Changes
```
gui/
  ├── start_gui.tscn (NEW - Phase 1)
  ├── start_gui.gd (NEW - Phase 1)
  ├── version_widget.tscn (NEW - Phase 1, convert from .gd)
  ├── pause_menu.tscn (NEW - Phase 3)
  ├── pause_menu.gd (NEW - Phase 3)
  ├── load_game_menu.tscn (NEW - Phase 3)
  ├── load_game_menu.gd (NEW - Phase 3)
  └── [existing files]

src/
  ├── save_manager.gd (NEW - Phase 2)
  ├── game_state.gd (NEW - Phase 2)
  └── [existing files]

world/
  ├── main.gd (MODIFY - Phase 1: remove version_widget, add pause menu)
  ├── main.tscn (MODIFY - Phase 1: remove version_widget node)
  ├── proc_gen_world.gd (MODIFY - Phase 2: expose seed getter)
  └── [existing files]
```

### Dependencies
- Godot 4.x built-in JSON support
- GUT framework for testing save/load functionality

---

## Testing Strategy

### Phase 1 Tests (Start GUI)
- Scene loads without errors
- Buttons are responsive and trigger correct signals
- Version widget displays correctly in lower left corner

### Phase 2 Tests (Save/Load System)
- SaveManager correctly saves game state to JSON
- SaveManager correctly loads game state from JSON
- **World seed is preserved and world regenerates identically after load**
- All three save slots work independently
- Error handling for missing/corrupted files
- Player state, inventory, and progression persist through save/load cycle

### Phase 3 Tests (Pause Menu)
- Pause menu toggles with ESC key
- Game state is paused (no movement, no time progression)
- Save/Load buttons in pause menu trigger correct operations
- Load menu displays all save slots correctly

### Manual Testing
- Full playthrough: Start new game → play → save → quit → load → verify identical world
- Test F6 key still works to start `world/main.tscn` directly (development workflow)

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
- ✅ **World seed is saved and world regenerates identically when loaded**
- ✅ Player can save game state to 3 different slots
- ✅ Player can load game state from any slot with all data intact
- ✅ Version widget appears in lower left corner of Start GUI and Debug Screen
- ✅ Version widget removed from Main scene
- ✅ `world/main.tscn` remains startable via F6 key in Godot Editor (development feature)
- ✅ All existing tests continue to pass
- ✅ New tests for save/load functionality have > 80% code coverage

