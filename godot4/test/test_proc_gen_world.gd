extends GutTest

const GOOD_FISH = preload("res://trading_system/good_fish.tres")
const GOOD_GRAIN = preload("res://trading_system/good_grain.tres")
const GOOD_WOOD = preload("res://trading_system/good_wood.tres")


var proc_gen_world: ProcGenWorld = null


func before_each():
	proc_gen_world = ProcGenWorld.new()


func after_each():
	proc_gen_world.free()


func test_get_good_by_type():
	# arrange
	var fish = Good.new()
	fish.good_resource = GOOD_FISH
	var grain = Good.new()
	grain.good_resource = GOOD_GRAIN
	var good_root = Node2D.new()
	good_root.add_child(fish)
	good_root.add_child(grain)
	proc_gen_world.goods = good_root
	
	#act
	var result = proc_gen_world.get_goods_by_type(GOOD_FISH)
	
	# assert
	assert_eq(result.size(), 1, "Should get all fishs in world")
	
	# tear down
	good_root.free()


func test_generate_minimap():
	# arrange
	var towns_root = Node2D.new()
	proc_gen_world.towns = towns_root
	
	# act
	var image = proc_gen_world.generate_minimap()
	
	# assert
	assert_not_null(image)
	assert_gt(image.get_width(), 0)
	assert_gt(image.get_height(), 0)

	# tear down
	towns_root.free()
	
	# image.save_png("res://test/test_proc_gen_world.png")
	
