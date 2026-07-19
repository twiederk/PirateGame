# Feature: More Places to Explore on Map

## Requirements Checklist
- [ ] Add new explorable place categories beyond current towns/treasure flow.
- [ ] Support place types: treasure, city (different sizes), ancient sites, lost places.
- [ ] Generate natural story moments such as “I found X near Y and risked Z to get it.”
- [ ] Integrate with existing world generation, simulation, save/load, and message systems.
- [ ] Show place discovery and risk outcome feedback in UI.
- [ ] Add balancing knobs for rarity, rewards, and risk.
- [ ] Add debug telemetry visible on DebugScreen.
- [ ] Deliver a base-first TDD backlog (GUT) in Red-Green-Refactor order.

## Implementation Plan

### Phase 1: Domain Model and Config Resources
**Goal**: Introduce a resource-driven place system that matches current TreasureResource and TownResource patterns.

**Scope**:
1. Add a generic place type model with typed categories and rarity.
2. Define reward and risk ranges in resources, not hardcoded in logic.
3. Keep compatibility with existing treasure maps and town ownership flow.

**File-level suggestions**:
- Modified: [world/treasure_resource.gd](world/treasure_resource.gd)
- New: world/place_resource.gd
- New: world/place_catalog.gd
- New: world/place_common.tres
- New: world/place_uncommon.tres
- New: world/place_rare.tres
- New: world/place_legendary.tres

**Data model proposal**:
- PlaceCategory enum:
1. TREASURE_CACHE
2. CITY_SMALL
3. CITY_LARGE
4. ANCIENT_SITE
5. LOST_PLACE
- Rarity enum:
1. COMMON
2. UNCOMMON
3. RARE
4. LEGENDARY
- PlaceResource fields:
1. category
2. rarity
3. spawn_weight
4. min_distance_from_border
5. map_marker_id
6. map_reveal_radius_tiles
7. reward_gold_range
8. reward_goods_bonus_range
9. risk_event_weights
10. flavor_templates_discovery
11. flavor_templates_resolution
- RiskEvent type ids:
1. RAIDERS_AMBUSH
2. STORM_DAMAGE
3. CURSE_TOLL
4. CREW_DESERTION
5. SAFE_FIND (zero-risk outcome)

**Acceptance criteria**:
- [ ] Place resources can represent all required categories.
- [ ] At least one risk profile is configurable per category.
- [ ] Existing treasure rarity and map size behavior remains intact.

---

### Phase 2: Runtime Place Entity and Story Event Resolution
**Goal**: Add a runtime place node that can be discovered, resolved, and translated into story messages.

**Scope**:
1. Introduce place runtime object state (hidden, discovered, resolved).
2. Resolve reward and risk on player interaction.
3. Emit narrative messages through existing message bus.

**File-level suggestions**:
- New: world/place.gd
- New: world/place_story_builder.gd
- Modified: [world/message_bus.gd](world/message_bus.gd)
- Modified: [player/player.gd](player/player.gd)

**Behavior design**:
1. Discovery happens when player enters interaction area and presses search (reuse current input pattern used by treasure).
2. Resolution flow:
   - Roll risk event first.
   - Apply penalties (gold loss, goods loss, optional temp debuff placeholder).
   - Roll rewards.
   - Mark place resolved.
3. Story message template:
   - “Ich fand [artifact] nahe [nearest_town]. Ich riskierte [risk_text] und gewann [reward_text].”
4. MessageBus upgrade:
   - Keep current signal compatible.
   - Optional second signal for structured telemetry payload: event_type, category, rarity, risk, reward.

**Acceptance criteria**:
- [ ] Place interaction can produce both reward-only and risk+reward outcomes.
- [ ] Messages are readable and include X (find), Y (nearby reference), Z (risk).
- [ ] Player state updates are consistent with existing loss/gain methods.

---

### Phase 3: World Generation and Distribution Strategy
**Goal**: Spawn places with controllable biome distribution and rarity pacing.

**Scope**:
1. Add a place generator integrated in ProcGenWorld simulation loop.
2. Choose spawn positions by category constraints:
   - Treasure caches: sand/coast and distance from towns.
   - Small cities: coast/grass adjacency.
   - Large cities: rarer, farther apart, near trade routes or coast hubs.
   - Ancient sites: cliff/grass boundaries.
   - Lost places: remote border-safe areas with high rarity.
