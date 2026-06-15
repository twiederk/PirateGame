# Feature Plan: Persist ProcGenWorld game_time, accumulation, and Town inventory

## Goal
Extend ProcGenWorld save/load so that `get_save_data()` and `set_save_data()` stay in sync while persisting:
- Global ProcGenWorld fields: `game_time`, `accumulation`
- Per-town state: `_inventory` (stock for each good)

All validation must be done in `test/test_proc_gen_world.gd`.

## Current Baseline
`world/proc_gen_world.gd`:
- `get_save_data()` currently returns only `{"world": {"seed_value": seed_value}}` (not yet wrapped)
- No `set_save_data()` method yet
- No `game_time` or `accumulation` fields yet (to be added as global)

`world/town.gd`:
- `town_name`: string identifier
- `town_resource`: TownResource (type/role reference)
- `_inventory`: Dictionary keyed by `good.id`, value is TradingItem with stock

`test/test_proc_gen_world.gd`:
- Only tests `get_save_data()` for world_seed
- No town state tests yet

## Target Save Contract
Extend `save_data` structure:

```gdscript
{
	"world": {
		"seed_value": 12345,
		"game_time": 1200,
		"accumulation": 450,
		"towns": {
			"Harbor 0": {
				"town_name": "Harbor 0",
				"inventory": {
					"1": {"stock": 15},
					"2": {"stock": 8},
				}
			},
			"Farm 1": {
				"town_name": "Farm 1",
				"inventory": {
					"3": {"stock": 42},
					"4": {"stock": 25},
				}
			}
		}
	}
}
```

Notes:
- All world data is nested under "world" key (mirrors "player" hierarchy from Player save/load).
- Global fields `game_time` and `accumulation` are at `world` level (ProcGenWorld-scoped).
- Town identifier is keyed by `town_name` (stable across saves).
- Inventory keys are strings (safer for serialization).
- Only per-town inventory stock is persisted; inventory structure is defined by town_resource.

## Implementation Steps

### Phase 1: Add Town Fields (No Tests Yet)
1. Add `game_time: int = 0` to `town/town.gd`
2. Add `accumulatGlobal ProcGenWorld Fields (No Tests Yet)
1. Add `game_time: int = 0` to `world/proc_gen_world.gd`
2. Add `accumulation: int = 0` to `world/proc_gen_world.gd`
3. These fields will be initialized to 0 in `_ready()` or at construction.

### Phase 2: Extend `get_save_data()` in ProcGenWorld
1. Add tests in `test/test_proc_gen_world.gd` for verifying game_time and accumulation are included in save data.
2. Update `world/proc_gen_world.gd` `get_save_data()` to serialize:
   - world_seed (existing)
   - game_time and accumulation (new global fields)
   - Per-town inventory stock

### Phase 3: Implement `set_save_data()` in ProcGenWorld
1. Add tests in `test/test_proc_gen_world.gd` for loading state.
2. Implement `world/proc_gen_world.gd` `set_save_data()` to restore:
   - game_time and accumulation (global).
   - Per-town inventory stocks (match towns by name).

### Phase 4: Backward Compatibility
1. Handle missing `game_time` and `accumulation` keys in save data (pre-feature saves, default to 0).
2. Handle missing `towns` key gracefully (pre-feature saves).
3. Handle missing individual town fields gracefully.
4# TDD Sequence (Required)
game_time and accumulation.
2. **Green**: add game_time and accumulation fields to ProcGenWorld, serialize both.
3. **Refactor**.
4. **Red**: add test for get_save_data includes towns structure.
5. **Green**: minimal serialization of town names as keys.
6. **Refactor**.
7. **Red**: add test for inventory stock serialization per town.
8. **Green**: add inventory stock to save for each town.
9. **Refactor**: consider helper for inventory serialization (similar to Player).

### Load Side (set_save_data)
10. **Red**: add test for set_save_data restores game_time and accumulation.
11. **Green**: minimal restore logic for those fields.
12. **Refactor**.
13. **Red**: add test for set_save_data restores per-town inventory stock.
14. **Green**: minimal inventory restore.
15. **Refactor**.
16. **Red**: add backward-compatibility test (missing game_time/accumulation/towns in old save).
17. **Green**: handle missing keys gracefully (default to 0 or skip)
16. **Red**: add backward-compatibility test (missing towns key in old save).
17. **Green**: handle missing key gracefully.
18. **Refactor**.

## Test Cases To Add

### Save Data Tests
- `test_get_save_data_includes_game_time_and_accumulation`
- `test_get_save_data_includes_towns_structure`
- `test_get_save_data_includes_town_names`
- `test_get_save_data_includes_town_inventory_stock`

### Load Data Tests
- `test_set_save_data_restores_game_time_and_accumulation`
- `test_set_save_data_restores_town_inventory_stock`
- `test_set_save_data_without_game_time_defaults_to_zero`
- `test_set_save_data_without_towns_key_does_not_crash`

## Integration with Player System

The pattern mirrors `Player.get_save_data()` / `Player.set_save_data()`:
- Top-level save structure is organized by entity: `"player"` and `"world"` at the same level.
- ProcGenWorld wraps all world data under `"world"` key (mirroring Player's `"player"` key).
- Each entity (Player, ProcGenWorld, Town) responsible for its own serialization helpers.
- Symmetry enforced: anything in `get_save_data()` must be restored by `set_save_data()`.

## Breaking Change Notice
Existing `test_get_save_data()` in `test_proc_gen_world.gd` currently expects:
```gdscript
assert_eq(save_data["world_seed"], 12345, ...)
```

This must be updated to:
```gdscript
assert_eq(save_data.world.seed_value, 12345, ...)
```

Once the "world" hierarchy is implemented.

## Risks / Notes

- **Hierarchy Refactor**: Wrapping world data under `"world"` key is a breaking change to the existing `get_save_data()` return structure. The existing test `test_get_save_data()` must be updated to access `save_data.world.world_seed` instead of `save_data["world_seed"]`.
- **Town Identification**: Using `town_name` as key assumes uniqueness and stability. If names can change post-load, consider storing an ID instead.
- **Partial Persistence**: If some towns are loaded but others are not, the save/load cycle will only restore the persisted subset.
- **Inventory Complexity**: Each Town may have different goods based on `town_resource`, so inventory restore must only update stocks for goods that exist in the town's current resource definition.
- **Initialization Order**: Town `_ready()` initializes inventory with default stocks. `set_save_data()` must restore after this is called.
- **New Global Fields**: Adding `game_time` and `accumulation` to ProcGenWorld requires default values (0) so existing code paths don't break.
- **Backward Compatibility**: Old saves without `game_time`, `accumulation`, or `towns` keys must not crash; missing keys default to 0 or are skipped.

## Future Enhancements (Out of Scope)
- Migrating save format if `town_name` uniqueness is not guaranteed.
- Versioning the save format for future evolution.
- Pruning or regenerating towns that no longer exist.
