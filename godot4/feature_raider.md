# Feature: Raider

## Feature Summary
Add a hostile land character named Raider that spawns in the world, detects nearby player presence, chases faster than the player, steals half of player gold and goods on collision, and is removed after the robbery. Raider spawning is handled by ProcGenWorld simulation (similar to goods simulation), and entering town clears active chasers so towns function as safe zones.

## Requirements Checklist
- [ ] Spawn Raider on land.
- [ ] Spawn new Raiders through ProcGenWorld simulation loop (similar lifecycle style as goods).
- [ ] Start chase when player is near Raider.
- [ ] Raider speed is faster than player speed.
- [ ] Show message on Raider-player collision.
- [ ] Apply actual loss of half gold and half goods on collision.
- [ ] Remove Raider immediately after successful robbery.
- [ ] Remove chasing Raider when player reaches a town.
- [ ] Town behaves as safe zone while player is inside.

## Assumptions
- Raider simulation supports recurring spawns over time, with a configurable cap (default 1 active Raider for minimal-invasive scope).
- Raider exists only in overworld gameplay, never inside town UI mode.
- Halving rule for odd numbers uses integer floor for amount lost:
  - lost = floor(value / 2)
  - remaining = value - lost
- Goods are represented by player TradingItem stock values in player inventory.
- To avoid repeated theft while overlapping colliders, a Raider is removed immediately after the first successful theft.
- Message display uses existing MessageBus and MessageWidget flow.
- Save/load should preserve active Raider simulation state (active Raiders and spawn cooldown/timer) with backward compatibility.

## Implementation Plan

### Phase 1: Raider Domain Setup
Goal: Introduce Raider scene/script with chase behavior and collision handling hooks.

Files
- New file: world/raider.gd
- New file: world/raider.tscn

Tasks
1. Create Raider as CharacterBody2D with:
   - exported chase_distance
   - exported move_speed
   - exported theft_done flag (or internal once-only guard)
   - player reference
2. Implement Raider states:
   - idle (not chasing)
   - chasing (within range)
3. Implement movement in _physics_process:
   - if chasing, move toward player position
   - no movement in town-safe context (controlled by Main lifecycle)
4. Emit signal on player collision:
   - example signal: player_caught(player: Player)
5. Keep visuals simple/minimal (Sprite2D placeholder acceptable for first pass).

### Phase 2: World Integration and Spawn Lifecycle
Goal: Manage Raider spawning and cleanup inside ProcGenWorld simulation, aligned with existing goods simulation patterns.

Files
- [world/main.gd](world/main.gd)
- [world/main.tscn](world/main.tscn)
- [world/proc_gen_world.gd](world/proc_gen_world.gd)
- [world/proc_gen_world.tscn](world/proc_gen_world.tscn)

Tasks
1. Add a dedicated Raiders root node under ProcGenWorld scene for y-sort consistency:
   - sibling to existing Towns and Goods
2. Add simulation-driven spawning in ProcGenWorld:
   - raider_spawn_timer and raider_spawn_interval
   - max_active_raiders cap (default 1)
   - process_raider_simulation(delta, player) called from world simulation loop
3. Add spawn helper in ProcGenWorld:
   - get_random_land_spawn_position(exclude_positions := [])
   - source from grass_arr/farm-compatible land positions
4. In Main:
   - preload Raider scene
   - delegate spawning decisions to ProcGenWorld simulation
   - set Raider speed > Player.LAND_SPEED
5. Connect Raider signal to Main theft handler.
6. On town_entered:
   - remove all active Raiders immediately
   - ensure no respawn while player.in_town() is true
7. On town_left:
   - allow normal spawn checks again.

### Phase 3: Theft and Message Logic
Goal: Apply exact gameplay effects on collision.

Files
- [world/main.gd](world/main.gd)
- [player/player.gd](player/player.gd)
- [trading_system/trading_item.gd](trading_system/trading_item.gd)

Tasks
1. Add player helper methods for reuse and testability:
   - lose_half_gold() -> int lost_amount
   - lose_half_goods() -> Dictionary lost_by_good_id
2. In Main collision handler:
   - call player loss methods once
   - emit message through MessageBus with clear text:
     - Raider took half of your gold and goods.
3. Enforce immediate Raider removal after robbery:
   - queue_free the colliding Raider in same handler
   - unregister it from ProcGenWorld active Raider tracking
   - prevent repeated collision deductions.
4. Ensure empty inventory/gold=0 paths do not error and message still displays.
5. Ensure simulation can spawn new Raiders again after removal, respecting cooldown/cap.

### Phase 4: Save/Load and Backward Compatibility
Goal: Persist Raider simulation state without breaking old saves.

