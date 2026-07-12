# Feature: Treasure Map Progression

## Goal
Make treasure maps feel exciting and strategic by adding:
- Scarcity: not every town sells a map
- Variety: map sizes with different risk and reward
- Cadence: offers refresh over time

## Why this feature now
This feature increases fun without requiring a full new gameplay pillar.
It strengthens your current loop (travel, trade, explore) and creates player decisions:
- Stay and trade, or travel to another town for map offers
- Buy a cheap small map now, or wait for a better one
- Plan routes around refresh timing

## Current state (from code)
- Treasure entities already exist and are generated in world generation.
- Player can buy one treasure map and later find treasure.
- Town menu currently shows one treasure map offer from the first entry in the treasure list.
- Treasure map image is currently fixed-size via one constant in world generation.
- TradingSystem already tracks current_game_time and is serialized.

## MVP scope
1. Town availability
- Only a subset of towns has an active map offer at any time.
- Default target: 30% of towns offer maps.

2. Map tiers by size
- Add 3 map tiers:
  - Small: low price, low reward, easier and local
  - Medium: medium price/reward
  - Large: high price/reward, farther travel

3. Offer refresh timing
- Offers refresh on a fixed game-time interval.
- Default: every 120 seconds of current_game_time.

4. UI clarity
- Town menu displays:
  - No map available
  - Map tier name and price when available

## Out of scope for MVP
- Special legendary map types
- Quest chains tied to maps
- Multiple map inventory per player
- Dynamic economy impact of map purchases

## Functional design

### Data model changes
1. Treasure
- Add tier metadata:
  - map_tier_id (String)
  - map_size (Vector2i)
- Keep existing fields gold, price, texture, active.

2. Town
- Add offer state fields:
  - has_treasure_offer (bool)
  - treasure_offer_treasure_id or direct reference (choose one strategy)
  - treasure_offer_refresh_time (float)

3. New config model (optional but recommended)
- New resource/script TreasureMapTierConfig with:
  - id
  - display_name
  - map_size
  - min_price, max_price
  - min_gold, max_gold
  - weight

### Systems and ownership
1. ProcGenWorld responsibilities
- Keep world treasure placement/generation source of truth.
- Add helper to create treasure map image by requested map_size.
- Add function to build treasure by tier.

2. Town offer assignment
- Introduce a small service/class (recommended): TreasureOfferSystem
- Inputs:
  - towns
  - available treasures
  - current_game_time
- Responsibilities:
  - assign offers to a target percentage of towns
  - refresh expired offers
  - avoid assigning already-active treasure to multiple towns

3. TownMenu integration
- Read current town offer state.
- Show hidden/empty state when no offer exists.
- On purchase:
  - transfer treasure to player
  - mark treasure active
  - clear town offer
  - refresh GUI immediately

4. Save/load integration
- Persist town offer state and tier metadata for treasure.
- Rehydrate offers on load so no sudden offer resets happen after save/load.

## Suggested file touchpoints
- world/treasure.gd
- world/proc_gen_world.gd
- world/proc_gen_world_serializer.gd
- world/town.gd
- gui/town_menu.gd
- trading_system/trading_system.gd (hook for periodic refresh trigger)
- trading_system/trading_system_serializer.gd (if needed for extra timing state)
- test/test_proc_gen_world.gd
- test/test_proc_gen_world_serializer.gd
- test/test_trading_system.gd
- test/new test file for treasure offer system

## Balancing defaults (first pass)
- Offer town ratio: 0.30
- Refresh interval: 120.0 seconds game time
- Tier weights:
  - small 60
  - medium 30
  - large 10
- Tier size examples:
  - small 64x64
  - medium 100x100
  - large 160x160
- Price/gold ranges:
  - small: price 300-700, gold 800-2200
  - medium: price 700-1600, gold 2200-5200
  - large: price 1600-3500, gold 5200-12000

## Rollout plan

### Phase 1: Tiered treasure map generation
- Add tier concept and map_size support in treasure creation.
- Replace single fixed map size constant with tier-driven size.
- Keep current purchase flow intact for now.

Exit criteria:
- Generated treasures contain tier metadata and size-specific map textures.

### Phase 2: Town offer assignment and UI
- Add town-level offer fields.
- Build assignment logic for initial world state.
- Update TownMenu to display no-offer vs offer state.

Exit criteria:
- Only subset of towns shows map offers.
- Buying from one town clears the local offer.

### Phase 3: Time-based refresh
- Hook refresh evaluation into game time progression.
- Refresh offers at interval, respecting active/inactive treasure state.

Exit criteria:
- Offers rotate predictably with current_game_time.
- Existing map owned by player remains stable.

### Phase 4: Save/load hardening
- Persist all new fields.
- Ensure loading does not duplicate or lose offers.

Exit criteria:
- Save/load round-trip preserves offers and tiers.

## TDD plan (GUT)

### Test list for new treasure offer system
1. creates initial offers for target percentage of towns
2. does not assign same treasure to multiple towns
3. skips towns that already have valid unexpired offers
4. refreshes expired offers when interval reached
5. does not refresh offers before interval
6. keeps purchased/active treasure from being reassigned

### Test list for world generation and tiers
1. creates treasure with valid tier id
2. creates map texture size matching tier map_size
3. generates price within tier range
4. generates gold within tier range

### Test list for town menu behavior
1. hides treasure row when town has no offer
2. shows tier name and price when offer exists
3. buying map clears town offer
4. buying map marks treasure active and assigns to player
5. buying map fails with not enough gold and keeps offer

### Test list for serialization
1. saves and restores treasure tier metadata
2. saves and restores town offer state
3. save/load round-trip preserves offer availability exactly
4. save/load round-trip does not duplicate assigned treasures

## Risks and mitigations
1. Risk: cyclic references between town and treasure
- Mitigation: store treasure node path or unique id instead of hard object reference when serializing.

2. Risk: offer refresh changes while TownMenu is open
- Mitigation: lock offer state during menu session, or refresh only on entering town menu.

3. Risk: balancing feels punishing if too few offers appear
- Mitigation: expose ratio and interval as exported values and tune quickly.

## Telemetry and debug hooks (recommended)
Add debug output in DebugScreen for:
- active map offers count
- towns with offers count
- next refresh time
- tier distribution currently available

## Acceptance checklist
- Not every town sells treasure maps.
- Treasure maps come in different sizes and rewards.
- Offers refresh based on game time.
- UI clearly communicates availability.
- Save/load preserves progression state.
- New tests pass in GUT.

## Nice-to-have follow-ups
- Reputation or rank gates for larger map tiers
- Region-specific map style and reward tables
- Rare special artifacts tied to specific destination towns
