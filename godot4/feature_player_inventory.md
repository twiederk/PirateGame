# Feature Plan: Persist Player Inventory and Current State

## Goal
Extend player save/load so that `get_save_data()` and `set_save_data()` stay in sync while persisting:
- `_inventory`
- `current_state`

All validation must be done in `test/test_player.gd`.

## Current Baseline
`player/player.gd` currently persists:
- `gold`
- `position`
- optional `ship.resource_path`

`test/test_player.gd` currently verifies:
- save data includes `gold` and `position`
- no tests yet for inventory persistence or state persistence

## Target Save Contract
Add these fields under `save_data.player`:
- `current_state`: integer enum value from `Player.STATE`
- `inventory`: dictionary keyed by `good_id`, value object:
  - `good_resource_path`
  - `stock`

Example shape:

```gdscript
{
	"player": {
		"gold": 321,
		"position": {"x": 17.0, "y": 29.0},
		"current_state": 0,
		"inventory": {
			"1": {
				"good_resource_path": "res://trading_system/good_fish.tres",
				"stock": 4
			},
			"2": {
				"good_resource_path": "res://trading_system/good_grain.tres",
				"stock": 7
			}
		},
		"ship": {"resource_path": "res://trading_system/ship_boat.tres"}
	}
}
```

Note: String keys in persisted dictionaries are safer for JSON-style serialization.

## Implementation Steps
1. Add tests in `test/test_player.gd` for `get_save_data()`:
- verifies `player.current_state` is present and correct
- verifies inventory entries exist for expected goods
- verifies each entry has `good_resource_path` and `stock`

2. Add tests in `test/test_player.gd` for `set_save_data()`:
- loading save data restores `current_state`
- loading save data restores inventory stock values
- loading save data keeps existing behavior for `gold`, `position`, and optional `ship`

3. Update `player/player.gd` `get_save_data()`:
- include `save_data.player.current_state = current_state`
- serialize `_inventory` into a plain dictionary payload suitable for persistence

4. Update `player/player.gd` `set_save_data()`:
- restore `current_state` from save data
- rebuild `_inventory` using `TradingItem.new(load(good_resource_path))`
- assign restored `stock` per item

5. Backward compatibility in `set_save_data()`:
- if `current_state` missing, default to `STATE.ON_LAND`
- if `inventory` missing, keep current default `_inventory`
- keep existing optional ship handling

6. Keep methods synchronized:
- any field written by `get_save_data()` must be read by `set_save_data()`
- tests should fail if save/load keys diverge

## TDD Sequence (Required)
1. Red: add one failing test for `current_state` in save data.
2. Green: minimal change in `get_save_data()` to pass.
3. Refactor: cleanup naming/duplication.
4. Red: add failing inventory save test.
5. Green: minimal inventory serialization.
6. Refactor.
7. Red: add failing load test for `current_state`.
8. Green: minimal restore logic.
9. Refactor.
10. Red: add failing inventory restore test.
11. Green: minimal inventory rebuild logic.
12. Refactor.
13. Add backward-compat tests for missing keys and implement defaults.

## Test Cases To Add
- `test_get_save_data_includes_current_state`
- `test_get_save_data_includes_inventory_with_resource_path_and_stock`
- `test_set_save_data_restores_current_state`
- `test_set_save_data_restores_inventory_stock`
- `test_set_save_data_without_current_state_defaults_to_on_land`
- `test_set_save_data_without_inventory_keeps_default_inventory`

## Risks / Notes
- Inventory keys may be numeric in memory and string in serialized data; normalize during load.
- `current_state` controls movement mode, so future enhancement may need a dedicated post-load state-application method if visual/collision toggles must be restored immediately.
- Keep save format simple and explicit to avoid hidden coupling.
