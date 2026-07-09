extends GutTest


var fog_sector_manager: FogSectorManager
var fog_sector_manager_serializer: FogSectorManagerSerializer


func before_each():
	fog_sector_manager = FogSectorManager.new()
	fog_sector_manager_serializer = FogSectorManagerSerializer.new()


func after_each():
	fog_sector_manager.free()


func test_get_save_data():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	fog_sector_manager.mark_sector_visited(Vector2i(0, 0))
	fog_sector_manager.mark_sector_visited(Vector2i(2, 3))
	fog_sector_manager.mark_sector_visited(Vector2i(5, 5))

	# act
	var save_data = fog_sector_manager_serializer.get_save_data(fog_sector_manager)

	# assert
	assert_true(save_data.has("fog"), "Save data should contain fog section")
	assert_eq(save_data.fog.world_width, 256, "Save data should include world_width")
	assert_eq(save_data.fog.world_height, 192, "Save data should include world_height")
	assert_eq(save_data.fog.sector_size, 16, "Save data should include sector_size")
	assert_eq(save_data.fog.visited_sectors.size(), 16 * 12, "Save data should include visited_sectors array")
	assert_true(save_data.fog.visited_sectors[0], "Sector (0,0) should be marked as visited")
	assert_true(save_data.fog.visited_sectors[3 * 16 + 2], "Sector (2,3) should be marked as visited")
	assert_true(save_data.fog.visited_sectors[5 * 16 + 5], "Sector (5,5) should be marked as visited")


func test_set_save_data():
	# arrange
	var visited_array = []
	visited_array.resize(16 * 12)
	visited_array.fill(false)
	visited_array[0] = true
	visited_array[3 * 16 + 2] = true
	visited_array[5 * 16 + 5] = true
	
	var save_data = {
		"fog": {
			"world_width": 256,
			"world_height": 192,
			"sector_size": 16,
			"visited_sectors": visited_array,
		}
	}

	# act
	fog_sector_manager_serializer.set_save_data(fog_sector_manager, save_data)

	# assert
	assert_eq(fog_sector_manager.world_width, 256, "Should restore world_width")
	assert_eq(fog_sector_manager.world_height, 192, "Should restore world_height")
	assert_eq(fog_sector_manager.sector_size, 16, "Should restore sector_size")
	assert_eq(fog_sector_manager.sector_width, 16, "Should calculate sector_width correctly")
	assert_eq(fog_sector_manager.sector_height, 12, "Should calculate sector_height correctly")
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(0, 0)), "Sector (0,0) should be visited")
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(2, 3)), "Sector (2,3) should be visited")
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(5, 5)), "Sector (5,5) should be visited")
	assert_false(fog_sector_manager.is_sector_visited(Vector2i(1, 1)), "Sector (1,1) should not be visited")


func test_set_save_data_missing_data_use_defaults():
	# arrange
	var save_data = {
		"fog": {
			"world_width": 256,
			"world_height": 192,
			"sector_size": 16,
		}
	}

	# act
	fog_sector_manager_serializer.set_save_data(fog_sector_manager, save_data)

	# assert
	assert_eq(fog_sector_manager.world_width, 256, "Should restore world_width")
	assert_eq(fog_sector_manager.world_height, 192, "Should restore world_height")
	assert_eq(fog_sector_manager.sector_size, 16, "Should restore sector_size")
	var total_sectors = fog_sector_manager.sector_width * fog_sector_manager.sector_height
	for i in range(total_sectors):
		assert_false(fog_sector_manager.visited_sectors[i], "All sectors should be false (not visited) when missing from save data")
