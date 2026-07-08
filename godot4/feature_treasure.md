# Feature: Treasure Exploration Loop

## Story Background
Treasure is the best next feature to raise fun quickly because it adds surprise, discovery, and memorable moments during travel. It gives the player short-term goals between trading runs, makes exploration feel purposeful, and fits existing systems (world traversal, towns, ships, minimap) without a major rewrite. It also creates a strong base for later systems like raider ambushes, title progression, quests, and fog-based clue gameplay.

## MVP Scope
1. Add world-spawned treasure points.
2. Allow treasure collection through proximity/search interaction.
3. Reward player immediately (gold first).

## Out of Scope for MVP
1. Full quest chains.
2. Complex treasure maps.
3. New large UI screens.
4. Heavy event orchestration.

## Balancing Knobs
1. `spawn_count_factor`: 0.01 to 0.04 of world width.
2. `reward_min_gold`: 15 to 40.
3. `reward_max_gold`: 60 to 180.
4. `clue_distance_hot_tiles`: 4 to 8.
5. `clue_distance_warm_tiles`: 9 to 16.
6. `clue_message_cooldown_sec`: 3 to 8.
7. `trap_risk_chance`: 0.00 to 0.20.
8. `trap_gold_loss_pct`: 0.05 to 0.20.

## Implementation Phases

### Phase 1: Treasure Model and Spawn
Goal: deterministic treasure placement tied to world seed.

Tasks:
1. Add treasure state and tuning values in `world/proc_gen_world.gd`.
2. Spawn only on valid terrain, excluding towns and blocked tiles.
3. Hook generation into world startup flow in `world/main.gd`.

Risks:
1. Invalid or frustrating spawn positions.
2. Town overlap and clutter.

Mitigations:
1. Reuse terrain buckets and exclusion radius checks.
2. Retry cap with safe fallback.

Exit criteria:
1. Treasure spawns every new game.
2. Same seed gives same locations.
3. No invalid spawn tiles.

### Phase 2: Discovery and Reward Loop
Goal: make treasure collection rewarding and reliable.

Tasks:
1. Add collection API in `world/proc_gen_world.gd`.
2. Apply rewards in `world/main.gd`.
3. Show feedback through `world/message_bus.gd` and `gui/message_widget.gd`.
4. Optional trap branch using `player/player.gd`.

Risks:
1. Duplicate rewards in same frame.
2. Message spam.

Mitigations:
1. Mark/remove treasure before reward dispatch.
2. Cooldown and dedupe logic.

Exit criteria:
1. One treasure gives one reward exactly once.
2. Clear success and trap feedback appears.

### Phase 3: Clues and Gamefeel
Goal: avoid random-feeling hunting and reduce frustration.

Tasks:
1. Add nearest-distance clue buckets in `world/proc_gen_world.gd`.
2. Add throttled clue messaging in `world/main.gd`.
3. Optional clue style intensity in `gui/message_widget.gd`.
4. Add debug tuning values in `gui/debug_screen.gd`.

Exit criteria:
1. Players can infer proximity from clues.
2. Clues are readable and non-spammy.

### Phase 4: Minimap and Fog Integration
Goal: make discoveries feel persistent without revealing all treasure.

Tasks:
1. Draw discovered treasure markers only in minimap generation.
2. Refresh minimap and fog only on state changes via `world/fog_sector_manager.gd` and `world/minimap.gd`.

Exit criteria:
1. Undiscovered treasure remains hidden.
2. Discovered markers persist.
3. No noticeable performance regression.

### Phase 5: Save/Load and Serialization
Goal: preserve treasure state across sessions and old saves.

Tasks:
1. Extend world serializer in `world/proc_gen_world_serializer.gd`.
2. Keep save manager flow stable in `world/save_manager.gd`.
3. Add missing-key defaults and load-order safeguards in `world/main.gd`.

Exit criteria:
1. Collected treasure stays collected after reload.
2. Old saves load safely with defaults.
3. No double-generation after load.

### Phase 6: Tests (GUT)
Goal: lock behavior and prevent regressions.

Test targets:
1. `test/test_proc_gen_world.gd`: spawn count range, valid tiles only, one-time collection, clue bucket transitions.
2. `test/test_proc_gen_world_serializer.gd`: save includes treasure state, restore works, missing keys fallback.
3. `test/test_save_manager.gd`: world treasure data included in game save.
4. `test/test_main.gd`: loading does not regenerate treasure over restored state.

## Suggested Solo Schedule (1 to 2 Weeks)
1. Day 1 to 2: Phase 1 plus initial spawn tests.
2. Day 3 to 4: Phase 2 reward loop plus feedback tests.
3. Day 5: Phase 3 clue tuning plus debug support.
4. Day 6: Phase 5 serialization plus save/load tests.
5. Day 7: Phase 4 minimap/fog integration plus manual gamefeel pass.
6. Day 8 to 10: balancing, bug fixes, and polish.

## Post-MVP Extensions
1. Raider ambush chance near treasure routes.
2. Title or progression bonuses for treasure milestones.
3. Town clue contracts.
4. Fog exploration depth affecting clue precision.
5. Rarity tiers tied to rank or ship class.