Files
- [world/proc_gen_world_serializer.gd](world/proc_gen_world_serializer.gd)
- [world/save_manager.gd](world/save_manager.gd)
- [world/main.gd](world/main.gd)

Tasks
1. Extend world save payload with optional raiders object:
   - active_raiders: list of {position x/y, chasing}
   - spawn_timer_remaining
   - max_active_raiders (optional if configurable)
2. Serializer rules:
   - write raiders block only when needed
   - on load, tolerate missing raiders key (legacy saves)
3. Main restore flow:
   - after world generation and load-state restore, recreate tracked Raiders if player not in town.
4. Confirm save manager merge remains stable with new optional world.raiders field.

### Phase 5: Town Safe-Zone Guarantees
Goal: Make safety behavior explicit and robust.

Files
- [world/main.gd](world/main.gd)
- [player/player.gd](player/player.gd)
- [gui/town_menu.gd](gui/town_menu.gd)

Tasks
1. Use existing town_entered and town_left signal flow in Main for Raider lifecycle.
2. Add explicit guard in spawn loop:
   - never spawn Raider while player.in_town().
3. Ensure entering town while currently chased always despawns Raider in same frame/signal cycle.
4. Ensure no collision processing happens after town entry event.

### Phase 6: Testing (TDD with GUT)
Goal: Add incremental red-green-refactor test coverage from pure logic to integration edges.

Primary Test File
- New file: test/test_raider.gd

Additional Test Files to Extend
- [test/test_player.gd](test/test_player.gd)
- [test/test_main.gd](test/test_main.gd)
- [test/test_proc_gen_world_serializer.gd](test/test_proc_gen_world_serializer.gd)

TDD Test List (ordered simple to complex)

1. test/test_player.gd
- [ ] test_lose_half_gold_even_value
- [ ] test_lose_half_gold_odd_value_uses_floor_loss
- [ ] test_lose_half_gold_zero_remains_zero
- [ ] test_lose_half_goods_even_stock_each_item
- [ ] test_lose_half_goods_odd_stock_uses_floor_loss
- [ ] test_lose_half_goods_empty_inventory_no_errors

2. test/test_raider.gd
- [ ] test_raider_starts_not_chasing_when_player_outside_range
- [ ] test_raider_starts_chasing_when_player_enters_range
- [ ] test_raider_speed_is_greater_than_player_land_speed
- [ ] test_raider_moves_toward_player_while_chasing
- [ ] test_raider_emits_player_caught_on_collision
- [ ] test_raider_is_removed_immediately_after_successful_theft

3. test/test_main.gd
- [ ] test_main_calls_proc_gen_world_raider_simulation_each_tick
- [ ] test_main_does_not_spawn_raider_while_player_in_town
- [ ] test_main_removes_all_active_raiders_on_town_entered
- [ ] test_main_raider_collision_emits_message
- [ ] test_main_raider_collision_reduces_player_gold_and_goods_by_half
- [ ] test_main_raider_is_removed_after_collision_and_cannot_double_deduct
- [ ] test_main_town_entry_while_chased_clears_raider_before_next_physics_tick

4. test/test_proc_gen_world.gd
- [ ] test_proc_gen_world_raider_simulation_spawns_on_land_after_interval
- [ ] test_proc_gen_world_raider_simulation_respects_max_active_raiders
- [ ] test_proc_gen_world_raider_simulation_spawns_new_raider_after_previous_removed

5. test/test_proc_gen_world_serializer.gd
- [ ] test_get_save_data_includes_active_raider_when_present
- [ ] test_set_save_data_restores_active_raider_state
- [ ] test_set_save_data_missing_raider_key_keeps_backward_compatibility

## File-by-File Change Plan