3. Preserve existing town generation while adding city-size metadata.

**File-level suggestions**:
- New: world/places_generator.gd
- Modified: [world/proc_gen_world.gd](world/proc_gen_world.gd)
- Modified: [world/generator.gd](world/generator.gd)
- Modified: [world/towns_generator.gd](world/towns_generator.gd)
- Modified: [world/town.gd](world/town.gd)

**Spawning/distribution strategy**:
1. Use per-category target count = world.width * category_percentage.
2. Use weighted rarity roll per category.
3. Enforce minimum spacing:
   - city_to_city_min_tiles
   - place_to_town_min_tiles
   - legendary_place_min_tiles_from_player_spawn
4. Use hidden-position filter where appropriate (already available in Generator).
5. Refill in simulation every SIMULATION_STEP similar to goods/raiders/treasures.

**Balancing knobs**:
1. category_percentage
2. rarity_weights per category
3. reward multipliers by rarity
4. risk probability by rarity
5. nearest-town distance bonus multiplier
6. max_active_places
7. discovery_reveal_radius
8. cooldown_before_respawn

**Acceptance criteria**:
- [ ] Places spawn consistently without overlap/invalid tiles.
- [ ] Distribution reflects category rarity targets.
- [ ] Simulation replenishment respects max_active_places.

---

### Phase 4: Save/Load and Backward Compatibility
**Goal**: Persist new place state safely with old saves still loading.

**Scope**:
1. Serialize active/discovered/resolved place instances.
2. Store category, rarity, position, rolled risk/reward outcome, and resolved timestamp tick.
3. Keep compatibility defaults for older saves without place data.

**File-level suggestions**:
- Modified: [world/proc_gen_world_serializer.gd](world/proc_gen_world_serializer.gd)
- Modified: [world/save_manager.gd](world/save_manager.gd)
- Modified: [player/player_serializer.gd](player/player_serializer.gd)

**Acceptance criteria**:
- [ ] Save-load roundtrip preserves place states and outcomes.
- [ ] Missing place data in old saves does not crash.
- [ ] Player treasure map state still restores correctly.

---

### Phase 5: UI/UX Discovery and Map Markers
**Goal**: Make discoveries legible, exciting, and strategically useful.

**Scope**:
1. Add marker styles for discovered place categories on minimap.
2. Extend town and message UI to hint nearby opportunities.
3. Keep clear visual distinction between unresolved and resolved places.

**File-level suggestions**:
- Modified: [world/minimap.gd](world/minimap.gd)
- Modified: [gui/message_widget.gd](gui/message_widget.gd)
- Modified: [gui/town_menu.gd](gui/town_menu.gd)
- Modified: [world/main.gd](world/main.gd)
- New: gui/place_discovery_row.gd
- New: gui/place_discovery_row.tscn

**UI/UX notes**:
1. Marker palette:
   - Treasure: gold dot
   - Small city: small blue square
   - Large city: large blue square with border
   - Ancient site: ochre triangle
   - Lost place: dark red diamond
2. Marker states:
   - Unknown: hidden
   - Discovered: icon visible
   - Resolved: faded icon
3. Message cadence:
   - Immediate discovery line.
   - Immediate resolution line (risk then reward).
4. Example story beats:
   - “Ich fand eine versunkene Truhe nahe Lübeck und riskierte einen Räuberhinterhalt.”
   - “Ich fand eine alte Stätte nordwestlich von Hamburg und verlor 20% Waren, barg aber 1800 Gold.”

**Acceptance criteria**:
- [ ] Player can identify discovered place type at a glance.
- [ ] Message flow always includes find context + risk context + reward result.
- [ ] UI remains readable during rapid events.

---

### Phase 6: Telemetry and Debug Screen Integration
**Goal**: Expose balancing and progression metrics for tuning.

**Scope**:
1. Add world-level counters and rolling averages.
2. Show metrics in debug screen with periodic refresh.
3. Keep telemetry lightweight and non-blocking.

**File-level suggestions**:
- Modified: [gui/debug_screen.gd](gui/debug_screen.gd)
- Modified: [world/main.gd](world/main.gd)
- New: world/place_metrics.gd

