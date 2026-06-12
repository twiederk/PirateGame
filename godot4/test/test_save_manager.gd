extends GutTest

var player: Player = null
var proc_gen_world: ProcGenWorld = null


func before_each():
	player = Player.new()
	proc_gen_world = ProcGenWorld.new()


func after_each():
	player.free()
	proc_gen_world.free()


func test_collect_save_data():
	# arrange
	player.gold = 321
	player.position = Vector2(17, 29)
	proc_gen_world.seed_value = 12345

	# act
	var game_state = SaveManager.collect_save_data(player, proc_gen_world)

	# assert
	assert_eq(game_state["player"]["gold"], 321, "Collected data should include player gold")
	assert_eq(game_state["player"]["position"], Vector2(17, 29), "Collected data should include player position")
	assert_eq(game_state["world_seed"], 12345, "Collected data should include world seed")

# Phase 2 scope only: SaveManager + GameState core save/load mechanics (no pause/load menu UI).

# should collect gold, position from player
# should collect seed from ProcGenWorld
# should collect all necessary save data from Player and ProcGenWorld into a single GameState dictionary for saving
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
