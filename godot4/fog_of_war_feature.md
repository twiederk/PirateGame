# Feature Plan: Fog of War (Minimap Sectors)

## Feature Goal
Reveal the minimap in sector-sized chunks as the player explores, while keeping unexplored sectors black.

## Scope
- Minimap size: 256 x 192 pixels (1 minimap pixel per world tile).
- Sector size: 16 x 16 tiles.
- Total sectors: 16 x 12 = 192.
- Only minimap rendering is affected.
- Only player exploration reveals sectors.
- Revealed sectors stay revealed.
- Fog state must persist in save/load.

## Confirmed Requirements
- Unvisited sectors render as pure black.
- No reveal animation is required.
- Starting sector is revealed on new game.
- Save data for fog is handled through ProcGenWorldSerializer.
- Camera and player can update every frame.
- No special world-border behavior required beyond safe bounds handling.

## Out of Scope
- Gameplay visibility, navigation, AI, or combat changes.
- Enemy or NPC based revealing.
- Visual transition effects.

## Design Decision
Use viewport-based geometric reveal checks, not Area2D sector nodes.

Reasons:
- Matches what the player can currently see.
- Avoids creating many scene nodes/signals.
- Keeps updates simple and deterministic.
- Fits the current minimap image pipeline.

## Data Model

### Fog Grid
- Represent visited state as a flat boolean array with 192 entries.
- Keep sector dimensions and world dimensions in the manager.

### Index Mapping
- Convert world position to sector coordinates.
- Convert sector coordinates to flat array index.
- Support reverse mapping for minimap overlay logic.
- Clamp or reject invalid input consistently.

### Persistence Payload
- Store visited sectors under world save data.
- Restore visited sectors after world generation and manager setup.
- If data is missing, fall back to all-unvisited state (except start sector for new game).

## Implementation Plan

### Phase 1: Fog Sector Manager
File: world/fog_sector_manager.gd (new)

Tasks:
1. Add manager class responsible for all fog sector calculations and visited state.
2. Initialize sector grid from world width/height using sector size 16.
3. Add helpers for position-to-sector, sector-to-index, and index-to-sector conversions.
4. Add visited-state operations (mark, query, export, import).
5. Add method to mark the starting sector as visited.
6. Add method to reveal all sectors overlapping a camera viewport rectangle.

Exit Criteria:
- Manager can represent and mutate fog state independently.
- All mapping and bounds rules are deterministic.

### Phase 2: ProcGenWorld Integration
File: world/proc_gen_world.gd

Tasks:
1. Add fog manager property and initialize it after world generation.
2. Keep a camera reference or viewport source for world-space viewport bounds.
3. Add update path that reveals sectors visible in the current camera viewport.
4. Trigger reveal updates during runtime (for moving camera/player).
5. Ensure setup order supports both new game and loaded game flows.

Exit Criteria:
- Visible sectors become visited during play.
- No node-heavy sector detection is introduced.

### Phase 3: Minimap Fog Overlay
File: world/proc_gen_world.gd (minimap generation path)

Tasks:
1. Keep existing minimap base rendering (terrain/towns).
2. Add fog overlay pass after base rendering.
3. For each unvisited sector, paint corresponding minimap region black.
4. Keep bounds-safe writes at sector edges.

Exit Criteria:
- Unvisited sectors are black.
- Visited sectors keep normal minimap colors.

### Phase 4: Save/Load Integration
File: world/proc_gen_world_serializer.gd

Tasks:
1. Include visited sector array in world save data.
2. Restore visited sector array during load.
3. Handle absent fog data safely for backward compatibility.

Exit Criteria:
- Fog state round-trips correctly through save and load.

### Phase 5: Main Flow Integration
File: world/main.gd

Tasks:
1. Ensure fog manager setup happens before applying loaded fog data.
2. On new game, mark starting sector as visited.
3. Ensure minimap setup uses fog-aware minimap generation.

Exit Criteria:
- New game starts with starting sector revealed.
- Loaded game restores prior exploration state.

## Initialization Order (Critical)
1. Generate world.
2. Generate towns/related world content.
3. Setup fog manager.
4. If loading: restore fog sectors from save.
5. If new game: reveal starting sector.
6. Generate minimap image with fog overlay.
7. Start runtime visibility updates.

## Testing Plan (TDD)

### Test File 1
File: test/test_fog_sector_manager.gd

Test groups:
1. Initialization and sector dimensions.
2. Index/coordinate mapping and bounds handling.
3. Visited state transitions and idempotency.
4. Export/import of visited array.
5. Starting sector reveal behavior.
6. Viewport overlap reveal behavior.

### Test File 2
File: test/test_proc_gen_world_fog.gd

Test groups:
1. Fog setup in ProcGenWorld lifecycle.
2. Runtime visibility update integration.
3. Minimap fog overlay correctness.

### Test File 3
File: test/test_fog_sector_persistence.gd

Test groups:
1. Serializer includes fog state.
2. Serializer restores fog state.
3. Missing fog state fallback behavior.

### Test File 4
File: test/test_fog_sector_integration.gd

Test groups:
1. Main flow order for new game and load.
2. End-to-end reveal and minimap consistency.
3. Save/load exploration continuity.

## Risks and Mitigations
- Risk: incorrect init order breaks restore behavior.
  Mitigation: add integration tests for load/new-game branches.

- Risk: coordinate conversion off-by-one errors at edges.
  Mitigation: add boundary-focused manager tests.

- Risk: frequent updates cause unnecessary work.
  Mitigation: keep reveal operation idempotent and lightweight.

## Acceptance Criteria
- Minimap starts mostly black except revealed sectors.
- Moving through the world reveals minimap sectors in 16x16 chunks.
- Revealed sectors remain visible permanently.
- Saving and loading preserves revealed sectors exactly.
- Implementation remains limited to minimap display behavior.

## Notes for Future Extensions
- Optional optimization: update reveals only when camera transform changes.
- Optional UX: add reveal feedback in UI without changing fog logic.
