# Feature: Ship Resource System

## Description

This feature introduces a **ShipResource** system to manage player ships with standardized properties and resource-based management. Instead of a simple boolean `has_ship` flag, the player will have a `ship_resource` property that holds a reference to a ShipResource. This allows for extensible ship properties (id, name, price, speed, texture) and easier future additions of ship variants.

### Key Changes

1. **New ShipResource Class**: A Godot Resource class with standardized ship properties
2. **Ship Resource Instances**: Two predefined ships (boat and sailing ship)
3. **Player Updates**:
   - Replace `has_ship: bool` property with `has_ship()` function
   - Add `ship_resource: ShipResource` property (initially null)
   - Update sprite texture when ship is acquired

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

1. **Remove** the `has_ship: bool = false` property
2. **Add** `ship_resource: ShipResource = null` property
3. **Add** `has_ship() -> bool` function that returns `ship_resource != null`
4. **Update** `board_ship()` to use `has_ship()` instead of `has_ship`
5. **Add** `set_ship(ship: ShipResource) -> void` function:
   - Set `ship_resource = ship`
   - Update `ship_sprite.texture` to `ship.texture`
   - Update player speed: `SPEED = ship.speed`
6. **Update** any other code that references `has_ship` as a property

### Phase 4: Update Dependent Code

Identify and update all code that:
- Checks `player.has_ship` (now call `player.has_ship()`)
- Sets `player.has_ship = true` (now call `player.set_ship(ship_resource)`)
- Accesses ship properties (use `player.ship_resource.property`)

Expected locations:
- Trading system / shop purchase logic
- Game initialization (if ships are pre-assigned)
- Debug/admin screens

---

## Test List

Tests organized by GUT convention. File: `test/test_ship_resource.gd`

### ShipResource Class Tests

```gdscript
test_ship_resource_has_id_property()
test_ship_resource_has_name_property()
test_ship_resource_has_price_property()
test_ship_resource_has_speed_property()
test_ship_resource_has_texture_property()
```

### Ship Instance Tests

```gdscript
test_ship_boat_instance_loads_correctly()
test_ship_boat_has_correct_id()
test_ship_boat_has_correct_name()
test_ship_boat_has_correct_price()
test_ship_boat_has_correct_speed()
test_ship_boat_has_correct_texture_path()

test_ship_sailing_instance_loads_correctly()
test_ship_sailing_has_correct_id()
test_ship_sailing_has_correct_name()
test_ship_sailing_has_correct_price()
test_ship_sailing_has_correct_speed()
test_ship_sailing_has_correct_texture_path()
```

### Player Integration Tests (extend test_player.gd)

```gdscript
test_player_ship_resource_initialized_as_null()
test_player_has_ship_returns_false_when_no_ship()
test_player_has_ship_returns_true_when_ship_assigned()

test_player_set_ship_assigns_ship_resource()
test_player_set_ship_updates_sprite_texture()
test_player_set_ship_updates_speed()

test_player_can_board_ship_when_has_ship()
test_player_cannot_board_ship_when_no_ship()

test_player_set_ship_with_boat_updates_to_boat_texture()
test_player_set_ship_with_sailing_updates_to_sailing_texture()

test_player_set_ship_boat_sets_correct_speed()
test_player_set_ship_sailing_sets_correct_speed()
```

### Edge Cases & Robustness

```gdscript
test_player_set_ship_null_clears_ship_resource()
test_player_has_ship_returns_false_after_ship_cleared()
test_player_multiple_set_ship_calls_overwrite_previous()

test_ship_resource_instances_are_unique()
test_ship_boat_and_sailing_have_different_ids()
```

---

## Dependencies

- GUT testing framework (already in project)
- Godot 4.x Resource system
- Player class modifications

## Notes

- Tests should use `autofree()` for automatic memory cleanup
- Use `before_each()` to load ship resources
- Test both the resource instances loading AND their properties
- Verify sprite texture assignment works with Sprite2D node
- Consider testing `board_ship()` behavior after ship is assigned

