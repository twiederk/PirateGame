# Feature: Treasure Map Progression

## Goal
Update treasure-map progression to use explicit treasure rarity resources,
town-owned treasure offers, and simulation-based replenishment.

Core design decisions:
- Three treasure resource tiers: common, rare, very rare
- Tier map sizes: 100x100, 75x75, 50x50
- Price progression: lowest to highest from common -> very rare
- Reward progression: lowest to highest from common -> very rare
- Every town has a treasure property; if null, the town cannot sell a map
- Treasure generation assigns tiered treasures directly to towns
- Simulation replenishes treasures back to max, similar to goods/raiders

## Why this feature now
This keeps treasure maps consistent with existing world simulation patterns.
It also makes town behavior simpler and clearer:
- A town either has a treasure map (`town.treasure != null`) or it does not.
- Treasure rarity is explicit and balancing is data-driven.
- Refill behavior follows the same simulation philosophy as other world entities.

## Current state (from code)
- Treasure entities already exist and are generated in world generation.
- Player can buy one treasure map and later find treasure.
- Town menu currently shows one treasure map offer from the first entry in the treasure list.
- Treasure map image is currently fixed-size via one constant in world generation.
- `ProcGenWorld` already has generation methods for goods, raiders, and treasures.
- Main loop already runs simulation for trading and world systems.

## MVP scope
1. Treasure tiers as resources
- Create three TreasureResource variants:
  - common
  - rare
  - very rare

2. Tier map sizes and progression
- common: 100x100 map, lowest price, lowest reward
- rare: 75x75 map, medium price, medium reward
- very rare: 50x50 map, highest price, highest reward

3. Town-owned treasure property
- Add `treasure` property to every town.
- If `treasure == null`, no treasure map purchase is possible in that town.

4. Generation and simulation behavior
- Treasure generation creates tiered treasures and assigns them to towns.
- Simulation calls treasure generation/replenishment up to configured max, like goods/raiders.

5. UI clarity
- Town menu displays:
  - "No map available" when town treasure is null
  - Treasure rarity/tier and price when town has a treasure

## Out of scope for MVP
- Special map types beyond common/rare/very rare
- Quest chains tied to treasure tiers
- Multiple simultaneous treasure maps in player inventory
- Dynamic economy coupling between treasure and goods prices

## Functional design

### Data model changes
1. TreasureResource tiers
- Introduce or formalize three TreasureResource assets:
  - common
  - rare
  - very rare
- Each resource defines:
  - tier_id
  - map_size
  - price range
  - reward range

2. Treasure instance
- Keep existing runtime fields (price, gold/reward, texture, active).
- Add explicit reference to its TreasureResource tier.

3. Town
- Add one property: `treasure` (Treasure or nullable reference).
- No separate offer flags are required; null means no offer.

### Systems and ownership
1. ProcGenWorld responsibilities
- Keep treasure generation source of truth in world generation.
- Add helpers to create map images by tier map_size (100/75/50).
- Generate treasure instances from TreasureResource tiers.
- Assign generated treasures directly to towns via `town.treasure`.

2. Simulation replenishment
- In simulation step, call treasure generation/replenishment to maintain max treasure population.
- Reuse the same pattern already used for goods/raiders: generate only missing amount.
- Do not overwrite existing non-null town treasures.

3. TownMenu integration
- Read `town.treasure` directly.
- Show empty state when null.
- On purchase:
  - transfer town treasure to player
  - mark treasure active/owned
  - set `town.treasure = null`
  - refresh GUI immediately

4. Save/load integration
- Persist town treasure reference/state and tier metadata.
- Restore null/non-null town treasure state exactly after load.

## Suggested file touchpoints
- world/treasure.gd
- world/treasure_resource.gd (or existing tier resource files)
- world/proc_gen_world.gd
- world/proc_gen_world_serializer.gd
- world/town.gd
- gui/town_menu.gd
- world/main.gd (confirm simulation trigger path)
- test/test_proc_gen_world.gd
- test/test_proc_gen_world_serializer.gd
- test/new test file for town treasure assignment/replenishment behavior

