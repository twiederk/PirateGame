extends GutTest

var main: Main = null

func before_each():
	main = Main.new()


func after_each():
	main.free()


func test_seed_new_game():
	# arrange
	SaveManager.load_game_state = {}
	
	# act
	var seed = main._get_seed()
	
	# assert
	assert_eq(seed, 0, "Should start with random seed.")


func test_seed_load_game():
	# arrange
	SaveManager.load_game_state = {
		"world_seed": 24680
	}
	
	# act
	var seed = main._get_seed()
	
	# assert
	assert_eq(seed, 24680, "Should start with loaded seed.")
