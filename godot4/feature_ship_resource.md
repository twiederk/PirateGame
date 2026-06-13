# Feature: Ship Resource System

## Description

This feature introduces a **ShipResource** system to manage player ships with standardized properties and resource-based management. Instead of a simple boolean `has_ship` flag, the player will have a `ship_resource` property that holds a reference to a ShipResource. This allows for extensible ship properties (id, name, price, speed, texture) and easier future additions of ship variants.

### Key Changes

1. **New ShipResource Class**: A Godot Resource class with standardized ship properties
2. **Ship Resource Instances**: Two predefined ships (boat and sailing ship)
3. **Player Updates**:
   - Remove legacy `has_ship`/`_has_ship` property and use `owns_ship()`
   - Add `ship_resource: ShipResource` property (initially null)
   - Update sprite texture when ship is acquired
   - Rename `equip_ship_by_name(ship_name: String)` to `equip_ship(ship: ShipResource)`

### Goals

- Make ship data manageable and extensible
- Decouple ship properties from hardcoded values
- Enable future ship variants without code changes
- Maintain backward compatibility with existing player mechanics

---

## Implementation Plan

### Phase 1: Create ShipResource Class

**File**: `trading_system/ship_resource.gd`

Create a new Resource class with the following structure:
- Extend `Resource`
- Properties: `id`, `name`, `price`, `speed`, `texture`
- Optional: metadata handling for future ship types

**Implementation Steps**:
1. Create the GDScript class file
2. Define all properties with type hints
3. Add getter methods if needed for validation

### Phase 2: Create Ship Resource Instances

**Files**: 
- `trading_system/ship_boat.tres`
- `trading_system/ship_sailing.tres`

Create two resource instances with the specified properties:

**ship_boat.tres**:
```
id: 1
name: Ruderboot
price: 150
speed: 50
texture: res://player/boat_spritesheet.png
```

**ship_sailing.tres**:
```
id: 2
name: Segelboot
price: 500
speed: 150
texture: res://player/ship_spritesheet.png
```

### Phase 3: Update Player Class

**File**: `player/player.gd`

Make the following changes:

1. **Remove** any `has_ship` / `_has_ship` property
2. **Add** `ship_resource: ShipResource = null` property
3. **Keep/Add** `owns_ship() -> bool` function that returns `ship_resource != null`
4. **Update** `board_ship()` to use `owns_ship()`
5. **Rename** `equip_ship_by_name(ship_name: String)` to `equip_ship(ship: ShipResource)` and implement:
   - Set `ship_resource = ship`
   - Update `ship_sprite.texture` to the ship texture reference/path
   - Update player speed: `SPEED = ship.speed`
6. **Update** any call sites to use the new function signature

### Phase 4: Update Dependent Code

Identify and update all code that:
- Checks ship ownership using `player.owns_ship()`
- Calls `player.equip_ship_by_name(...)` (now call `player.equip_ship(ship_resource)`)
- Accesses ship properties (use `player.ship_resource.property`)

Expected locations:
- Trading system / shop purchase logic
- Game initialization (if ships are pre-assigned)
- Debug/admin screens

---

## Test List

Tests organized by GUT convention. File: `test/test_ship_resource.gd`


### Player Integration Tests (extend test_player.gd)

```gdscript
test_player_ship_resource_initialized_as_null()
test_player_owns_ship_returns_false_when_no_ship()
test_player_owns_ship_returns_true_when_ship_assigned()

test_player_equip_ship_assigns_ship_resource()
test_player_equip_ship_updates_sprite_texture()
test_player_equip_ship_updates_speed()

test_player_can_board_ship_when_has_ship()
test_player_cannot_board_ship_when_no_ship()

```

### Edge Cases & Robustness

```gdscript
test_player_multiple_set_ship_calls_overwrite_previous()
```

---

## Dependencies

- GUT testing framework (already in project)
- Godot 4.x Resource system
- Player class modifications
