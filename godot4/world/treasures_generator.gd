class_name TreasuresGenerator


@export var treasure_percentage: float = 0.02
@export var treasure_rareness: Array[TreasureResource] = [
	preload("res://world/treasure_common.tres"),
	preload("res://world/treasure_common.tres"),
	preload("res://world/treasure_common.tres"),
	preload("res://world/treasure_rare.tres"),
	preload("res://world/treasure_rare.tres"),
	preload("res://world/treasure_very_rare.tres"),
]

const INVALID_TILE_POSITION: Vector2i = Vector2i(-1, -1)

const TreasureScene = preload("res://world/treasure.tscn")



func generate_treasures(proc_gen_world: ProcGenWorld) -> void:
	var width = proc_gen_world.width
	var height = proc_gen_world.height
	var sand_arr = proc_gen_world.sand_arr
	var treasures_root = proc_gen_world.treasures
	
	var max_treasures = int(width * treasure_percentage)
	var treasures_to_generate = max_treasures - proc_gen_world.get_treasures().size()
	var treasure_resource = treasure_rareness.pick_random()
	for i in range(treasures_to_generate):
		var spawn_position = _pick_distance_from_border_tile_position(sand_arr, treasure_resource.treasure_map_size * 0.5, width, height)
		if spawn_position == INVALID_TILE_POSITION:
			continue
		var treasure = _create_treasure(spawn_position, treasure_resource, proc_gen_world)
		var town = _get_town_without_treasure(proc_gen_world.get_towns())
		town.treasure = treasure
		treasures_root.add_child(treasure)


func _pick_distance_from_border_tile_position(positions: Array[Vector2i], distance: Vector2, width: int, height: int) -> Vector2i:
	if positions.is_empty():
		return INVALID_TILE_POSITION
	
	var valid_positions: Array[Vector2i] = positions.filter(func(pos): return _is_distance_from_border(pos, distance, width, height))
	if valid_positions.is_empty():
		return INVALID_TILE_POSITION

	return valid_positions.pick_random()


func _create_treasure(spawn_position: Vector2i, treasure_resource: TreasureResource, proc_gen_world: ProcGenWorld) -> Treasure:
		var treasure: Treasure = TreasureScene.instantiate()
		treasure.resource = treasure_resource
		treasure.price = treasure_resource.get_price()
		treasure.gold = treasure_resource.get_gold()
		var treasure_map_image = proc_gen_world.create_treasure_map(treasure.global_position, treasure.resource.treasure_map_size)
		treasure.texture = ImageTexture.create_from_image(treasure_map_image)
		treasure.global_position = spawn_position * ProcGenWorld.TILE_SIZE
		return treasure


func _get_town_without_treasure(all_towns: Array[Town]) -> Town:
	var towns_without_treasure = all_towns.filter(func(town): return not town.has_treasure())
	return towns_without_treasure.pick_random()


func _is_distance_from_border(pos: Vector2i, distance: Vector2, width: int, height: int) -> bool:
	var min_x := int(ceil(distance.x))
	var min_y := int(ceil(distance.y))
	var max_x := width - min_x - 1
	var max_y := height - min_y - 1

	if max_x < min_x or max_y < min_y:
		return false

	return pos.x >= min_x and pos.x <= max_x and pos.y >= min_y and pos.y <= max_y
