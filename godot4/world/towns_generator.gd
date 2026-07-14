class_name TownsGenerator
extends Generator

@export var town_percentage: float = 0.05

const TOWN_HABOR = preload("res://world/town_habor.tres")
const TOWN_FARM = preload("res://world/town_farm.tres")
const TOWN_WOOD_CAMP = preload("res://world/town_wood_camp.tres")

const TOWN_OFFSET: Vector2i = Vector2i(8, 8)

const TownScene = preload("res://world/town.tscn")


func generate_towns(proc_gen_world: ProcGenWorld) -> void:
	var width = proc_gen_world.width
	var grass_arr = proc_gen_world.grass_arr
	var tree_arr = proc_gen_world.tree_arr
	var towns_root = proc_gen_world.towns
	
	var max_cities = int(width * town_percentage)
	var farm_arr = grass_arr.filter(func(pos): return not (pos in tree_arr))
	
	# Habors
	var habor_positions: Array[Vector2i] = _create_habor_positions(proc_gen_world)
	for i in range(max_cities * 1.0):
		var town_name = TownResource.name_dictionary[TownResource.Type.Habor].pick_random()
		var spawn_position = habor_positions.pick_random()
		var town = _create_town(TOWN_HABOR, town_name, spawn_position)
		towns_root.add_child(town)
	
	# Farms
	for i in range(max_cities * 0.5):
		var town_name = TownResource.name_dictionary[TownResource.Type.Farm].pick_random()
		var town = _create_town(TOWN_FARM, town_name, farm_arr.pick_random())
		towns_root.add_child(town)

	# Woodcamps
	for i in range(max_cities * 0.5):
		var town_name = TownResource.name_dictionary[TownResource.Type.Woodcamp].pick_random()
		var town = _create_town(TOWN_WOOD_CAMP, town_name, tree_arr.pick_random())
		towns_root.add_child(town)


func _create_town(town_resource: TownResource, town_name: String, pos: Vector2i) -> Town:
	var town: Town = TownScene.instantiate()
	town.town_resource = town_resource
	town.town_name = town_name
	town.name = town_name
	town.global_position = pos * ProcGenWorld.TILE_SIZE + TOWN_OFFSET
	return town


func _create_habor_positions(proc_gen_world: ProcGenWorld) -> Array[Vector2i]:
	return proc_gen_world.sand_arr.filter(func(pos): return _is_habor_position(pos, proc_gen_world))


func _is_habor_position(pos: Vector2i, proc_gen_world: ProcGenWorld) -> bool:
	var width = proc_gen_world.width
	var height = proc_gen_world.height
	return proc_gen_world.is_coast(pos * ProcGenWorld.TILE_SIZE) and _is_distance_from_border(pos, Vector2(5, 5), width, height)