**Debug metrics proposal**:
1. active_places_total
2. active_places_by_category
3. active_places_by_rarity
4. discovered_places_count
5. resolved_places_count
6. average_reward_gold_10_events
7. average_loss_gold_10_events
8. risk_event_distribution
9. spawn_failures_invalid_tile
10. nearest_place_distance_to_player

**Acceptance criteria**:
- [ ] DebugScreen displays place metrics while running.
- [ ] Values update during simulation/discovery.
- [ ] Metrics support practical balancing decisions.

---

### Phase 7: Testing (TDD Backlog)
**Test File Suggestions**:
- New: test/test_places_generator.gd
- New: test/test_place.gd
- New: test/test_place_story_builder.gd
- New: test/test_place_metrics.gd
- Modified: [test/test_proc_gen_world.gd](test/test_proc_gen_world.gd)
- Modified: [test/test_proc_gen_world_serializer.gd](test/test_proc_gen_world_serializer.gd)
- Modified: [test/test_main.gd](test/test_main.gd)
- Modified: [test/test_town.gd](test/test_town.gd)

**Ordered TDD list (base functionality first, one test at a time)**:
1. Red: place resource defaults are valid for category and rarity.
2. Green: create minimal PlaceResource with required fields.
3. Refactor: normalize enum naming and defaults.
4. Red: places generator returns no invalid positions when no candidate tiles.
5. Green: minimal spawn guard for empty candidates.
6. Refactor: extract shared placement filters.
7. Red: generator spawns configured max_active_places cap.
8. Green: enforce cap with simple count check.
9. Refactor: isolate cap calculation.
10. Red: place discovery marks place discovered and emits message.
11. Green: add discovered flag and message call.
12. Refactor: split discovery and resolution methods.
13. Red: risk event applies expected player penalty.
14. Green: implement one risk event (RAIDERS_AMBUSH) end-to-end.
15. Refactor: move risk application into strategy map.
16. Red: reward grant increases player gold in configured range.
17. Green: minimal reward roll and application.
18. Refactor: centralize reward calculation.
19. Red: story builder includes find-near-risk text parts.
20. Green: compose deterministic story string.
21. Refactor: move templates to resource-driven format.
22. Red: serializer roundtrip preserves discovered/resolved state.
23. Green: add place list serialization and restore.
24. Refactor: deduplicate serialization helpers.
25. Red: debug metrics increment on discovery and resolution.
26. Green: implement counters only.
27. Refactor: add rolling window averages.
28. Red: minimap markers update by place state.
29. Green: render discovered markers minimally.
30. Refactor: extract marker style mapping table.

## Dependencies & Integration Notes
- Phase 1 must finish before Phases 2 and 3.
- Phase 3 depends on current town generation to provide nearest-town references for story text.
- Phase 4 should be implemented before broad playtesting to avoid state loss.
- Phase 6 depends on finalized event hooks from Phases 2 and 3.
- Tight coupling risk: place generation inside ProcGenWorld can grow too large; prefer dedicated places_generator and place_metrics helpers.

## Potential Edge Cases
- Player discovers place while simulation despawns/replaces it.
- Story builder cannot find nearest town (fallback to cardinal direction only).
- Risk event would reduce resources below zero.
- Save contains place category or rarity no longer present in enums.
- Marker clutter at high density on minimap.
- Multiple events triggered in same frame causing message overwrite.
- Town menu hints reference resolved or inaccessible places.

## MVP vs Later Extensions

### MVP
- Place categories implemented: TREASURE_CACHE, CITY_SMALL, ANCIENT_SITE, LOST_PLACE.
- Single-risk event table with 2-3 event types.
- Discovery/resolution messaging with nearest-town context.
- Minimap markers for discovered places only.
- Save/load persistence for place runtime state.
- Debug counters only (no advanced analytics).

### Later Extensions
- CITY_LARGE with unique trade modifiers and ship offerings.
- Multi-step expeditions (map fragments, chained ancient clues).
- Region-specific place pools and lore packs.
- Dynamic risk scaling by player rank/ship.
- Quest-like journal of story moments.
- Economic interactions where discoveries affect town prices/events.
