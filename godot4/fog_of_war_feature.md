# Feature Plan: Fog of War System

## Feature Overview
**Feature Name:** Fog of War (Minimap Sectors)  
**Goal:** Hide unvisited portions of the minimap by dividing it into 16x16 tile sectors that become revealed when the player enters them.

---

## Initial Requirements (from user)

- Minimap dimensions: multiples of 16 (width and height)
- **Fog Sector**: 16x16 tile area
- **Visited Condition**: Player position is inside a fog sector
- **Unvisited Behavior**: Minimap displays as black in that sector area
- **Implementation Constraint**: Minimize signal emissions from position changes

### Implementation Approach (options to evaluate):
1. **Positional check on player move** – check sector on every position update (signal heavy)
2. **Area2D-based detection** – one Area2D per sector, use `body_entered` signal to mark visited (cleaner)
3. **Hybrid or alternative approach** – open to suggestions

---

## Clarifying Questions

Before finalizing the implementation plan, I need answers to:

### 1. Minimap Rendering & Integration
- [ ] How is the minimap currently rendered? (e.g., CanvasLayer, TextureRect, custom shader, TileMaps)
The minimpa is created a image in ProcGenWorld.generate_minimap. In the minimap scene the image is turned into a Testure for a TextureRect.
- [ ] Is there a `Minimap` scene/class? If so, what file?
Yes, there is a minimap scene. See world/minimap.tscn
- [ ] What is the current minimap viewport size in pixels? Tiles?
The minimap contains one pixel per tile, which is based on width and height of ProcGenWorld, this results in width: 256 and height 192.

### 2. Player Position Update Mechanism
- [ ] How frequently does the player position update? (every frame, discrete moves, or continuous)
The player position can update every frame.
- [ ] Is there a signal emitted when player position changes? If yes, which one?
Not won.
- [ ] Is the player position an `Area2D`, `CharacterBody2D`, or other node type?
The player is a CharacterBody2D

### 3. Fog Sector Persistence & State
- [ ] Should revealed fog sectors **stay revealed forever**, or should they revert to fog over time (memory decay)?
The fog sectors stay revealed
- [ ] Should fog sector visited state be **saved and loaded** (persistent across game sessions)?
Yes, the fog sector visited state needs to be saved and loaded
- [ ] If saved, what file/system should store this state? (existing SaveManager? New serializer?)
The ProcWorldGenSerializer stores this state.

### 4. Visual Representation
- [ ] Should unvisited sectors appear **pure black**, semi-transparent **overlay**, or **gradient** blend?
pure black
- [ ] Should there be a **transition/animation** when fog is revealed?
No

