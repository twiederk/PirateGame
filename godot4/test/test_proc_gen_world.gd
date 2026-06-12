extends GutTest

var proc_gen_world: ProcGenWorld = null


func before_each():
	proc_gen_world = ProcGenWorld.new()


func after_each():
	proc_gen_world.free()


func test_get_save_data():
	# arrange
	proc_gen_world.seed_value = 12345

	# act
	var save_data = proc_gen_world.get_save_data()

	# assert
	assert_eq(save_data["world_seed"], 12345, "Save data should include the world seed")
