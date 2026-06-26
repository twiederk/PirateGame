# Feature: Ship Ownership and Selection

## Feature Overview

This feature allows the player to own multiple ships and choose the active ship from the inventory screen.
Gameplay systems that currently use a single ship must switch to an active-ship model.

Core idea:
- Replace `Player._ship_resource` with `Player._ship_resources: Array[ShipResource]`.
- Add `Player._current_ship_index: int`.
- If `_ship_resources` is empty, the player owns no ship.

The selected active ship controls movement speed, ocean travel capability, promotion checks, and displayed ship info.

---

## MVP Scope

- Player can own multiple ships.
- Player can switch active ship from inventory.
- Town ship purchase adds a ship to ownership (not just equip one ship).
- Existing behavior remains stable for players with one ship.
- Save/load supports the new multi-ship model.
- Legacy saves with only one ship still load correctly.

Out of scope for this MVP:
- Selling ships
- Multiple copies of the same ship type
- Fleet mechanics

---

## UX Decision: Ship Selection in Inventory

### Proposed by you (recommended for MVP)

Show one button per owned ship in inventory. Clicking a button sets that ship active.

Why this is good now:
- Very clear and discoverable.
- Easy to implement and test.
- Fits small ship counts well.

### Simpler alternative

Use a single `OptionButton` (dropdown) for ship selection.

Why it can be simpler:
- Fewer dynamic UI nodes.
- Cleaner layout when many ships are owned.

Recommendation:
- Keep your button-per-ship approach for MVP.
- Revisit `OptionButton` only if ship counts become large enough to clutter inventory.

---

## Design Decisions

1. Data model
- `Player._ship_resources: Array[ShipResource] = []`
- `Player._current_ship_index: int = -1`
- Active ship is valid only when index is in range.

2. Ownership semantics
- `owns_ship()` returns `true` if `_ship_resources.size() > 0`.
- No ships means no ownership.

3. Active ship semantics
- Add active-ship accessors and selection API.
- Player cannot switch active ship while `ON_SHIP`.

4. Compatibility layer
- Keep `equip_ship(ship_resource)` and `get_ship()` during migration as wrappers.
- New code should use multi-ship APIs.

5. Save migration
- Read both old and new formats.
- Write new format by default.

6. Purchase and ownership policy (fixed)
- A ship type can be owned only once.
- Buying a ship always sets it as the active ship.

---

## API Migration Notes

Old to new mapping:
- `_ship_resource` -> `_ship_resources` + `_current_ship_index`
- `get_ship()` -> `get_active_ship()`
- `equip_ship(ship_resource)` -> `add_ship(ship_resource)` + `set_active_ship_by_index(index)`

New player API (target):
- `add_ship(ship_resource: ShipResource) -> bool`
- `get_ships() -> Array[ShipResource]`
- `get_active_ship() -> ShipResource`
- `get_active_ship_index() -> int`
- `set_active_ship_by_index(index: int) -> bool`
- `owns_ship() -> bool`

Temporary wrappers:
- `equip_ship(ship_resource)` remains callable and sets active ship.
- `get_ship()` remains callable and returns active ship.

---

## Implementation Plan

### Phase 1: Player Multi-Ship Core Model

Files:
- `player/player.gd`
- `test/test_player.gd`

Tasks:
1. Replace single ship field with array + active index.
2. Add new ownership/active ship methods.
3. Keep compatibility wrappers (`equip_ship`, `get_ship`).
4. Update movement ship lookup (`_move_on_ship`) to use active ship safely.
5. Ensure `board_ship()` no-ops when no active ship exists.

Acceptance criteria:
- Empty ship array means `owns_ship() == false`.
- First added ship becomes active.
- Active ship can be switched by index.
- No null access when trying to move on ship without active ship.

Regression risks:
- ON_SHIP transitions without active ship.
- Existing tests that assert private single-ship field.

---

### Phase 2: Town Purchase Flow Integration

Files:
- `gui/town_menu.gd`
- `test/test_town.gd` (or current town-related integration test location)

Tasks:
1. Replace direct equip in buy flow with multi-ship add/select behavior.
2. Enforce duplicate purchase rejection for already owned ship types.
3. Keep gold deduction logic correct.

Acceptance criteria:
- Buying ship adds ship to ownership.
- Buying ship always sets the purchased ship active.
- Buying an already owned ship type is rejected.
- Gold deduction remains correct.

Regression risks:
- Repeated purchase handling.
- Buy feedback messages.

---

### Phase 3: Inventory Ship Selection UI

Files:
- `gui/inventory_screen.tscn`
- `gui/inventory_screen.gd`
- `world/main.gd` (connection wiring if required by current architecture)

Tasks:
1. Replace single ship label output with dynamic list of ship buttons.
2. Add signal from inventory screen for ship selection, for example:
   - `signal active_ship_selected(index: int)`
