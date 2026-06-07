# Feature Prompt: Multi-Good Trading With OO Model

**Status**: In Progress (6 of ~20 tests completed)

## Progress Summary

### Completed (✅):
1. `TradingItem` class created with constructor
2. `TradingSystem.goods` dictionary populated with fish and grain
3. Player and Town use `TradingItem` for inventory
4. `get_price()` uses `GoodResource.base_price` and TradingItem
5. `buy()` method refactored to TradingItem-based API
6. `sell()` method refactored to TradingItem-based API

### Remaining:
- Price independence per good
- Capacity counting across all goods
- Safe handling of missing good IDs
- Cached stock and price updates
- Integration tests for multi-good scenarios

---

You are implementing a refactor in a Godot 4 project to support many goods in a clean object-oriented way.

## Context

Current code supports trading by string IDs (for example, `"fish"`) and mostly single-stock town logic.

Relevant existing files:
- `trading_system/trading_system.gd`
- `trading_system/good_resource.gd`
- `player/player.gd`
- `world/town.gd`
- `trading_system/good_fish.tres`

The project already has `GoodResource` and one concrete resource (`good_fish`).

## Goal

Refactor `TradingSystem`, `Player`, and `Town` to support **multiple goods** using `GoodResource` objects and a new `TradingItem` model.

## Required Design

1. Introduce a new class `TradingItem` used for inventories (player and town).
2. `TradingItem` must contain:
   - `good: GoodResource`
   - `amount: int`
   - `last_updated: float` (needed for delayed/cached price update logic)
   - `_stock: int` (internal actual stock)
   - `_cached_stock: int` (snapshot for delayed price calculations)
3. `TradingSystem` must contain an exported dictionary:
   - `@export var goods: Dictionary`
   - dictionary key = `GoodResource.id`
   - dictionary value = `GoodResource`
4. Remove dependence on hardcoded `"fish"` / `"grain"` value maps for core trading logic.
5. The API should be object-oriented around goods and trading items, but keep external method signatures stable where possible.

## Implementation Tasks

1. Create `trading_system/trading_item.gd`:
   - `class_name TradingItem`
   - extend `Resource` (preferred, so it can be serialized and edited if needed)
   - public fields: `good`, `amount`, `last_updated`, `stock`, `cached_stock` (accessible directly, no getters/setters needed)

2. Keep `trading_system/good_resource.gd` unchanged:
   - do not modify `GoodResource` fields or types
   - replace hardcoded string keys (`"fish"`, `"grain"`) with `GoodResource.id` driven lookups

3. Refactor `player/player.gd` inventory:
   - replace raw integer dictionary values with `TradingItem` values
   - keep cargo capacity checks working (`has_space`, `get_used_capacity`)
   - make lookups robust when an item key does not exist

4. Refactor `world/town.gd` stock model:
   - replace single `_stock` and `_cached_stock` scalar model with per-good `TradingItem` inventory
   - keep cached/delayed price update behavior using `last_updated`
   - preserve town enter signal behavior

5. Refactor `trading_system/trading_system.gd`:
   - replace hardcoded goods/base-price maps with `@export var goods: Dictionary`
   - update simulation to process each good per town (production/consumption)
   - update pricing to use `GoodResource.base_price`
   - update buy/sell to read/write `TradingItem.amount`
   - ensure missing keys fail safely (no crashes)
   - keep existing gameplay loop behavior (`_process`, simulation step, price update interval)

6. Ensure one-to-many good support works:
   - if new `GoodResource` files are added later, they should be registerable through `TradingSystem.goods`
   - no additional hardcoded good-specific code should be required

## Constraints

- Use typed GDScript where practical.
- Preserve current behavior as much as possible except where multi-good support requires structure changes.
- Avoid breaking scene wiring and public node interfaces.
- Keep code readable and explicit over clever shortcuts.

## Acceptance Criteria

1. Trading works for more than one good without hardcoded branches.
2. `TradingSystem.goods` is exported and maps id -> `GoodResource`.
3. Player inventory stores `TradingItem` per good.
4. Town stock stores `TradingItem` per good.
5. Price calculation uses `GoodResource.base_price` and delayed/cached update semantics.
6. Buy/sell, capacity, and gold updates still behave correctly.
7. Existing tests are updated (or new tests added) to cover at least two goods.

## Test-Driven Development Tests

### TradingItem Tests
- ✅ `test_trading_item_creation`: Create `TradingItem` with `good`, `amount`, `stock`, `cached_stock` initialized correctly

### TradingSystem Tests
- ✅ `test_goods_dictionary_populated`: `@export var goods` contains at least `fish` and `grain` with correct base prices
- ✅ `test_get_price_uses_good_base_price`: Price calculation uses `GoodResource.base_price`, not hardcoded strings (implemented as `test_price_in_habor_for_fish`)
- `test_price_varies_per_good`: Two different goods have independent price calculations based on their own stock

### Player Inventory Tests
- ✅ `test_player_inventory_stores_trading_items`: Player inventory uses `TradingItem` values (not raw ints) (verified in `test_town_initialized_with_goods`)
- `test_has_space_counts_total_items`: Capacity check sums amounts across all goods
- ✅ `test_buy_updates_trading_item_amount`: Buying updates `TradingItem.amount` for the correct good (implemented as `test_player_buys_fish_in_habor`)
- ✅ `test_sell_updates_trading_item_amount`: Selling updates `TradingItem.amount` for the correct good (implemented as `test_player_sells_fish_in_habor`)
- `test_inventory_safe_missing_good`: Accessing unknown good ID fails gracefully (no crash)

### Town Stock Tests
- ✅ `test_town_stock_uses_trading_items`: Town inventory uses `TradingItem` per good (not single `_stock`) (implemented as `test_town_initialized_with_goods`)
- `test_town_independent_goods_stock`: Two goods in one town have independent stock values
- `test_town_cached_stock_updates`: `update_cached_stock()` syncs `cached_stock` and updates `last_updated`
- `test_town_price_cache_delay`: Price remains cached until time interval expires, per good

### Integration Tests
- `test_buy_sell_two_goods_same_run`: Buy and sell `fish` and `grain` in same game session
- `test_stock_and_price_independent`: Changing one good's stock doesn't affect another's price
- `test_missing_good_id_safe`: Trading system handles unknown good IDs without crashes
- `test_simulation_processes_all_goods`: Simulation loop updates production/consumption for each good

## Notes for Migration

- Keep backward compatibility helpers where useful (for example wrappers) if UI still expects old methods.
- If changing `GoodResource.id` type, migrate existing resources accordingly.
- Ensure default data initialization so inventories are valid at runtime and in editor.
