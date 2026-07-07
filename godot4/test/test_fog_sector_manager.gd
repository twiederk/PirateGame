extends GutTest

var fog_sector_manager: FogSectorManager


func before_each():
	fog_sector_manager = FogSectorManager.new()
	add_child(fog_sector_manager)


func after_each():
	if fog_sector_manager:
		fog_sector_manager.free()


# ============================================================================
# POSITION-TO-SECTOR CONVERSION TESTS (Simple → Complex)
# ============================================================================


func test_convert_origin_position_zero_zero_to_sector():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var position = Vector2(0, 0)
	
	# act
	var sector = fog_sector_manager.world_position_to_sector(position)
	
	# assert
	assert_eq(sector, Vector2(0, 0), "Origin position (0,0) should map to sector (0,0)")


func test_convert_position_within_first_sector_to_sector_zero_zero():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var position = Vector2(8, 8)
	
	# act
	var sector = fog_sector_manager.world_position_to_sector(position)
	
	# assert
	assert_eq(sector, Vector2i(0, 0), "Position (8,8) should map to sector (0,0) as integer sector coordinates")


func test_convert_position_at_sector_boundary_to_next_sector():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var position = Vector2(16, 0)
	
	# act
	var sector = fog_sector_manager.world_position_to_sector(position)
	
	# assert
	assert_eq(sector, Vector2i(1, 0), "Position at x=16 boundary should map to sector (1,0) using floor(x/16)")


func test_convert_position_in_middle_world_to_sector():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var position = Vector2(100, 80)
	
	# act
	var sector = fog_sector_manager.world_position_to_sector(position)
	
	# assert
	assert_eq(sector, Vector2i(6, 5), "Position (100,80) should map to sector (6,5) using floor(x/16), floor(y/16)")


func test_convert_position_at_world_boundary_to_sector():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var position = Vector2(240, 176)
	
	# act
	var sector = fog_sector_manager.world_position_to_sector(position)
	
	# assert
	assert_eq(sector, Vector2i(15, 11), "Position (240,176) should map to last valid sector (15,11)")


func test_convert_position_beyond_world_width():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var position = Vector2(300, 80)
	
	# act
	var sector = fog_sector_manager.world_position_to_sector(position)
	
	# assert
	assert_eq(sector, Vector2i(18, 5), "Position beyond world width should still map deterministically via floor division")


func test_convert_negative_position_to_negative_sector():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var position = Vector2(-10, -10)
	
	# act
	var sector = fog_sector_manager.world_position_to_sector(position)
	
	# assert
	assert_eq(sector, Vector2i(-1, -1), "Negative position should map to negative sector coordinates via floor division")


# ============================================================================
# SECTOR-TO-INDEX CONVERSION TESTS (Medium)
# ============================================================================


func test_convert_sector_zero_zero_to_index_zero():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var sector = Vector2i(0, 0)
	
	# act
	var index = fog_sector_manager.sector_to_index(sector)
	
	# assert
	assert_eq(index, 0, "Sector (0,0) should map to flat index 0")


func test_convert_sector_one_zero_to_index_one():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var sector = Vector2i(1, 0)
	
	# act
	var index = fog_sector_manager.sector_to_index(sector)
	
	# assert
	assert_eq(index, 1, "Sector (1,0) should map to flat index 1")


func test_convert_sector_zero_one_to_index_sector_width():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var sector = Vector2i(0, 1)
	
	# act
	var index = fog_sector_manager.sector_to_index(sector)
	
	# assert
	assert_eq(index, 16, "Sector (0,1) should map to index sector_width (16)")


func test_convert_sector_at_boundary_to_index():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var sector = Vector2i(15, 11)  # Last sector in 16x12 grid
	
	# act
	var index = fog_sector_manager.sector_to_index(sector)
	
	# assert
	assert_eq(index, 191, "Last sector (15,11) should map to index 191")


# ============================================================================
# VISITED STATE OPERATIONS TESTS (Medium → Complex)
# ============================================================================


func test_mark_sector_as_visited():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var sector = Vector2i(5, 3)
	
	# act
	fog_sector_manager.mark_sector_visited(sector)
	fog_sector_manager.mark_sector_visited(sector)
	
	# assert
	assert_true(fog_sector_manager.is_sector_visited(sector), "Marking a sector visited should be idempotent and leave it visited")


func test_query_marked_sector_returns_true():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var sector = Vector2i(5, 3)
	fog_sector_manager.mark_sector_visited(sector)
	
	# act
	var is_visited = fog_sector_manager.is_sector_visited(sector)
	
	# assert
	assert_true(is_visited, "Querying a marked sector should return true")


func test_query_unmarked_sector_returns_false():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var sector = Vector2i(5, 3)
	
	# act
	var is_visited = fog_sector_manager.is_sector_visited(sector)
	
	# assert
	assert_false(is_visited, "Querying an unmarked sector should return false")


func test_mark_multiple_sectors_as_visited():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var sectors = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]
	
	# act
	for sector in sectors:
		fog_sector_manager.mark_sector_visited(sector)
	fog_sector_manager.mark_sector_visited(Vector2i(1, 0))
	
	# assert
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(0, 0)), "Sector (0,0) should be visited")
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(1, 0)), "Sector (1,0) should be visited")
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(0, 1)), "Sector (0,1) should be visited")
	assert_false(fog_sector_manager.is_sector_visited(Vector2i(2, 2)), "Unrelated sector should remain unvisited")


