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


func _build_segment(start_x: int, end_x: int, max_y: int) -> Array[Vector2i]:
	var segment: Array[Vector2i] = []
	for x in range(start_x, end_x):
		for y in range(0, max_y):
			segment.append(Vector2i(x, y))
	return segment


func test_get_minimap_image():
	# arrange
	var biome_properties = [
		"deep_water_arr",
		"shallow_water_arr",
		"sand_arr",
		"grass_arr",
		"cliff_arr",
		"tree_arr",
	]
	var towns_root = Node2D.new()
	proc_gen_world.towns = towns_root

	var segment_width = int(proc_gen_world.width * (1.0 / 6.0))
	var start_x = 0
	for i in range(biome_properties.size()):
		var town = Town.new()
		town.position = Vector2(start_x + (segment_width * 0.5), proc_gen_world.height * 0.5) * 16
		towns_root.add_child(town)
		
		var end_x = start_x + segment_width
		proc_gen_world.set(biome_properties[i], _build_segment(start_x, end_x, proc_gen_world.height))
		start_x = end_x

	
	# act
	var image = proc_gen_world.get_minimap_image()
	
	# assert
	assert_not_null(image)
	assert_gt(image.get_width(), 0)
	assert_gt(image.get_height(), 0)

	# tear down
	towns_root.free()
	
	image.save_png("res://test/test_proc_gen_world.png")


func test_get_town_without_treasure_returns_town_without_treasure():
	# arrange
	var town_with_treasure = Town.new()
	var town_without_treasure = Town.new()
	var treasure = Treasure.new()
	town_with_treasure.treasure = treasure

	var all_towns: Array[Town] = []
	all_towns.append(town_with_treasure)
	all_towns.append(town_without_treasure)

	# act
	var result = proc_gen_world._get_town_without_treasure(all_towns)

	# assert
	assert_eq(result, town_without_treasure, "Should return the town without treasure")

	# tear down
	treasure.free()
	town_with_treasure.free()
	town_without_treasure.free()