### 5. Gameplay Scope
- [ ] Does fog of war affect **only the minimap display**, or does it also gate gameplay mechanics (e.g., can't navigate to unseen areas)?
Only the minimap display

- [ ] Do **enemies or NPCs** also reveal fog when they enter sectors, or only the player?
No, only the player reveals the fog

### 6. World & Performance
- [ ] What is the approximate minimap size in tiles? (e.g., 1024×1024, 2048×2048)
The size of the minimap is 256x192. Each pixel representing a tile of 16 pixels.
- [ ] How many fog sectors will this create? (we can calculate: sectors = (width/16) × (height/16))
This will create (256/16) x (192/16) = 192 fog sectory
- [ ] Are there performance concerns for creating one Area2D per sector?
No

### 7. Edge Cases & Behavior
- [ ] What happens at world boundaries or off-map areas? Should those sectors be pre-marked visited or handled specially?
No special handling there.
- [ ] Should the player start with the starting sector already revealed, or start in fog?
Yes the starting sector will already be revealed.

---

## Implementation Plan

### Phase 1: Fog Sector System Core
**File**: `world/fog_sector_manager.gd` *(new file)*

**Purpose**: Centralized class to manage fog sector state, visited tracking, and sector calculations.

**Class Definition**:
```gdscript
class_name FogSectorManager
extends Node

# Configuration
const SECTOR_SIZE: int = 16  # pixels (tiles) per sector side

# State
var visited_sectors: Array[bool] = []  # Flat array of visited states
var sector_width: int = 0
var sector_height: int = 0
var world_width: int = 0
var world_height: int = 0
```

**Methods to implement**:

1. **`_init(world_width: int, world_height: int) -> void`**
   - Initialize grid dimensions
   - Calculate sector_width = world_width / SECTOR_SIZE (should be 16 for 256px)
   - Calculate sector_height = world_height / SECTOR_SIZE (should be 12 for 192px)
   - Initialize visited_sectors as empty bool array of size (sector_width * sector_height)
   - All values start as `false` (unvisited)

2. **`get_sector_at_world_position(world_pos: Vector2) -> int`**
   - Convert world position (in pixels) to sector index
   - Return flat index: `(sector_x * sector_height) + sector_y`
   - Handle edge cases: clamp to valid range or return -1 if out of bounds

3. **`get_sector_position_from_index(sector_index: int) -> Vector2i`**
   - Reverse of above: convert flat index back to sector coordinates
   - Return as Vector2i(sector_x, sector_y)

4. **`mark_sector_visited(sector_index: int) -> void`**
   - Set `visited_sectors[sector_index] = true`
   - Validate index is in valid range
   - No effect if already visited (idempotent)

5. **`is_sector_visited(sector_index: int) -> bool`**
   - Return `visited_sectors[sector_index]`
   - Handle invalid indices by returning `false`

6. **`get_visited_sectors() -> Array[bool]`**
   - Return copy of visited_sectors array for serialization
   - Used by ProcGenWorldSerializer

7. **`set_visited_sectors(sectors: Array[bool]) -> void`**
   - Restore visited_sectors from save data
   - Used by ProcGenWorldSerializer during load

8. **`mark_starting_sector_visited(player_start_pos: Vector2) -> void`**
   - Called during initialization
   - Convert player_start_pos to sector index
   - Mark that sector as visited

9. **`get_sector_index(sector_x: int, sector_y: int) -> int`**
   - Helper to convert 2D coords to flat index
   - Return `(sector_x * sector_height) + sector_y`
   - Validate bounds

---

### Phase 2: ProcGenWorld Integration (Area2D Sector Detection)
**File**: `world/proc_gen_world.gd` *(modifications)*

**Purpose**: Create Area2D nodes for each sector, enable body_entered signal detection.

**New properties**:
```gdscript
var fog_sector_manager: FogSectorManager
var fog_sectors_container: Node2D  # Parent node for all Area2D sectors
var _sector_area2d_map: Dictionary = {}  # Maps sector_index → Area2D reference
```

**New method: `_setup_fog_sectors() -> void`**
- Called during world initialization (likely in `_ready()` or after world generation)
- Initialize FogSectorManager: `fog_sector_manager = FogSectorManager.new(width, height)`
- Create fog_sectors_container: `fog_sectors_container = Node2D.new()` with name "FogSectors"
- Add to scene: `add_child(fog_sectors_container)`
- **Loop through all sectors** (0 to (16×12)-1):
  - Create Area2D node with name "FogSector_{sector_index}"
  - Create CollisionShape2D child with RectangleShape2D
  - Calculate sector position: `sector_x = index % sector_width`, `sector_y = index // sector_width`
  - Position Area2D at world coords: `(sector_x * 256, sector_y * 256)` (where 256 = SECTOR_SIZE * 16 world pixels)
  - Set collision shape size to `Vector2(256, 256)` (16 tiles × 16 pixels/tile)
  - Store reference: `_sector_area2d_map[sector_index] = area2d`
  - Connect signal: `area2d.body_entered.connect(_on_fog_sector_entered.bind(sector_index))`
  - Add to container: `fog_sectors_container.add_child(area2d)`

**New signal handler: `_on_fog_sector_entered(body: Node2D, sector_index: int) -> void`**
- Check if body is the player (compare by node reference or type check)
- If player: `fog_sector_manager.mark_sector_visited(sector_index)`
- Could emit custom signal here for minimap update if needed

**Modify existing `func _ready()` or similar**:
- Call `_setup_fog_sectors()` after world generation completes
- Ensure this is called BEFORE player enters world
- Mark starting sector as visited: `fog_sector_manager.mark_starting_sector_visited(player_start_pos)`

---

### Phase 3: Minimap Integration (Visual Rendering)
**File**: `world/proc_gen_world.gd` *(modifications to generate_minimap)*

**Modify method: `func generate_minimap() -> Image:`**
- Current implementation creates full world minimap
- **After rendering world/towns**, overlay fog of war:
  - Get visited_sectors array from fog_sector_manager
  - Loop through all sectors
  - For each unvisited sector:
    - Calculate minimap pixel range: 
      - `min_x = sector_x * SECTOR_SIZE` (16 pixels)
      - `max_x = min_x + SECTOR_SIZE`
      - `min_y = sector_y * SECTOR_SIZE`
      - `max_y = min_y + SECTOR_SIZE`
    - Set all pixels in that range to `Color.BLACK`

**Expected minimap render order**:
1. Draw world tiles (water, sand, grass, etc.) — existing code
2. Draw towns — existing code
3. **Overlay fog sectors** (new) — unvisited sectors as pure black

**Code structure**:
```gdscript
func generate_minimap() -> Image:
    var minimap: Image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
    minimap.fill(Color.BLACK)
    _draw_world(minimap)
    _draw_towns(minimap)
    # NEW: Apply fog of war
    if fog_sector_manager:
        _apply_fog_of_war_overlay(minimap)
    return minimap

func _apply_fog_of_war_overlay(minimap: Image) -> void:
    var visited_sectors = fog_sector_manager.get_visited_sectors()
    for sector_index in range(visited_sectors.size()):
        if not visited_sectors[sector_index]:
            var pos = fog_sector_manager.get_sector_position_from_index(sector_index)
            _draw_fog_sector(minimap, pos.x, pos.y)

func _draw_fog_sector(minimap: Image, sector_x: int, sector_y: int) -> void:
    var min_x = sector_x * FogSectorManager.SECTOR_SIZE
    var max_x = min_x + FogSectorManager.SECTOR_SIZE
    var min_y = sector_y * FogSectorManager.SECTOR_SIZE
    var max_y = min_y + FogSectorManager.SECTOR_SIZE
    
    for x in range(min_x, max_x):
        for y in range(min_y, max_y):
            if _is_in_minimap_bounds(minimap, Vector2i(x, y)):
                minimap.set_pixelv(Vector2i(x, y), Color.BLACK)
```

---

### Phase 4: Save/Load Persistence
**File**: `world/proc_gen_world_serializer.gd` *(modifications)*

**Modify method: `func get_save_data(proc_gen_world: ProcGenWorld) -> Dictionary:`**
- Add fog sector data to world_data dictionary
- New structure:
  ```gdscript
  world_data = {
      "seed_value": proc_gen_world.seed_value,
      "spawn_accumulator": proc_gen_world.spawn_accumulator,
      "visited_sectors": proc_gen_world.fog_sector_manager.get_visited_sectors(),  # NEW
      "towns": [...],
      "goods": [...]
  }
  ```

**Modify method: `func set_save_data(proc_gen_world: ProcGenWorld, save_data: Dictionary) -> void:`**
- After restoring other data, restore fog sectors:
  ```gdscript
  func _restore_world(proc_gen_world: ProcGenWorld, world_data: Dictionary) -> void:
      if world_data.has("spawn_accumulator"):
          proc_gen_world.spawn_accumulator = world_data.spawn_accumulator
      
      # NEW: Restore fog sectors
      if world_data.has("visited_sectors"):
          if proc_gen_world.fog_sector_manager:
              proc_gen_world.fog_sector_manager.set_visited_sectors(world_data.visited_sectors)
  ```

---

### Phase 5: Main.gd Integration
**File**: `world/main.gd` *(modifications)*

**In `func _ready():`** — Add fog sector initialization:

```gdscript
func _ready() -> void:
    PauseManager.clear_all()
    var world_seed = _get_seed()
    proc_gen_world.generate_world(world_seed)
    towns = proc_gen_world.generate_towns()
    _setup_limits_and_borders()
    
    # NEW: Initialize fog sectors BEFORE loading save data
    proc_gen_world._setup_fog_sectors()
    
    debug_screen.set_seed(proc_gen_world.seed_value)
    zoom_widget.set_zoom(camera.zoom)
    
    if SaveManager.is_game_loaded():
        PlayerSerializer.new().set_save_data(player, SaveManager.load_game_state)
        ProcGenWorldSerializer.new().set_save_data(proc_gen_world, SaveManager.load_game_state)
        TradingSystemSerializer.new().set_save_data(trading_system, SaveManager.load_game_state)
        # Fog sectors are now restored from save data above
    else:
        proc_gen_world.generate_goods()
        proc_gen_world.generate_raiders()
        player.position = proc_gen_world.get_starting_position()
        player.gold = 100
        # NEW: Mark starting sector as visited
        proc_gen_world.fog_sector_manager.mark_starting_sector_visited(player.position)
    
    _connect_signals()
    _setup_minimap()
```

**In `func _setup_minimap():`** — Add minimap fog update:

```gdscript
func _setup_minimap() -> void:
    # Existing minimap setup code
    var minimap_image = proc_gen_world.generate_minimap()
    minimap.set_image(minimap_image)
```

---

### Phase 6: Testing (TDD)

**Test File**: `test/test_fog_sector_manager.gd` *(new file)*

**Test List** (in execution order, simple → complex):

#### Group 1: Initialization
```gdscript
it.todo("FogSectorManager should initialize with correct grid dimensions")
it.todo("FogSectorManager should create visited_sectors array with all false values")
it.todo("FogSectorManager should calculate sector_width = 16 for 256px world width")
it.todo("FogSectorManager should calculate sector_height = 12 for 192px world height")
```

#### Group 2: Sector Index Calculation
```gdscript
it.todo("get_sector_at_world_position should return correct sector index for tile (0,0)")
it.todo("get_sector_at_world_position should return correct sector index for tile (128,96)")
it.todo("get_sector_at_world_position should return correct sector index for tile (240,180)")
it.todo("get_sector_at_world_position should clamp out-of-bounds positions to valid range")
it.todo("get_sector_position_from_index should reverse calculation correctly")
```

#### Group 3: Visited State Tracking
```gdscript
it.todo("mark_sector_visited should set sector to true")
it.todo("is_sector_visited should return false for unvisited sector")
it.todo("is_sector_visited should return true for visited sector")
it.todo("mark_sector_visited should be idempotent (marking twice has same effect)")
it.todo("mark_sector_visited should handle edge sectors correctly")
```

#### Group 4: Batch Operations
```gdscript
it.todo("get_visited_sectors should return current state array")
it.todo("set_visited_sectors should restore array from save data")
it.todo("set_visited_sectors should not affect other state")
```

#### Group 5: Starting Sector
```gdscript
it.todo("mark_starting_sector_visited should mark player start sector as visited")
it.todo("mark_starting_sector_visited should work with positions near world origin")
it.todo("mark_starting_sector_visited should work with positions near world bounds")
```

**Test File**: `test/test_proc_gen_world_fog.gd` *(new file)*

#### Group 1: ProcGenWorld Setup
```gdscript
it.todo("_setup_fog_sectors should create FogSectorManager instance")
it.todo("_setup_fog_sectors should create fog_sectors_container node")
it.todo("_setup_fog_sectors should create 192 Area2D nodes (16×12)")
it.todo("_setup_fog_sectors should position Area2D nodes at correct world coordinates")
it.todo("_setup_fog_sectors should connect body_entered signals to handler")
```

#### Group 2: Sector Detection
```gdscript
it.todo("_on_fog_sector_entered should mark sector visited when player enters")
it.todo("_on_fog_sector_entered should not affect non-player bodies entering sector")
it.todo("_on_fog_sector_entered should handle multiple sector entries")
```

#### Group 3: Minimap Rendering
```gdscript
it.todo("generate_minimap should render unvisited sectors as pure black")
it.todo("generate_minimap should render visited sectors with normal colors")
it.todo("generate_minimap should preserve existing world/town rendering")
it.todo("generate_minimap should handle sector boundaries correctly")
it.todo("generate_minimap should handle mixed visited/unvisited sectors")
```

**Test File**: `test/test_fog_sector_persistence.gd` *(new file)*

#### Group 1: Serialization
```gdscript
it.todo("get_save_data should include visited_sectors in world data")
it.todo("get_save_data should serialize all 192 sector states")
it.todo("get_save_data should include both visited and unvisited sectors")
```

#### Group 2: Deserialization
```gdscript
it.todo("set_save_data should restore visited_sectors from save data")
it.todo("set_save_data should preserve town and good data during restore")
it.todo("set_save_data should handle missing visited_sectors gracefully (fallback to all false)")
it.todo("set_save_data should restore exact visited state after round-trip (save → load)")
```

**Test File**: `test/test_fog_sector_integration.gd` *(new file)*

#### Group 1: Main Integration
```gdscript
it.todo("Main._ready should call _setup_fog_sectors before save data load")
it.todo("Main._ready should mark starting sector visited on new game")
it.todo("Main._ready should restore fog state on game load")
it.todo("Main._setup_minimap should generate minimap with fog overlay applied")
```

#### Group 2: Full Cycle
```gdscript
it.todo("Player entering sector should mark it visited in fog system")
it.todo("Visited sector should render normally in minimap")
it.todo("Unvisited sector should render as black in minimap")
it.todo("Fog state should persist across save/load cycle")
```

#### Group 3: Edge Cases
```gdscript
it.todo("Fog system should handle world boundaries correctly")
it.todo("Fog system should handle player at exact sector boundaries")
it.todo("Fog system should handle player moving between sectors rapidly")
it.todo("Fog system should pre-reveal exactly one starting sector")
```

---

## Dependencies & Integration Notes

### Critical Initialization Order
1. **World generation MUST complete first** → proc_gen_world.generate_world()
2. **Then towns spawn** → proc_gen_world.generate_towns()
3. **Then fog sectors setup** → proc_gen_world._setup_fog_sectors()
4. **Then save data restore** (if loading) → ProcGenWorldSerializer.set_save_data()
5. **Then starting sector mark** (if new game) → fog_sector_manager.mark_starting_sector_visited()
6. **Then minimap generated** → proc_gen_world.generate_minimap()
7. **Finally displayed** → minimap.set_image()

**If this order breaks, fog sectors won't detect player or will fail to render.**

### Signal Connections
- **Area2D.body_entered** → FogSectorManager.mark_sector_visited
- One signal per sector (192 signals total) — minimal performance impact
- Signals ONLY fire once per sector when player enters
- No redundant emissions (Area2D doesn't emit if body stays)

### Serialization Format
```gdscript
{
    "world": {
        "seed_value": 12345,
        "spawn_accumulator": 5.5,
        "visited_sectors": [true, false, true, ...],  # 192 bools
        "towns": [...],
        "goods": [...]
    }
}
```
- visited_sectors array stored as flat Array[bool]
- Sized exactly to sector count (16 × 12 = 192)

### Performance Considerations
- **Area2D overhead**: One per sector (192) — acceptable for Godot 4
- **Memory**: 192 bools ≈ 192 bytes in visited_sectors
- **Minimap render**: ~192 nested loops for fog overlay (minimal, only on minimap generation)
- **Per-frame**: Zero overhead after initial setup (signals only fire on entry)

### Tight Coupling & Refactoring Opportunities
- **FogSectorManager** is independent class → easy to test in isolation
- **ProcGenWorld** owns FogSectorManager → tight coupling acceptable (single responsibility)
- **Minimap** doesn't know about fog → loose coupling via proc_gen_world.generate_minimap()
- **Future enhancement**: Signal emitted when sector visited (for UI feedback) — easy to add

---

## Recommended Area2D Implementation Detail

### Node Architecture
```
ProcGenWorld (Node2D)
├── [existing TileLayers]
├── FogSectors (Node2D) ← container node
│   ├── FogSector_0 (Area2D) - top-left sector
│   │   └── CollisionShape2D (RectangleShape2D)
│   ├── FogSector_1 (Area2D)
│   │   └── CollisionShape2D (RectangleShape2D)
│   ├── FogSector_2 (Area2D)
│   │   └── CollisionShape2D (RectangleShape2D)
│   ├── ...
│   └── FogSector_191 (Area2D) - bottom-right sector
│       └── CollisionShape2D (RectangleShape2D)
├── Towns
└── Goods
```

### Area2D Configuration
- **Name**: "FogSector_{index}" (for debugging)
- **Collision Layers**: Configure to detect player CharacterBody2D
- **Collision Mask**: Set to detect "player" collision layer only
- **Position**: World coordinates (sector_x * 256, sector_y * 256)
- **Size**: Fixed 256×256 pixels (16 tiles × 16 pixels/tile)
- **Monitoring**: Enabled
- **Monitorable**: Disabled (we only care about bodies entering)

### Why Area2D (not positional polling)
✅ **Advantages**:
- Clean signal-based architecture (no polling every frame)
- Leverages Godot's built-in collision detection
- Easy to visualize/debug in editor
- Scales to any sector count
- Zero per-frame overhead after setup

❌ **Why NOT positional polling**:
- Would require signal every frame or frequent positional checks
- More CPU intensive (distance calculations)
- Harder to test (frame-dependent behavior)
- Signal spam on frequent position updates

---

## Edge Cases & Handling

| Edge Case | Behavior | Notes |
|-----------|----------|-------|
| **Player at world boundary** | Clamps sector calculation to valid range | `get_sector_at_world_position()` handles this |
| **Player at sector boundary (edge pixels)** | Belongs to sector of lower pixel value | Expected behavior, Area2D physics handles naturally |
| **Rapid sector transitions** | Each sector area emits signal only on enter, not on stay | Player can move between sectors without re-triggering |
| **Player starts out of bounds** | `mark_starting_sector_visited()` clamps position | Graceful fallback |
| **Starting sector == loaded game** | Starting sector mark skipped (already in save data) | Conditional logic: `if not SaveManager.is_game_loaded()` |
| **Multiple Area2D triggers (overlap)** | Signals fire for each sector entered | Expected and acceptable — all overlapped sectors marked visited |
| **Minimap generation before fog setup** | Fog overlay skipped (null check on fog_sector_manager) | Graceful: `if fog_sector_manager:` guard clause |
| **Fog system reinitialization** | Previous Area2D nodes freed, new ones created | Clean slate on world regeneration |
| **Large world (e.g., 1024×1024)** | Creates 4096 sectors — may need optimization | Out of scope for current 256×192 world; consider spatial indexing if needed |

---

## Summary of Files to Create/Modify

### New Files
1. **`world/fog_sector_manager.gd`** — Core fog system
2. **`test/test_fog_sector_manager.gd`** — Unit tests
3. **`test/test_proc_gen_world_fog.gd`** — Integration tests
4. **`test/test_fog_sector_persistence.gd`** — Persistence tests
5. **`test/test_fog_sector_integration.gd`** — End-to-end tests

### Modified Files
1. **`world/proc_gen_world.gd`** — Add _setup_fog_sectors(), modify generate_minimap()
2. **`world/proc_gen_world_serializer.gd`** — Add visited_sectors to save/load
3. **`world/main.gd`** — Call fog initialization, mark starting sector

---

## TDD Workflow Recommended

1. **Start with FogSectorManager** (test-list → red → green → refactor cycles)
   - Pure logic, no dependencies, easiest to test
2. **Then ProcGenWorld integration** (Area2D setup and signals)
   - Depends on FogSectorManager working
3. **Then Minimap rendering** (fog overlay)
   - Depends on visited_sectors populated correctly
4. **Then serialization** (save/load)
   - Depends on FogSectorManager state stable
5. **Finally Main.gd integration** (end-to-end)
   - All subsystems working

This sequencing ensures each phase builds on proven foundations.