3. On inventory render:
   - clear previous dynamic ship controls
   - create one button per owned ship
   - visually mark active ship
4. On click:
   - set active ship only when player is not `ON_SHIP`
   - refresh inventory view
6. If player is `ON_SHIP`, selection controls are disabled or hidden.
5. Show empty state text when no ships are owned.

Acceptance criteria:
- Exactly one button per owned ship is shown.
- Clicking a button switches active ship only when player is not `ON_SHIP`.
- While `ON_SHIP`, ship selection is not possible.
- Active ship marker updates correctly.
- Empty state is clear and stable.

Regression risks:
- Duplicate signal connections on repeated open/close.
- Stale UI nodes between refreshes.

---

### Phase 4: Promotion System Integration

Files:
- `promotion_system/promotion_system.gd`
- `test/test_promotion_system.gd`

Tasks:
1. Ensure promotion evaluation uses active ship accessor.
2. Keep no-ship behavior safe and deterministic.

Acceptance criteria:
- Sailer rank checks continue working with active ship model.
- No crashes with empty ship ownership.

Regression risks:
- Rank progression changes if active ship is switched.

---

### Phase 5: Save/Load Schema Migration

Files:
- `player/player_serializer.gd`
- `test/test_player_serializer.gd`
- `test/test_save_manager.gd`

Tasks:
1. New save fields (inside `player`):
   - `ships`: array of ship resource references
   - `current_ship_index`: integer
2. Backward read compatibility:
   - if new format exists, use it
   - else if old `ship` exists, migrate to one-element `ships`
   - else default to empty list + `-1`
3. Validate active index on load:
   - if invalid and ships exist, default to `0`
   - if no ships, force `-1`
4. If loaded state is `ON_SHIP` but no active ship exists, safely force `ON_LAND`.

Acceptance criteria:
- New saves round-trip correctly.
- Old single-ship saves still load.
- Invalid indices do not crash and are corrected.

Regression risks:
- Corrupt save data edge cases.
- State mismatches after load.

---

### Phase 6: Migration Cleanup

Files:
- `player/player.gd`
- `gui/town_menu.gd`
- `gui/inventory_screen.gd`
- `promotion_system/promotion_system.gd`
- related tests

Tasks:
1. Move all call sites to new multi-ship APIs.
2. Keep wrappers until all code paths are migrated and stable.
3. Document deprecation/removal plan for wrappers.

Acceptance criteria:
- Core code paths use new APIs consistently.
- Compatibility wrappers still pass legacy-oriented tests.

---

## Save Format Proposal

New player save fragment:

```json
{
  "player": {
    "ships": [
      { "resource_path": "res://trading_system/ship_boat.tres" },
      { "resource_path": "res://trading_system/ship_sailing.tres" }
    ],
    "current_ship_index": 1
  }
}
```

Backward read support:
- Accept old `player.ship.resource_path` format and migrate in memory to the new structure.

---

## Test Plan (GUT, TDD Backlog)

### Player tests
- `test_player_starts_with_empty_ship_list`
- `test_player_starts_with_current_ship_index_minus_one`
- `test_owns_ship_false_when_ship_list_is_empty`
- `test_add_ship_adds_ship_to_list`
- `test_add_ship_sets_first_ship_as_active`
- `test_set_active_ship_by_index_updates_active_ship`
- `test_set_active_ship_by_index_rejects_invalid_index`
- `test_get_active_ship_returns_null_when_no_ship`
- `test_get_ship_wrapper_returns_active_ship`
- `test_equip_ship_wrapper_adds_or_activates_ship`
- `test_move_on_ship_uses_active_ship_speed`
- `test_board_ship_noop_when_no_active_ship`

### Town/inventory integration tests
- `test_buy_ship_adds_ship_to_owned_list`
- `test_buy_ship_updates_active_ship_on_success`
- `test_buy_ship_deducts_gold_once`
- `test_buy_ship_rejects_already_owned_ship_type`
- `test_inventory_renders_button_per_owned_ship`
- `test_inventory_switch_button_changes_active_ship`
- `test_inventory_switch_blocked_while_on_ship`
- `test_inventory_marks_active_ship`
- `test_inventory_shows_empty_state_without_ships`

### Promotion tests
- `test_promotion_uses_active_ship`
- `test_promotion_handles_no_active_ship`

### Serializer/save tests
- `test_serializer_writes_ships_array`
- `test_serializer_writes_current_ship_index`
- `test_serializer_reads_new_format`
- `test_serializer_migrates_old_single_ship_format`
- `test_serializer_corrects_invalid_ship_index`
- `test_load_forces_on_land_if_no_active_ship`

---

## Open Question

1. UI container choice:
- For future scalability, should we already use a `ScrollContainer` for the ship button list?

---

## Execution Notes

- Implement in small TDD increments.
- Prefer compatibility wrappers first, then migrate call sites.
- Keep changes deterministic and idempotent for save/load and promotion behavior.