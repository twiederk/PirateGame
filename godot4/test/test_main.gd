extends GutTest

var main: Main = null

func before_each():
	main = Main.new()


func after_each():
	main.free()


func test_seed_new_game():
	# arrange
	var proc_gen_world = ProcGenWorld.new()
	main.proc_gen_world  = proc_gen_world
	SaveManager.load_game_state = {}
	
	# act
	var result = main._get_seed()
	
	# assert
	assert_eq(result, 0, "Should start with random seed.")
	
	# tear down
	proc_gen_world.free()


func test_seed_load_game():
	# arrange
	SaveManager.load_game_state = {
		"world": {
			"seed_value": 24680
		}
	}
	
	# act
	var result = main._get_seed()
	
	# assert
	assert_eq(result, 24680, "Should start with loaded seed.")
