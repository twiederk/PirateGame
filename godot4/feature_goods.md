# Feature Prompt: Multi-Good Trading With OO Model

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
   - exported fields: `good`, `amount`, `last_updated`
   - helper methods if useful (for example increase/decrease amount with clamping)

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

## Suggested Tests

- Buy and sell `fish` and a second good (for example `grain`) in one run.
- Verify independent stock and pricing per good.
- Verify price cache delay (`last_updated`) affects each good correctly.
- Verify capacity checks use total amounts across all goods.
- Verify behavior when a good ID is unknown.

## Notes for Migration

- Keep backward compatibility helpers where useful (for example wrappers) if UI still expects old methods.
- If changing `GoodResource.id` type, migrate existing resources accordingly.
- Ensure default data initialization so inventories are valid at runtime and in editor.