# ============================================================================
# CAMERA VIEWPORT REVEAL TESTS (Complex)
# ============================================================================


func test_reveal_sectors_in_camera_viewport_rectangle():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var viewport_rect = Rect2(0, 0, 64, 64)
	
	# act
	fog_sector_manager.reveal_sectors_in_viewport(viewport_rect)
	
	# assert
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(0, 0)), "Viewport should reveal top-left sector")
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(3, 3)), "Viewport should reveal bottom-right overlapping sector")
	assert_false(fog_sector_manager.is_sector_visited(Vector2i(4, 0)), "Viewport should not reveal sectors outside overlap")


func test_reveal_sectors_handles_viewport_at_world_boundary():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var viewport_rect = Rect2(230, 170, 50, 50)
	
	# act
	fog_sector_manager.reveal_sectors_in_viewport(viewport_rect)
	
	# assert
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(14, 10)), "Boundary viewport should reveal clamped sector (14,10)")
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(15, 11)), "Boundary viewport should reveal clamped sector (15,11)")
	assert_false(fog_sector_manager.is_sector_visited(Vector2i(13, 10)), "Boundary viewport should not reveal non-overlapping left neighbor")
	assert_false(fog_sector_manager.is_sector_visited(Vector2i(15, 9)), "Boundary viewport should not reveal non-overlapping upper neighbor")


func test_reveal_sectors_handles_partial_sector_overlap():
	# arrange
	fog_sector_manager.initialize(256, 192, 16)
	var viewport_rect = Rect2(10, 10, 20, 20)  # Overlaps multiple sectors partially
	
	# act
	fog_sector_manager.reveal_sectors_in_viewport(viewport_rect)
	
	# assert
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(0, 0)), "Partial overlap should reveal sector (0,0)")
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(1, 0)), "Partial overlap should reveal sector (1,0)")
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(0, 1)), "Partial overlap should reveal sector (0,1)")
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(1, 1)), "Partial overlap should reveal sector (1,1)")
	assert_false(fog_sector_manager.is_sector_visited(Vector2i(2, 2)), "Partial overlap should not reveal non-overlapping sectors")


func test_update_fog_uses_active_camera():
	# arrange
	fog_sector_manager.initialize(32, 32, 16)
	var camera = autofree(Camera2D.new())
	add_child(camera)
	camera.position = Vector2(8, 8)
	camera.zoom = Vector2.ONE
	camera.make_current()

	# act
	fog_sector_manager.update_fog(Vector2i(16, 16))

	# assert
	assert_true(fog_sector_manager.is_sector_visited(Vector2i(0, 0)), "Active camera viewport should reveal overlapping sectors")


func test_generate_minimap_with_fog_keeps_visited_and_hides_unvisited_pixels():
	# arrange
	fog_sector_manager.initialize(32, 32, 16)
	var base_minimap := Image.create_empty(32, 32, false, Image.FORMAT_RGBA8)
	base_minimap.fill(Color.BLACK)
	base_minimap.set_pixelv(Vector2i(5, 5), Color.DARK_BLUE)
	base_minimap.set_pixelv(Vector2i(20, 5), Color.DARK_BLUE)
	fog_sector_manager.set_base_minimap_image(base_minimap)
	fog_sector_manager.mark_sector_visited(Vector2i(0, 0))

	# act
	var minimap_with_fog: Image = fog_sector_manager.generate_minimap_with_fog()
	var visited_pixel: Color = minimap_with_fog.get_pixelv(Vector2i(5, 5))
	var unvisited_pixel: Color = minimap_with_fog.get_pixelv(Vector2i(20, 5))

	# assert
	assert_eq(visited_pixel, Color.DARK_BLUE, "Visited sector pixel should preserve base minimap color")
	assert_eq(unvisited_pixel, Color.BLACK, "Unvisited sector pixel should be covered by fog")


func test_generate_minimap_with_fog_is_bounds_safe_on_edges():
	# arrange
	fog_sector_manager.initialize(32, 32, 16)
	var base_minimap := Image.create_empty(32, 32, false, Image.FORMAT_RGBA8)
	base_minimap.fill(Color.BLACK)
	base_minimap.set_pixelv(Vector2i(0, 0), Color.DARK_BLUE)
	base_minimap.set_pixelv(Vector2i(31, 31), Color.DARK_BLUE)
	fog_sector_manager.set_base_minimap_image(base_minimap)
	fog_sector_manager.mark_sector_visited(Vector2i(0, 0))

	# act
	var minimap_with_fog: Image = fog_sector_manager.generate_minimap_with_fog()
	var top_left_pixel: Color = minimap_with_fog.get_pixelv(Vector2i(0, 0))
	var bottom_right_pixel: Color = minimap_with_fog.get_pixelv(Vector2i(31, 31))

	# assert
	assert_eq(top_left_pixel, Color.DARK_BLUE, "Visited edge pixel should keep its base color")
	assert_eq(bottom_right_pixel, Color.BLACK, "Unvisited edge pixel should be black without out-of-bounds issues")
