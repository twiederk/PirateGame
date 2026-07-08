class_name FogSectorManager
extends Node


const DEFAULT_SECTOR_SIZE: int = 4

var world_width: int
var world_height: int
var sector_size: int
var sector_width: int
var sector_height: int
var visited_sectors: Array = []
var base_minimap_image: Image


func initialize(p_world_width: int, p_world_height: int, p_sector_size: int = DEFAULT_SECTOR_SIZE) -> void:
	world_width = p_world_width
	world_height = p_world_height
	sector_size = p_sector_size
	@warning_ignore("integer_division")
	sector_width = world_width / sector_size
	@warning_ignore("integer_division")
	sector_height = world_height / sector_size
	var total_sectors = sector_width * sector_height
	_reset_visited_sectors(total_sectors)


func _reset_visited_sectors(total_sectors: int) -> void:
	visited_sectors = []
	visited_sectors.resize(total_sectors)
	visited_sectors.fill(false)


func world_position_to_sector(position: Vector2):
	if position == Vector2.ZERO:
		return Vector2.ZERO

	var sector_x: int = int(floor(position.x / float(sector_size)))
	var sector_y: int = int(floor(position.y / float(sector_size)))
	return Vector2i(sector_x, sector_y)


func sector_to_index(sector: Vector2i) -> int:
	return sector.y * sector_width + sector.x


func is_sector_in_bounds(sector: Vector2i) -> bool:
	return sector.x >= 0 and sector.y >= 0 and sector.x < sector_width and sector.y < sector_height


func mark_sector_visited(sector: Vector2i) -> void:
	if not is_sector_in_bounds(sector):
		return
	visited_sectors[sector_to_index(sector)] = true


func is_sector_visited(sector: Vector2i) -> bool:
	if not is_sector_in_bounds(sector):
		return false
	return bool(visited_sectors[sector_to_index(sector)])


func reveal_sectors_in_viewport(viewport_rect: Rect2) -> void:
	if sector_width <= 0 or sector_height <= 0:
		return

	var world_max_x = world_width - 1
	var world_max_y = world_height - 1
	if world_max_x < 0 or world_max_y < 0:
		return

	var rect_min_x = int(floor(viewport_rect.position.x))
	var rect_min_y = int(floor(viewport_rect.position.y))
	var rect_max_x = int(ceil(viewport_rect.position.x + viewport_rect.size.x)) - 1
	var rect_max_y = int(ceil(viewport_rect.position.y + viewport_rect.size.y)) - 1

	var clamped_min_x = clamp(rect_min_x, 0, world_max_x)
	var clamped_min_y = clamp(rect_min_y, 0, world_max_y)
	var clamped_max_x = clamp(rect_max_x, 0, world_max_x)
	var clamped_max_y = clamp(rect_max_y, 0, world_max_y)

	if clamped_min_x > clamped_max_x or clamped_min_y > clamped_max_y:
		return

	var min_sector = world_position_to_sector(Vector2(clamped_min_x, clamped_min_y))
	var max_sector = world_position_to_sector(Vector2(clamped_max_x, clamped_max_y))

	for y in range(min_sector.y, max_sector.y + 1):
		for x in range(min_sector.x, max_sector.x + 1):
			mark_sector_visited(Vector2i(x, y))


func update_fog(tile_size: Vector2i) -> void:
	if tile_size.x <= 0 or tile_size.y <= 0:
		return

	var viewport_rect_world: Rect2 = _get_fog_viewport_rect()
	if viewport_rect_world.size.x <= 0 or viewport_rect_world.size.y <= 0:
		return

	var viewport_rect_tiles: Rect2 = _world_rect_to_tile_rect(viewport_rect_world, tile_size)
	if viewport_rect_tiles.size.x <= 0 or viewport_rect_tiles.size.y <= 0:
		return

	reveal_sectors_in_viewport(viewport_rect_tiles)


func set_base_minimap_image(minimap_image: Image) -> void:
	if minimap_image == null:
		base_minimap_image = null
		return
	base_minimap_image = minimap_image.duplicate()


func generate_minimap_with_fog() -> Image:
	if base_minimap_image == null:
		return null
	var minimap_with_fog: Image = base_minimap_image.duplicate()
	apply_fog_overlay(minimap_with_fog)
	return minimap_with_fog


func _world_rect_to_tile_rect(world_rect: Rect2, tile_size: Vector2i) -> Rect2:
	var tile_position := Vector2(
		world_rect.position.x / float(tile_size.x),
		world_rect.position.y / float(tile_size.y)
	)
	var tile_size_vec := Vector2(
		world_rect.size.x / float(tile_size.x),
		world_rect.size.y / float(tile_size.y)
	)
	return Rect2(tile_position, tile_size_vec)


func _get_fog_viewport_rect() -> Rect2:
	var viewport := get_viewport()
	if viewport == null:
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	var camera: Camera2D = viewport.get_camera_2d()
	if camera == null:
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	var viewport_size: Vector2 = viewport.get_visible_rect().size * camera.zoom
	var visible_origin: Vector2 = camera.get_screen_center_position() - (viewport_size * 0.5)
	return Rect2(visible_origin, viewport_size)


func apply_fog_overlay(minimap: Image) -> void:
	var sector_grid_size := Vector2i(sector_width, sector_height)
	for sector_y in range(sector_grid_size.y):
		for sector_x in range(sector_grid_size.x):
			var sector_position := Vector2i(sector_x, sector_y)
			if not is_sector_visited(sector_position):
				_draw_fog_sector_overlay(minimap, sector_position)


func _draw_fog_sector_overlay(minimap: Image, sector: Vector2i) -> void:
	var sector_bounds := _get_fog_sector_pixel_bounds(minimap, sector, sector_size)

	for y in range(sector_bounds.position.y, sector_bounds.end.y + 1):
		for x in range(sector_bounds.position.x, sector_bounds.end.x + 1):
			var pixel_pos := Vector2i(x, y)
			if _is_in_minimap_bounds(minimap, pixel_pos):
				minimap.set_pixelv(pixel_pos, Color.BLACK)


func _get_fog_sector_pixel_bounds(minimap: Image, sector: Vector2i, p_sector_size: int) -> Rect2i:
	var start_x: int = sector.x * p_sector_size
	var start_y: int = sector.y * p_sector_size
	var end_x: int = min(start_x + p_sector_size - 1, minimap.get_width() - 1)
	var end_y: int = min(start_y + p_sector_size - 1, minimap.get_height() - 1)
	return Rect2i(start_x, start_y, end_x - start_x + 1, end_y - start_y + 1)


func _is_in_minimap_bounds(minimap: Image, pixel_pos: Vector2i) -> bool:
	return pixel_pos.x >= 0 and pixel_pos.y >= 0 and pixel_pos.x < minimap.get_width() and pixel_pos.y < minimap.get_height()
