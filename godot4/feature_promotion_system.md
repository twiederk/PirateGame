# Feature: Promotion System

## Feature Overview

This feature introduces a promotion system that grants the player new titles based on progress.

Two promotion mechanisms are included in the first iteration:

- By money: promotion is granted when the player's gold reaches configured thresholds.
- By ship: promotion is granted when the player buys specific ships.

When a promotion is reached, the PromotionSystem signals Main to show a PromotionMenu.
The PromotionMenu displays:

Du hast den Titel ${title} erhalten

The player confirms the message with an OK button.
The current title must be saved and loaded via SaveManager.

---

## Scope (MVP)

- Add title state to Player.
- Add PromotionSystem to evaluate and grant promotions.
- Add PromotionMenu UI for promotion notifications.
- Trigger promotions after relevant gameplay events (gold change, ship purchase, load/new game setup).
- Persist current title in save data.
- Keep promotion flow deterministic and idempotent (no duplicate title popups for already unlocked title).

---

## Promotion Rules

### Start Title

- Required for this feature: player starts with title Händler.

### Gold-based Promotions

| Gold Threshold | Title |
|---|---|
| 500 | Händler |
| 1.000 | Großhändler |
| 2.500 | Kaufmann |
| 5.000 | Großkaufmann |
| 7.500 | Zunftmeister |
| 10.000 | Handelsfürst |

### Ship-based Promotions

| Ship Resource ID | Title |
|---|---|
| ship_boat | Kapitän |
| ship_sailing | Kapitän zur See |

### Future Ideas (Not in MVP)

- Kapitän -> Schaluppe
- Kapitän zur See -> Brigantine
- Flottenkapitän -> Fregatte
- Admiral -> Linienschiff
- Großadmiral -> mehrere Schiffe / Flotte

---

## Design Decisions

### Rule Priority

- PromotionSystem computes the highest valid title from all active rules (gold + ship).
- If multiple rules are met at once, the highest-ranked title is granted.
- If computed title equals current title, no signal is emitted.

### Data-Driven Configuration

- Use arrays/dictionaries in PromotionSystem for thresholds and ship-to-title mapping.
- Keep rank order explicit in one place to avoid ambiguous comparisons.

### Backward Compatibility

- If old save data has no title field, default to Händler.

---

## Implementation Plan

### Phase 1: Core Title Model

Files:
- player/player.gd

Tasks:
1. Add current title field to Player, for example current_title: String = "Händler".
2. Add helper methods:
   - get_current_title()
   - set_current_title(title: String)
3. Extend player save data serialization and restore logic with title.

Acceptance:
- New game player starts as Händler.
- Loading save restores title.
- Older save without title falls back to Händler.

---

### Phase 2: PromotionSystem Node

Files:
- world/promotion_system.gd (new)
- world/main.tscn (add node)

Tasks:
1. Create PromotionSystem class with configured rules:
   - Gold thresholds
   - Ship promotion mapping
   - Ordered rank list
2. Add signal, for example:
   - signal promotion_reached(new_title: String)
3. Add API methods:
   - evaluate(player: Player) -> void
   - _calculate_best_title(player: Player) -> String
4. Emit signal only when player title changes.

Acceptance:
- evaluate() promotes exactly once per new title.
- evaluate() is safe to call repeatedly.

---

### Phase 3: PromotionMenu UI

Files:
- gui/promotion_menu.tscn (new)
- gui/promotion_menu.gd (new)

Tasks:
1. Create menu UI with text label and OK button.
2. Add init(title: String) to set text:
   - Du hast den Titel ${title} erhalten
3. Add confirmation signal, for example:
   - signal confirmed
4. Hide menu by default.

Acceptance:
- Menu shows exact title message.
- Pressing OK emits confirmation and closes menu.

---

### Phase 4: Main Flow Integration

Files:
- world/main.gd
- world/main.tscn
- gui/town_menu.gd

Tasks:
1. Add references to PromotionSystem and PromotionMenu in Main.
2. Connect PromotionSystem signal to Main handler that opens PromotionMenu.
3. While PromotionMenu is visible, block normal gameplay input (same behavior style as town/pause overlays).
4. Trigger PromotionSystem.evaluate(player) at reliable points:
   - After game initialization (new game and loaded game)
   - After trading buy/sell in TownMenu
   - After ship purchase in TownMenu
5. Prefer routing through Main for UI ownership:
   - TownMenu emits event/request, Main triggers evaluate
   - or inject PromotionSystem reference into TownMenu if currently simpler

Acceptance:
- Promotions appear immediately after reaching a threshold.
- UI flow is: promotion signal -> menu popup -> user confirms -> resume.

---

### Phase 5: Save/Load Integration

Files:
- player/player.gd
- world/save_manager.gd (only if schema helpers are needed)
- test/test_save_manager.gd

Tasks:
1. Ensure title is part of player save payload.
2. Ensure load restores exact title value.
3. Ensure missing title in save defaults to Händler.

Acceptance:
- Save/load roundtrip preserves title exactly.

---

### Phase 6: Test Plan (TDD with GUT)

Primary test files:
- test/test_promotion_system.gd (new)
- test/test_player.gd
- test/test_save_manager.gd
- test/test_town.gd or test/test_main.gd (integration flow)

Test list:
- test_player_starts_with_haendler_title
- test_promote_to_grosshaendler_at_1000_gold
- test_promote_to_kaufmann_at_2500_gold
- test_promote_to_grosskaufmann_at_5000_gold
- test_promote_to_zunftmeister_at_7500_gold
- test_promote_to_handelsfuerst_at_10000_gold
- test_no_promotion_below_next_gold_threshold
- test_ship_boat_promotes_to_kapitaen
- test_ship_sailing_promotes_to_kapitaen_zur_see
- test_highest_title_selected_when_gold_and_ship_rules_both_match
- test_no_duplicate_signal_if_title_unchanged
- test_signal_emitted_once_when_new_title_granted
- test_promotion_message_contains_new_title
- test_confirm_closes_promotion_menu
- test_player_title_serialized_in_save_data
- test_player_title_restored_from_save_data
- test_missing_title_in_save_defaults_to_haendler

---

## Open Questions

1. Start title conflict:
   - Requirement says start title is Händler.
   - Idea table also includes 0 -> Krämer.
   - Proposed MVP decision: start with Händler and keep Krämer out of active rules for now.

2. Title precedence model:
   - Should naval titles outrank economic titles, or should one unified rank order be used?
   - Proposed MVP decision: one explicit unified rank list in PromotionSystem.

3. Localization:
   - Promotion message currently hardcoded in German.
   - Keep as-is for MVP, extract later if localization is introduced.

---

## Suggested Rank Order (MVP)

A single ordered list to resolve conflicts consistently:

1. Händler
2. Großhändler
3. Kaufmann
4. Großkaufmann
5. Zunftmeister
6. Kapitän
7. Kapitän zur See
8. Handelsfürst

Note: This order can be adjusted after gameplay balancing.

---

## Rollout Notes

- Implement in small TDD increments.
- Keep PromotionSystem pure where possible (calculation logic easy to unit test).
- Keep UI logic in Main/PromotionMenu, not inside Player.
- Validate no regressions for town/trading flow and save/load behavior.
