extends GutTest

# Phase 2 scope only: SaveManager + GameState core save/load mechanics (no pause/load menu UI).

# should collect gold, position from player
# should reject save requests for slot numbers outside 1..3
# should return false when loading a slot file that does not exist in user://saves/
# should create user://saves/ automatically before writing a slot file
# should save slot 1 as JSON with required GameState fields including world_seed
# should load slot 1 JSON into GameState and return success
# should preserve world_seed exactly across save and load
# should apply loaded world_seed to ProcGenWorld and regenerate deterministically via generate_world() intent
# should keep save slots isolated so saving slot 2 does not modify slot 1 data
# should overwrite only the targeted slot file and leave the other slots unchanged
# should return false and keep current state unchanged when slot JSON is corrupt
