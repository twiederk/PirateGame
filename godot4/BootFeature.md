# Boat Mechanics Feature: Simplified Coast-Based Boat Entry/Exit

## Context
I am developing a 2D top-down game in Godot 4. The game world consists of multiple `TileMapLayer` nodes: one for land/ground and one for water.
The player (`CharacterBody2D`) moves on foot by default on land. The player can toggle between walking and boating modes by swapping sprites and collision layers.

## Key Mechanic
The player can **toggle between on-foot and boat modes by pressing E (interact action) when standing on a coast tile**.

- **Entering the boat (on land):** Player stands on a coast tile (terrain ID 3, `sand_in_water`, variants 1+) and presses E → switches to boat mode (sprite changes to boat, Layer 0 collision disabled).
- **Exiting the boat (on water):** Player is in boat mode on a water tile (terrain ID 4), and that water tile is **adjacent to at least one coast tile** → presses E → switches to land mode (sprite changes back to player, Layer 0 collision re-enabled) on the adjacent coast tile in their facing direction.

**Important constraint:** The boat cannot drive onto coast tiles because they have land collision (physics_layer_0). The boat must stay on water (physics_layer_2) and can only exit when adjacent to coast.

## Physics & Layer Setup
* **Physics Layer 0 (Land collisions):** Terrain obstacles (walls, cliffs, trees). Coast tiles have this layer.
* **Physics Layer 2 (Water collisions):** Water tiles only. Used for boat movement detection.
* **Player collision (on foot):** Collision masks for Layer 0 and Layer 2 are **ACTIVE** (blocked by land and water).
* **Player collision (in boat):** Collision mask for Layer 0 is **DISABLED** (can drive on water), mask for Layer 2 remains **ACTIVE** (cannot drive onto land). *Note: Cannot drive onto coast tiles because they have Layer 0.*

## Terrain ID Reference
- **Terrain Set 0:** Land/ground tiles (various grass variants)
- **Terrain Set 3:** Coast tiles (`sand_in_water`) — These mark the boundary between land and water. First variant (index 0) is open water; variants 1+ are walkable coast.
- **Terrain Set 4:** Deep water tiles with physics_layer_2 collision — The boat's domain.

## Implementation Task
Create clean, well-commented GDScript code for the following component:

**Extension to `Player.gd` (CharacterBody2D):**
* Implement a state system with two states: `ON_LAND` and `IN_BOAT`.
* Add sprite references: `player_sprite` (default) and `boat_sprite` (for boat mode).
* **`_is_coast_tile(tile_pos: Vector2i) -> bool`**: Check if a tile position corresponds to terrain_set=3 (coast). Use `TileMapLayer.get_cell_tile_data()` and the custom terrain data.
* **`_is_water_tile(tile_pos: Vector2i) -> bool`**: Check if a tile position corresponds to terrain_set=4 (water).
* **`_has_adjacent_coast(tile_pos: Vector2i) -> bool`**: Check if a water tile has at least one adjacent coast tile (in 4 cardinal directions or 8 directions).
* **`_find_coast_in_direction(direction: Vector2) -> Vector2i`**: Return the tile position of an adjacent coast tile in the player's facing direction. If no coast exists in that direction, return the first available adjacent coast tile.
* **`_enter_boat_mode()`**: 
  * Change state to `IN_BOAT`.
  * Swap sprite to boat sprite.
  * Disable collision mask for Layer 0 (land collision) so the player can move on water.
* **`_exit_boat_mode()`**: 
  * Validate that current tile is on water AND has at least one adjacent coast tile.
  * If valid: Find coast tile in player's facing direction, move player to that coast tile, swap sprite back to player sprite, re-enable Layer 0 collision mask, change state to `ON_LAND`.
  * If invalid (in open water with no adjacent coast): Block the action; player remains in boat.
* **Integrate `"interact"` input handling in `_process()`**: 
  * When in boat state and E is pressed, call `_exit_boat_mode()`.
  * When on land state and E is pressed while standing on a coast tile, call `_enter_boat_mode()`.

## Implementation Steps

### Phase 1: Project Setup & Verification
1. **Verify "enter_exit_boat" action exists in input map**
   - Check `project.godot` for the `"enter_exit_boat"` action binding (should map to 'E' key)
   - If missing, add it: `Project → Project Settings → Input Map → Add "enter_exit_boat" action bound to 'E'`

2. **Identify TileMapLayer references in scene**
   - Open `proc_gen_world.tscn` and locate the TileMapLayer nodes
   - Identify which layer contains water (terrain_set=4) — should be `water_layer`
   - Note the path for script access (e.g., `%water_layer` or `$TileMap/water_layer`)

