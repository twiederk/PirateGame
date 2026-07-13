class_name TownGenerator


@export var town_percentage: float = 0.05

const TOWN_HABOR = preload("res://world/town_habor.tres")
const TOWN_FARM = preload("res://world/town_farm.tres")
const TOWN_WOOD_CAMP = preload("res://world/town_wood_camp.tres")

const TownScene = preload("res://world/town.tscn")


func generate_towns(proc_gen_world: ProcGenWorld) -> Array[Town]:
	var width = proc_gen_world.width
	var sand_arr = proc_gen_world.sand_arr
	var grass_arr = proc_gen_world.grass_arr
	var tree_arr = proc_gen_world.tree_arr
	var towns_root = proc_gen_world.towns
	
	var max_cities = int(width * town_percentage)
	var coast_arr = sand_arr.filter(func(pos): return not (pos in grass_arr) and proc_gen_world.is_coast(pos * ProcGenWorld.TILE_SIZE))
	var farm_arr = grass_arr.filter(func(pos): return not (pos in tree_arr))
	
	for i in range(max_cities * 1.0):
		var town_name = TownResource.name_dictionary[TownResource.Type.Habor].pick_random()
		var town = _create_town(TOWN_HABOR, town_name, coast_arr.pick_random())
		towns_root.add_child(town)
		
	for i in range(max_cities * 0.5):
		var town_name = TownResource.name_dictionary[TownResource.Type.Farm].pick_random()
		var town = _create_town(TOWN_FARM, town_name, farm_arr.pick_random())
		towns_root.add_child(town)

	for i in range(max_cities * 0.5):
		var town_name = TownResource.name_dictionary[TownResource.Type.Woodcamp].pick_random()
		var town = _create_town(TOWN_WOOD_CAMP, town_name, tree_arr.pick_random())
		towns_root.add_child(town)

	return proc_gen_world.get_towns()


func _create_town(town_resource: TownResource, town_name: String, pos: Vector2i) -> Town:
	var town: Town = TownScene.instantiate()
	town.town_resource = town_resource
	town.town_name = town_name
	town.name = town_name
	town.global_position = pos * ProcGenWorld.TILE_SIZE + ProcGenWorld.TOWN_OFFSET
	return town
