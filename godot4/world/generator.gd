class_name Generator

const INVALID_TILE_POSITION: Vector2i = Vector2i(-1, -1)


func _pick_hidden_tile_position(viewport: Viewport, positions: Array[Vector2i]) -> Vector2i:
	if positions.is_empty():
		return INVALID_TILE_POSITION

	var hidden_positions: Array[Vector2i] = positions.filter(func(pos): return not _is_tile_position_visible(viewport, pos))
	if hidden_positions.is_empty():
		return INVALID_TILE_POSITION

	return hidden_positions.pick_random()


func _is_tile_position_visible(viewport: Viewport, tile_position: Vector2i) -> bool:
	if viewport == null:
		return false

	var camera: Camera2D = viewport.get_camera_2d()
	if camera == null:
		return false

	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var visible_size: Vector2 = viewport_size * camera.zoom
	var visible_origin: Vector2 = camera.get_screen_center_position() - (visible_size * 0.5)
	var visible_rect := Rect2(visible_origin, visible_size)

	var tile_size: Vector2i = ProcGenWorld.TILE_SIZE
	var tile_world_rect := Rect2(Vector2(tile_position * tile_size), Vector2(tile_size))
	return visible_rect.intersects(tile_world_rect)


func _is_distance_from_border(pos: Vector2i, distance: Vector2, width: int, height: int) -> bool:
	var min_x := int(ceil(distance.x))
	var min_y := int(ceil(distance.y))
	var max_x := width - min_x - 1
	var max_y := height - min_y - 1

	if max_x < min_x or max_y < min_y:
		return false

	return pos.x >= min_x and pos.x <= max_x and pos.y >= min_y and pos.y <= max_y
