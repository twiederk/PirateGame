# Feature: Ship Animation System

## Overview
Add animated sprite sheet support for the boat/ship in the PirateGame. Currently, the boat uses a static sprite and has no animations. The person already has a full animation system with AnimationPlayer and AnimationTree.

## Problem Statement
The player can toggle between person and boat representations. The person has:
- Sprite sheet with 9 rows × 4 columns (idle, walk, chop animations in 4 directions)
- AnimationPlayer with 13 animations (idle_*, walk_*, chop_*)
- AnimationTree with state machine (idle ↔ walk ↔ chop transitions)

The boat currently:
- Uses a static PNG sprite (no sprite sheet)
- Has no animations
- Cannot reuse the person's AnimationTree due to different animation requirements

## Proposed Solution: Option A - Independent AnimationPlayers

### Architecture

Create separate animation infrastructure for the boat that mirrors the person's setup:

```
Player (CharacterBody2D)
├── WandererSprite2D (person sprite)
│   └── [AnimationPlayer + AnimationTree for person]
├── ShipSprite2D (boat sprite)
│   └── [NEW] AnimationBoat + AnimationTreeBoat for boat
└── CollisionShape2D
```

### Scene Structure Changes

Add two new nodes to the Player scene:

1. **AnimationBoat** (AnimationPlayer)
   - Contains boat animation library
   - Targets ShipSprite2D frame_coords
   - Similar animations to person (idle_down, idle_up, walk_down, etc.)

2. **AnimationTreeBoat** (AnimationTree)
   - References AnimationBoat as its anim_player
   - Uses identical state machine structure (idle ↔ walk ↔ chop)
   - Allows boat to respond to same animation conditions

### Implementation Strategy

#### Step 1: Create Boat Sprite Sheet
Prepare a boat sprite sheet matching the person's structure:
- 4 columns (4 directions or variations)
- 9 rows (to match person animations: idle, walk, chop in each direction)
- Frame size and timing consistent with person animations

#### Step 2: Add AnimationBoat to Scene
- Create AnimationPlayer node named "AnimationBoat"
- Create AnimationLibrary with boat-specific animations
- Use same animation names as person (idle_down, idle_up, walk_left, etc.) for consistency
- Target all tracks to `ShipSprite2D:frame_coords`

#### Step 3: Add AnimationTreeBoat to Scene
- Create AnimationTree node named "AnimationTreeBoat"
- Reference AnimationBoat as its anim_player
- Copy state machine structure from AnimationTree (person)
- Set to inactive by default (active = false)

#### Step 4: Update player.gd Script

```gdscript
# Add reference to boat animation system
@onready var animation_player_boat: AnimationPlayer = $AnimationBoat
@onready var animation_tree_boat = $AnimationTreeBoat

# In _ready()
func _ready():
	animation_tree.active = true
	animation_tree_boat.active = false  # Inactive until boarding

# Update board_ship() to toggle animation systems
func board_ship() -> void:
	if not has_ship:
		return
	
	wanderer_sprite.visible = !wanderer_sprite.visible
	ship_sprite.visible = !ship_sprite.visible
	
	# Toggle animation systems
	animation_tree.active = !animation_tree.active
	animation_tree_boat.active = !animation_tree_boat.active
	
	if current_state == STATE.ON_LAND:
		set_collision_mask_value(2, false)
		set_collision_mask_value(3, true)
		current_state = STATE.ON_SHIP
	else:
		set_collision_mask_value(2, true)
		set_collision_mask_value(3, false)
		current_state = STATE.ON_LAND

# Update animation logic to target active tree
func _update_animation_parameters():
	# Determine which tree is active
	var active_tree = animation_tree if animation_tree.active else animation_tree_boat
	
	if velocity == Vector2.ZERO:
		active_tree["parameters/conditions/is_idle"] = true
		active_tree["parameters/conditions/is_moving"] = false
	else:
		active_tree["parameters/conditions/is_chopping"] = false
		active_tree["parameters/conditions/is_idle"] = false
		active_tree["parameters/conditions/is_moving"] = true

	if direction != Vector2.ZERO:
		active_tree["parameters/idle/blend_position"] = direction
		active_tree["parameters/walk/blend_position"] = direction
```

### Advantages

✅ **Safe Architecture**
- No dynamic reference switching
- Each animation system is self-contained
- Lower risk of edge-case bugs

✅ **Maintenance**
- Clear separation of concerns
- Easy to add boat-specific animations later
- Each sprite sheet can evolve independently

✅ **Reusability**
- Animation state conditions (is_idle, is_moving, is_chopping) remain consistent
- Same script logic updates both trees
- Future characters can follow same pattern

✅ **Extensibility**
- Can add special boat animations (raising sails, anchoring, etc.)
- Can animate different boat types with different trees
- Frame timing can differ per sprite if needed

### Disadvantages

⚠️ **Slightly More Nodes**
- Adds 2 nodes (AnimationBoat, AnimationTreeBoat)
- Minor scene complexity increase
- Negligible performance impact

⚠️ **Animation Library Duplication**
- Must maintain boat animation names matching person animations
- Both libraries need same structure
- Requires attention during animation updates

### Timeline & Effort

| Phase | Effort | Notes |
|-------|--------|-------|
| Create boat sprite sheet | Medium | Most time-consuming |
| Add AnimationBoat to scene | Low | 15 min |
| Add AnimationTreeBoat to scene | Low | 15 min |
| Copy animation library | Medium | ~20 animations |
| Update player.gd script | Low | ~10 min |
| Test and debug | Low-Medium | Verify animation transitions |

### Testing Checklist

- [ ] Board ship → animations switch correctly
- [ ] Leave ship → animations switch back
- [ ] All directions work (up, down, left, right)
- [ ] Idle animations play smoothly
- [ ] Walk animations blend correctly
- [ ] No animation stuttering when switching
- [ ] Performance is acceptable (2 trees active)

### Future Enhancements

1. **Boat-Specific Animations**
   - Add anchoring animation
   - Add sail-raising animation
   - Add docking animation

2. **Animation Variants**
   - Different boat types with different animations
   - Damaged boat animations
   - Cargo-loaded boat variations

3. **Reusable Pattern**
   - Apply same pattern to other switchable characters
   - Create animation system template for future additions

## Conclusion

Option A provides a clean, maintainable solution that leverages Godot's strength in scene composition. While it adds a few nodes, the architectural clarity and reduced risk make it the recommended approach for this feature.
