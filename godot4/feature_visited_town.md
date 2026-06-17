# Feature: Display Town Names and Track Visited Towns

## Feature Overview

This feature adds the ability to display town names in the world view and track which towns the player has visited. When a player enters a town for the first time, the town's `visited` property is set to `true`, and its name becomes visible in the world view below the town. This helps players identify which towns they've already visited and gives the towns more character and atmosphere.

### Key Requirements

- ✅ Add a `visited: bool` property to the `Town` class (initially `false`)
- ✅ Display town name label in the world view only for visited towns
- ✅ Set `visited` to `true` when the player opens the town menu
- ✅ Save and load the `visited` property state
- ✅ Add a Label node to `town.tscn` to display the town name
- ✅ Restore visited state when loading a game

---

## Implementation Plan

### Phase 1: Town Class Enhancement

**File**: `world/town.gd`

**Tasks**:
1. Add `visited: bool` property to the `Town` class (default: `false`)
2. Emit a signal when town is visited for the first time (e.g., `signal town_visited`)

---

### Phase 2: Town Scene Modification

**File**: `world/town.tscn`

**Tasks**:
1. Add a new Label node as a child of the Town scene
2. Position the label below the town visual representation
3. Configure the label:
   - Anchor it to the bottom center of the town
   - Use an appropriate font size
   - Set initial visibility to `false` (will be toggled via script)
4. Reference the label in `town.gd` via `@onready`

---

### Phase 3: Town Initialization and Display Logic

**File**: `world/town.gd`

**Tasks**:
1. Add `@onready var town_name_label: Label` to reference the scene label
2. Create method `_update_name_label_visibility()` to show/hide label based on visited state
3. Call `_update_name_label_visibility()` in `_ready()` to initialize label state
4. Set label text to town name in `_ready()`
5. Create method `mark_town_as_visited()` that:
   - Sets `visited = true`
   - Calls `_update_name_label_visibility()`
   - Emits `town_visited` signal

---

### Phase 4: Integration with TownMenu

**File**: `gui/town_menu.gd`

**Tasks**:
1. In the `init()` method, call `_town.mark_town_as_visited()` when the town menu is opened
2. This ensures the town is marked as visited exactly when the player opens the menu

---

### Phase 5: Save/Load Integration

**File**: `world/proc_gen_world.gd`

**Tasks**:

1. **Extend `_serialize_town_save_data()` method**:
   - Add `"visited"` property to the returned dictionary
   - Include town's visited state in serialization

2. **Extend `_restore_town_inventory_from_save()` method**:
   - Rename to `_restore_town_from_save()` to reflect broader responsibility
   - Include restoration of `visited` property
   - Call `mark_town_as_visited()` if visited state was `true` in save data
   - Ensure label visibility is updated after restoration

3. **Update `set_save_data()` method**:
   - Call the renamed method with proper visited state restoration

---

### Phase 6: Testing (TDD)

Tests should follow the Red-Green-Refactor cycle using GUT.

**Test File**: `test/test_town_visited.gd`

---

## TDD Test List

- test_town_initialization
- test_get_visited_state_correctly
- test_mark_town_as_visited
- test_emit_town_visited_signal_when_visited
- test_handle_marking_visited_town_again
- test_display_town_name_label_when_visited
- test_hide_town_name_label_when_unvisited
- test_set_town_name_label_text_to_town_name
- test_return_town_name
- test_serialize_town_visited_state_in_save_data
- test_serialize_unvisited_town_as_false
- test_restore_visited_state_from_save_data
- test_restore_unvisited_state_from_save_data
- test_update_label_visibility_after_restoring_save
- test_keep_label_hidden_for_unvisited_town_after_restore
- test_mark_town_as_visited_when_town_menu_initialized
- test_handle_multiple_different_towns_visited
- test_correctly_serialize_multiple_towns_with_different_visited_states
- test_preserve_visited_states_through_full_save_load_cycle
- test_handle_loading_save_data_without_visited_property

---

## Notes

- The town name is already generated in `ProcGenWorld.generate_towns()` via the `_create_town()` method
- Town names follow the pattern: `{TownTypeName} {number}` (e.g., "Harbor Town 1")
- TownMenu already displays the town name in the menu; the label in world view is independent
- The visited state should be saved whenever a save occurs, so the existing save/load flow needs modification
- Label positioning should align with the town's visual representation in the 2D scene
