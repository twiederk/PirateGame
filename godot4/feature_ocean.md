# Feature Plan: Ocean / Deep Water

## Goal
Introduce two water depths generated from noise and enforce ship capability rules:
- `DEEP_WATER_LEVEL` separates deep vs shallow water.
- Deep water uses dedicated tiles.
- Deep water blocks non-ocean-going ships via a new physics layer (`ocean`).

## Requested Rules (as implementation targets)
1. If `noise_val < DEEP_WATER_LEVEL`: place **deep water**.
2. If `DEEP_WATER_LEVEL <= noise_val <= WATER_LEVEL`: place **shallow water**.
3. Add deep-water tiles to the tileset.
4. Add `ocean_going` to `ShipResource`.
5. Add a 2D physics layer named `ocean`.
6. Give deep-water tiles collision on the `ocean` layer.
7. In `Player.board_ship`, check `ocean_going` to decide whether `ocean` collision mask is enabled.
8. Remove magic numbers from `set_collision_mask_value` calls in `Player.board_ship`.

## Current Baseline (from code)
- World generation currently has one water threshold in `WATER_LEVEL` in `world/proc_gen_world.gd`.
- Water uses one tile (`water_tile = Vector2i(0,1)`) in `WaterLayer`.
- Physics layer names in `project.godot` currently include: `player`, `water`, `land`, `environment`.
- `Player.board_ship` currently toggles hard-coded mask indices `2` and `3` in `player/player.gd`.
- `ShipResource` currently has no ocean capability flag.

## Design Decisions
1. Threshold constants
- Add `DEEP_WATER_LEVEL` as a constant in `ProcGenWorld`.
- Keep `WATER_LEVEL` as shallow-water upper bound.
- Constraint: `DEEP_WATER_LEVEL < WATER_LEVEL`.

2. Ocean collision behavior
- While on foot: ocean mask stays disabled.
- While on ship:
  - ocean-going ship: ocean mask disabled (can cross deep water).
  - non-ocean-going ship: ocean mask enabled (blocked by deep water).

3. Replace mask magic numbers
- Add named constants in `Player` for mask indices, for example:
  - `MASK_WATER`
  - `MASK_LAND`
  - `MASK_OCEAN`
- Use these constants in all `set_collision_mask_value` calls.

## Implementation Steps

### Step 1: Physics layer setup
Files:
- `project.godot`

Tasks:
- Add `2d_physics/layer_5="ocean"` under `[layer_names]`.
- Keep existing layer names unchanged.

Validation:
- Layer appears in Godot collision layer UI as `ocean`.

### Step 2: Tileset deep-water support
Files:
- `world/world.tres` (best edited in Godot TileSet editor)

Tasks:
- Add one or more deep-water tile variants to the atlas.
- Assign collision polygons for deep-water tiles on `physics_layer_*` that maps to `ocean` layer bit.
- Ensure shallow-water tiles remain on existing water behavior.

Validation:
- Deep-water tile(s) have collision on ocean layer only.
- Shallow-water tile(s) do not accidentally get ocean collision.

### Step 3: World generation split (deep vs shallow)
Files:
- `world/proc_gen_world.gd`

Tasks:
- Add `const DEEP_WATER_LEVEL`.
- Replace single-water placement with depth-aware placement logic:
  - `noise_val < DEEP_WATER_LEVEL` -> deep-water tile.
  - `DEEP_WATER_LEVEL <= noise_val <= WATER_LEVEL` -> shallow-water tile.
- Keep sand/grass/cliff logic unchanged unless required by the new thresholds.

Suggested structure:
- Add separate tile coordinates (`deep_water_tile`, `shallow_water_tile`).
- Keep logic in `_place_water(...)` or split into helpers for readability.

Validation:
- Generated maps visibly show two water depths.
- Coast logic still works (`is_coast`) and towns still generate.

### Step 4: Ship resource capability
Files:
- `trading_system/ship_resource.gd`
- `trading_system/ship_boat.tres`
- `trading_system/ship_sailing.tres`

Tasks:
- Add `@export var ocean_going: bool = false` to `ShipResource`.
- Set per ship resource value:
  - Boat: likely `false`.
  - Sailing ship: likely `true`.

Validation:
- Resource inspector shows `ocean_going` for both ship assets.
- Existing loading/equipping flows remain compatible.

### Step 5: Player boarding and collision masks
Files:
- `player/player.gd`

Tasks:
- Replace hard-coded mask indices with named constants.
- Update `board_ship`:
  - ON_LAND -> ON_SHIP:
    - disable water mask
    - enable land mask
    - set ocean mask depending on `_ship_resource.ocean_going`
  - ON_SHIP -> ON_LAND:
    - enable water mask
    - disable land mask
    - disable ocean mask
- Keep animation/speed/state toggles intact.

Validation:
- Non-ocean-going ship cannot enter deep water.
- Ocean-going ship can enter deep water.
- Land/sea transitions still behave as before.

### Step 6: Tests
Files:
- `test/test_player.gd`
- `test/test_proc_gen_world.gd`
- Optional: `test/test_ship_resource.gd` (new)

Tasks:
- Add/extend tests for:
  - `ShipResource.ocean_going` defaults and specific ship resources.
  - `Player.board_ship` mask behavior for ocean-going vs non-ocean-going ships.
  - (Optional unit-level) water depth classification helper logic in `ProcGenWorld`.

Notes:
- Current tests are minimal around world generation and ship boarding logic; this feature needs direct tests for collision mask toggling.

Validation:
- All existing tests pass.
- New tests pass and cover both ship types.

## Suggested Task Order
1. Add `ocean` layer in project settings.
2. Add deep-water tiles + ocean collisions in tileset.
3. Implement generation thresholds in `ProcGenWorld`.
4. Add `ocean_going` to `ShipResource` + update ship resources.
5. Refactor and update `Player.board_ship` mask logic.
6. Add/update tests.
7. Manual playtest in editor.

## Manual Test Checklist
1. Start a new game and inspect generated map for shallow/deep water visuals.
2. Equip non-ocean-going ship and verify deep water is blocked.
3. Equip ocean-going ship and verify deep water is passable.
4. Board/unboard repeatedly at coast and verify no collision state leaks.
5. Verify environment and land collisions still work.

## Risks / Edge Cases
- Deep-water threshold set too close to `WATER_LEVEL` can make depth distinction rare.
- Tile collision misconfiguration in TileSet editor can invert behavior.
- Existing save files may reference ship resources; adding a new exported field should remain backward compatible, but should be sanity-checked.
- If initial `collision_mask` in `player.tscn` conflicts with runtime assumptions, first board/unboard cycle should still normalize masks.

## Definition of Done
1. World generates with deep + shallow water according to thresholds.
2. Tileset has deep-water tiles configured with ocean collision.
3. `ShipResource` includes `ocean_going`, and ship assets are configured.
4. `Player.board_ship` uses named mask constants (no magic numbers).
5. Ocean mask logic behaves correctly for both ship categories.
6. Automated tests updated and passing.
7. Manual checklist completed without regressions.