3. **Create placeholder boat sprite**
   - Quick visual placeholder to distinguish boat mode from walking (can be a simple rectangle or recolor)
   - Export as PNG or use a simple Sprite2D modulation change temporarily

### Phase 2: Add State System to Player.gd
4. **Add state enum and variables**
   - Define `enum STATE { ON_LAND, IN_BOAT }`
   - Add state tracking variable: `var current_state = STATE.ON_LAND`
   - Add sprite references: `@onready var player_sprite` and create a boat sprite variant

5. **Add TileMapLayer references**
   - Add `@onready` or `@export` references to the water and ground TileMapLayers
   - Ensure they point to the correct layers in the scene

### Phase 3: Implement Terrain Detection Functions
6. **Implement `_is_coast_tile(tile_pos: Vector2i) -> bool`**
   - Get tile data from the TileMapLayer using `get_cell_tile_data()`
   - Check if the tile's `terrain_set` equals 3
   - Exclude variant 0 (index 0 should not count as coastable coast)
   - Return true only for valid coast tiles

7. **Implement `_is_water_tile(tile_pos: Vector2i) -> bool`**
   - Similar logic: get tile data and check if `terrain_set` equals 4
   - Return true for water tiles

8. **Implement `_has_adjacent_coast(tile_pos: Vector2i) -> bool`**
   - Check all 4 cardinal directions (up, down, left, right) from the given tile
   - Call `_is_coast_tile()` for each adjacent position
   - Return true if at least one adjacent tile is coast

9. **Implement `_find_coast_in_direction(direction: Vector2) -> Vector2i`**
   - Normalize the direction vector to get primary direction (up/down/left/right)
   - Check if the adjacent tile in that direction is coast
   - If yes, return that tile position
   - If no, check all 4 cardinal neighbors and return the first coast tile found
   - Return current position if no coast found (handle gracefully in calling code)

### Phase 4: Implement Mode Switching Functions
10. **Implement `_enter_boat_mode()`**
   - Change `current_state` to `STATE.IN_BOAT`
   - Call method to swap sprite to boat sprite (e.g., `player_sprite.visible = false`, boat sprite visible)
   - Disable Layer 0 collision mask: `collision_mask &= ~(1 << 0)` (or use visual collision layer API)
   - Print debug message: `print("Entered boat mode")`

11. **Implement `_exit_boat_mode()`**
   - Get player's current tile position using `local_to_map(global_position)`
   - Verify current tile is water: `if not _is_water_tile(current_tile_pos): return`
   - Verify adjacent coast exists: `if not _has_adjacent_coast(current_tile_pos): return`
   - Find coast tile in facing direction: `var coast_tile = _find_coast_in_direction(direction)`
   - Convert tile position back to global position
   - Move player to coast: `global_position = tilemap.map_to_local(coast_tile)`
   - Change `current_state` to `STATE.ON_LAND`
   - Swap sprite back to player sprite
   - Re-enable Layer 0 collision mask: `collision_mask |= (1 << 0)`
   - Print debug message: `print("Exited boat mode at coast")`

### Phase 5: Input Handling
12. **Add enter/exit boat input handling in `_process()`**
   - Check if `Input.is_action_just_pressed("enter_exit_boat")`
   - If `current_state == STATE.IN_BOAT`: call `_exit_boat_mode()`
   - If `current_state == STATE.ON_LAND`:
     - Get current tile position
     - Check if `_is_coast_tile()` returns true
     - If yes: call `_enter_boat_mode()`
     - If no: optionally print "Not on coast"

### Phase 6: Testing & Refinement
13. **Manual testing walkthrough**
   - Start game, player on land
   - Walk to a coast tile (terrain_set=3)
   - Press E → sprite should change, movement should allow water traversal
   - Walk to adjacent water tile (terrain_set=4)
   - From water, press E while adjacent to coast → player should move back to coast, sprite changes back
   - Try pressing E in deep water (no adjacent coast) → should fail silently, player stays in boat
   - Verify collision layers are toggled correctly (check Physics debug draw if needed)

14. **Debug & Edge Case Handling**
   - Add console logs for state transitions and tile checks
   - Test edge cases: narrow coastal areas, surrounded water, multiple coast tiles
   - Verify direction-based exit placement logic works (should prefer facing direction)

15. **Code Review & Cleanup**
   - Ensure all functions are well-commented
   - Remove or convert debug print statements
   - Verify no hardcoded values; use configurable layer IDs
   - Ensure TileMapLayer references are easily adjustable

## Usage Notes
- Provide references to the relevant `TileMapLayer` nodes (water_layer, ground_layer, etc.) that can be easily adjusted to your scene structure.
- Terrain checking uses the tileset's custom terrain data; ensure terrain_set IDs match your `world.tres` configuration.
- The sprite swap should handle both visual representation and collision layer toggling in a single state change.