| File | Change Type | Planned Changes |
|---|---|---|
| world/raider.gd (new) | Add | Raider behavior class, chase state, movement, collision signal, once-only theft guard fields. |
| world/raider.tscn (new) | Add | CharacterBody2D scene with collision shape and minimal visual node structure. |
| [world/proc_gen_world.tscn](world/proc_gen_world.tscn) | Modify | Add Raiders Node2D container under ProcGenWorld. |
| [world/proc_gen_world.gd](world/proc_gen_world.gd) | Modify | Add Raider simulation loop, spawn timer/interval, max count cap, land spawn helper, active Raider tracking, and cleanup registration. |
| [world/main.gd](world/main.gd) | Modify | Call ProcGenWorld Raider simulation, handle collision theft message/loss, remove colliding Raider, clear all Raiders on town entry, and restore hooks. |
| [world/main.tscn](world/main.tscn) | Optional Modify | Only if a direct Raider node reference is needed; otherwise keep unchanged and instantiate dynamically. |
| [player/player.gd](player/player.gd) | Modify | Add half-loss helper methods for gold and inventory stocks. |
| [world/proc_gen_world_serializer.gd](world/proc_gen_world_serializer.gd) | Modify | Serialize/restore optional world.raiders simulation block (active list + timer fields). |
| [world/save_manager.gd](world/save_manager.gd) | Verify/Minor | Confirm no special changes needed beyond serializer output merge; add only if explicit helper wiring is required. |
| [test/test_player.gd](test/test_player.gd) | Modify | Add unit tests for halving rules and edge cases. |
| test/test_raider.gd (new) | Add | New Raider-focused movement/chase/collision tests. |
| [test/test_main.gd](test/test_main.gd) | Modify | Add integration tests for simulation calls, theft/removal flow, and safe-zone behavior. |
| [test/test_proc_gen_world.gd](test/test_proc_gen_world.gd) | Modify | Add tests for simulation-based Raider spawning and respawn after removal. |
| [test/test_proc_gen_world_serializer.gd](test/test_proc_gen_world_serializer.gd) | Modify | Add persistence tests for Raider world state and legacy save compatibility. |

## Dependencies and Integration Notes
- Phase 1 must complete before integration tests in Phase 6 can execute.
- Player half-loss helpers should be completed before Main collision handler to keep logic testable.
- ProcGenWorld simulation contract should be stable before Main integration tests.
- Serializer changes depend on stable Raider simulation data shape from ProcGenWorld.
- Town safe-zone depends on existing signal chain:
  - town_entered from Town to Main and Player
  - town_left from TownMenu to Main and Player
- Keep changes isolated:
  - Avoid touching TradingSystem pricing logic.
  - Avoid modifying Town inventory logic.
  - Use existing MessageBus path for UI notification.

## Potential Edge Cases
- Odd-number halving:
  - gold 5 -> lose 2, keep 3
  - stock 7 -> lose 3, keep 4
- Empty inventory:
  - no errors, no negative values, message still shown.
- Repeated collisions:
   - theft happens once, then that Raider is removed immediately.
- Rapid respawn loop:
   - simulation must enforce spawn interval to avoid instant respawn every frame.
- Active cap handling:
   - simulation must not exceed max_active_raiders.
- Town entry while chased:
   - all active Raiders must be removed immediately and cannot steal afterward.
- Player on ship:
  - no land Raider spawn while not on land.
- Save during chase:
  - active Raider restored correctly after load (unless player loads directly into town state).

## Acceptance Criteria
- [ ] Raider appears in overworld land gameplay without manual debug actions.
- [ ] New Raiders are spawned by ProcGenWorld simulation over time on land.
- [ ] Raider begins pursuing player once within configured proximity.
- [ ] Raider movement is observably faster than player land movement.
- [ ] Collision triggers a visible message about losing half gold and goods.
- [ ] Player gold is reduced by exactly half-loss rule.
- [ ] Every tracked good stock is reduced by exactly half-loss rule.
- [ ] Raider is removed immediately after robbing the player.
- [ ] After Raider removal, simulation can spawn new Raiders again.
- [ ] Entering any town while chased despawns Raider immediately.
- [ ] No Raider threat exists while player remains in town (safe zone).
- [ ] Repeated overlap cannot repeatedly apply theft from same Raider.
- [ ] Save/load keeps behavior consistent and does not break old saves.

## Validation Checklist

### Automated (GUT)
- [ ] Run targeted Raider/player/main/serializer tests.
- [ ] Run full suite to detect regressions in trading, town, and save systems.
- [ ] Confirm new tests pass in headless mode:
  - godot --path . --headless --script addons/gut/gut_cmdln.gd -gexit

### Manual Gameplay
- [ ] Start new game: verify Raider spawn on land.
- [ ] Wait through simulation interval: verify new Raider appears without manual trigger.
- [ ] Walk near Raider: verify chase starts.
- [ ] Compare movement: Raider closes distance over time.
- [ ] Trigger collision: verify message, actual inventory/gold changes, and immediate Raider removal.
- [ ] Continue playing on land: verify a new Raider can spawn later through simulation.
- [ ] Test odd values (set via debug or quick setup): verify floor-loss behavior.
- [ ] Enter town while chased: verify Raider removed immediately.
- [ ] Stay in town: verify no re-spawn and no theft.
- [ ] Leave town to overworld land: verify normal Raider spawn lifecycle resumes.

### Save/Load
- [ ] Save while chased; reload; verify Raider state is restored correctly.
- [ ] Save in town; reload; verify no active Raider in safe zone.
- [ ] Load older save without raider data; verify no load errors and normal play.
