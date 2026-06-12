extends GutTest

const SLOT_NUMBER: int = 100

var player: Player = null
var proc_gen_world: ProcGenWorld = null


func before_each():
	player = Player.new()
	proc_gen_world = ProcGenWorld.new()


func after_each():
	player.free()
	proc_gen_world.free()


func test_collect_game_state():
	# arrange
	player.gold = 321
	player.position = Vector2(17, 29)
	proc_gen_world.seed_value = 12345

	# act
	var game_state = SaveManager._collect_game_state(player, proc_gen_world)

	# assert
	assert_eq(game_state["player"]["gold"], 321, "Collected data should include player gold")
	assert_eq(game_state["player"]["position"]["x"], 17.0, "Collected data should include player position")
	assert_eq(game_state["player"]["position"]["y"], 29.0, "Collected data should include player position")
	assert_eq(game_state["world_seed"], 12345, "Collected data should include world seed")


func test_save_file():
	# arrange
	var save_path = "user://saves/save_slot_%d.json" % SLOT_NUMBER
	var game_state: Dictionary = {
		"world_seed": 67890,
		"player": {
			"gold": 99,
		}
	}

	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)

	# act
	SaveManager._save_file(game_state, SLOT_NUMBER)

	# assert
	assert_true(FileAccess.file_exists(save_path), "Save file should be created for the target slot")

	var save_file = FileAccess.open(save_path, FileAccess.READ)
	assert_not_null(save_file, "Save file should be readable")

	var saved_text = save_file.get_as_text()
	save_file.close()

	var parsed_state = JSON.parse_string(saved_text)
	var expected_state = JSON.parse_string(JSON.stringify(game_state))
	assert_eq(parsed_state, expected_state, "Saved file content should match provided game state")


func test_save():
	# arrange
	player.gold = 123
	player.position = Vector2(45, 67)
	proc_gen_world.seed_value = 24680

	var save_path = "user://saves/save_slot_%d.json" % SLOT_NUMBER

	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)

	# act
	SaveManager.save(player, proc_gen_world, SLOT_NUMBER)

	# assert
	assert_true(FileAccess.file_exists(save_path), "Save file should be created for the target slot")

	# tear down
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)


func test_load():
	# arrange
	var save_path = "user://saves/save_slot_%d.json" % SLOT_NUMBER
	var game_state: Dictionary = {
		"world_seed": 13579,
		"player": {
			"gold": 250,
			"position": {
				"x": 12,
				"y": 34,
			},
		}
	}

	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)

	SaveManager._save_file(game_state, SLOT_NUMBER)

	# act
	var result = SaveManager.load(SLOT_NUMBER)

	# assert
	assert_true(result, "Should return true when game is successfully loaded")
	var expected_state = JSON.parse_string(JSON.stringify(game_state))
	assert_eq(SaveManager.load_game_state, expected_state, "Loaded game state should match saved game state")

	# tear down
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