## Balancing defaults (first pass)
- Tier sizes:
  - common: 100x100
  - rare: 75x75
  - very rare: 50x50
- Price order:
  - common < rare < very rare
- Reward order:
  - common < rare < very rare
- Generation target:
  - keep treasures at configured max count via simulation replenishment

Example first-pass ranges:
- common: price 300-700, reward 800-2200
- rare: price 700-1600, reward 2200-5200
- very rare: price 1600-3500, reward 5200-12000

## Rollout plan

### Phase 1: TreasureResource tiers and sizes
- Create three TreasureResource tiers: common, rare, very rare.
- Configure tier map sizes: 100x100, 75x75, 50x50.
- Ensure price/reward scale upward from common to very rare.

Exit criteria:
- Generated treasures reference one of the three tier resources.
- Generated map textures match configured tier sizes.

### Phase 2: Town treasure property and purchase flow
- Add `town.treasure` nullable property.
- Assign generated treasures to towns.
- Update TownMenu to use null/non-null treasure state.

Exit criteria:
- Town without treasure cannot sell a map.
- Buying a map sets `town.treasure` to null.

### Phase 3: Simulation replenishment to max
- Add/adjust simulation call to generate missing treasures up to max.
- Keep behavior aligned with goods/raiders generation model.
- Assign newly generated treasures only to towns with null treasure.

Exit criteria:
- Treasure population recovers to max during simulation.
- Existing town treasures are not overwritten unexpectedly.

### Phase 4: Save/load hardening
- Persist tier metadata and town treasure references.
- Ensure load restores null/non-null treasure state per town.

Exit criteria:
- Save/load round-trip preserves town treasure assignment and tiers.

## TDD plan (GUT)

### Test list for town treasure assignment
1. assigns treasure to town when town.treasure is null
2. does not overwrite town.treasure when already assigned
3. sets town.treasure to null after successful purchase
4. prevents purchase when town.treasure is null
5. does not assign the same treasure instance to multiple towns

### Test list for world generation and tiers
1. creates treasure with tier resource common/rare/very rare
2. creates map texture size matching tier map_size
3. generates price within tier range and in proper ordering across tiers
4. generates reward within tier range and in proper ordering across tiers

### Test list for simulation replenishment
1. simulation replenishes treasures when below max
2. simulation does not exceed configured max treasures
3. simulation fills only towns where town.treasure is null
4. simulation behavior matches goods/raiders replenishment cadence model

### Test list for town menu behavior
1. hides treasure row when town.treasure is null
2. shows tier name and price when town.treasure exists
3. buying map clears town.treasure
4. buying map marks treasure active and assigns to player
5. buying map fails with not enough gold and keeps town.treasure unchanged

### Test list for serialization
1. saves and restores treasure tier metadata
2. saves and restores town.treasure null/non-null state
3. save/load round-trip preserves town-to-treasure assignments exactly
4. save/load round-trip does not duplicate assigned treasures

## Risks and mitigations
1. Risk: cyclic references between town and treasure
- Mitigation: store treasure node path or unique id instead of hard object reference when serializing.

2. Risk: simulation assigns treasure during open TownMenu
- Mitigation: update UI on menu open and after purchase; avoid replacing non-null town treasures.

3. Risk: rarity weights can starve very rare generation
- Mitigation: expose tier weights/ranges in TreasureResource data for quick balancing.

## Telemetry and debug hooks (recommended)
Add debug output in DebugScreen for:
- towns with non-null treasure count
- towns with null treasure count
- active treasures count vs max
- tier distribution currently assigned to towns

## Acceptance checklist
- Three TreasureResource tiers exist: common, rare, very rare.
- Tier map sizes are 100x100, 75x75, and 50x50.
- Price and reward scale from lowest (common) to highest (very rare).
- Every town has a treasure property and null blocks map purchase.
- Treasure generation assigns tiered treasures to towns.
- Simulation replenishes treasures to max, aligned with goods/raiders behavior.
- Save/load preserves town treasure and tier state.
- New tests pass in GUT.

## Nice-to-have follow-ups
- Reputation or rank gates for rare/very-rare tiers
- Region-specific map style and reward tables
- Rare special artifacts tied to specific destination towns
