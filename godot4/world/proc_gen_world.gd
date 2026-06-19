class_name ProcGenWorld
extends Node2D

@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D
@export var seed_value: int = 0
@export var city_denstity: int = 20

const TownScene = preload("res://world/town.tscn")
const HaborTownResource = preload("res://world/town_habor.tres")
const FarmTownResource = preload("res://world/town_farm.tres")
const WoodCampTownResource = preload("res://world/town_wood_camp.tres")

const DEEP_WATER_LEVEL: float = -0.2
const WATER_LEVEL: float = 0
const GRASS_LEVEL: float = 0.2
const FIELD_LEVEL: float = 0.3
const CLIFF_LEVEL: float = 0.6
const TREE_CHANCE: float = 0.0
const PALM_TREE_CHANCE: float = 0.35

const WORLD_TILE_SET = 0

const GRASS_IN_SAND_TERRAIN_SET: int = 1
const SAND_IN_WATER_TERRAIN_SET: int = 3
const CLIFF_TERRAIN_SET: int = 4
const TERRAIN: int = 0

const COAST_TILE_DATA = "coast"

const SHALLOW_WATER_TILE = Vector2i(0,1)
const DEEP_WATER_TILE = Vector2i(3,1)
const TREE_TILE = Vector2i(6,1)


var width : int = 200
var height : int = 200

var noise : Noise
var tree_noise : Noise

var random_palm_tree_array = [Vector2i(7, 1), Vector2i(8,1) ]

var sand_arr: Array[Vector2i] = []
var grass_arr: Array[Vector2i] = []
var dirt_arr: Array[Vector2i] = []
var cliff_arr: Array[Vector2i] = []
var tree_arr: Array[Vector2i] = []

var random_grass_tile_arr: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0)]

@onready var water_layer: TileMapLayer = $WaterLayer
@onready var sand_and_grass_layer: TileMapLayer = $SandAndGrassLayer
@onready var farm_field_layer: TileMapLayer = $FarmFieldLayer
@onready var cliff_layer: TileMapLayer = $CliffLayer
@onready var environment_layer: TileMapLayer = $EnvironmentLayer
@onready var towns: Node2D = $Towns


func _ready() -> void:
	noise = noise_texture.noise
	tree_noise = tree_noise_texture.noise


func generate_world(new_seed: int):
	seed_value = new_seed
	var noise_val: float
	var tree_noise_val: float
	_generate_seed()
	
	for x in range(width):
		for y in range(height):
			var curr_pos: Vector2i = Vector2i(x, y)
			noise_val = noise.get_noise_2d(x,y)
			tree_noise_val = tree_noise.get_noise_2d(x,y)
			
			_place_sand(noise_val, curr_pos)
			_place_grass(noise_val, curr_pos)
			_place_cliffs(noise_val, curr_pos)
			_place_water(noise_val, curr_pos)
			_place_trees(tree_noise_val, noise_val, curr_pos)
			_place_palm_trees(tree_noise_val, noise_val, curr_pos)
			
	sand_and_grass_layer.set_cells_terrain_connect(sand_arr, SAND_IN_WATER_TERRAIN_SET, TERRAIN)
	sand_and_grass_layer.set_cells_terrain_connect(grass_arr, GRASS_IN_SAND_TERRAIN_SET, TERRAIN)
	cliff_layer.set_cells_terrain_connect(cliff_arr, CLIFF_TERRAIN_SET, TERRAIN)


func get_starting_position() -> Vector2i:
	if grass_arr.is_empty():
		return Vector2i.ZERO
	return grass_arr.pick_random() * water_layer.tile_set.tile_size


func _place_sand(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val > WATER_LEVEL:
		sand_arr.append(curr_pos)


func _place_grass(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val > GRASS_LEVEL:
		grass_arr.append(curr_pos)
		if noise_val > FIELD_LEVEL:
			farm_field_layer.set_cell(curr_pos, WORLD_TILE_SET, random_grass_tile_arr.pick_random())


func _place_cliffs(noise_val: float, curr_pos: Vector2i) -> void:
		if noise_val > CLIFF_LEVEL:
			cliff_arr.append(curr_pos)


func _place_water(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val <= DEEP_WATER_LEVEL:
		water_layer.set_cell(curr_pos, WORLD_TILE_SET, DEEP_WATER_TILE)
	elif noise_val <= WATER_LEVEL:
		water_layer.set_cell(curr_pos, WORLD_TILE_SET, SHALLOW_WATER_TILE)


func _place_trees(tree_noise_val: float, noise_val: float, curr_pos: Vector2i) -> void:
	#setting trees where there are no cliffs
	if (tree_noise_val > TREE_CHANCE) and (noise_val > FIELD_LEVEL) and (noise_val < CLIFF_LEVEL):
		environment_layer.set_cell(curr_pos, WORLD_TILE_SET, TREE_TILE)
		tree_arr.append(curr_pos)


func _place_palm_trees(tree_noise_val: float, noise_val: float, curr_pos: Vector2i) -> void:
	# setting palm trees on sand, between water and grass
	if (noise_val > WATER_LEVEL) and (noise_val < GRASS_LEVEL):
		if tree_noise_val > PALM_TREE_CHANCE:
			environment_layer.set_cell(curr_pos, WORLD_TILE_SET, random_palm_tree_array.pick_random())


func _generate_seed() -> void:
	if seed_value == 0:
		seed_value = randi()
	seed(seed_value)
	noise.seed = seed_value
	tree_noise.seed = seed_value


func get_used_rect() -> Rect2i:
	return water_layer.get_used_rect()


func get_tile_size() -> Vector2i:
	return water_layer.tile_set.tile_size


func get_save_data() -> Dictionary:
	var world_data = {
		"seed_value": seed_value
	}
	world_data.towns = []
	for town in get_towns():
		world_data.towns.append(_serialize_town_save_data(town))
	return {"world": world_data}


func set_save_data(save_data: Dictionary) -> void:
	var world_data: Dictionary = save_data.world
	var towns_data: Array = world_data.towns
	var generated_towns : Array[Town] = get_towns()
	for i in range(towns_data.size()):
		var town_data: Dictionary = towns_data[i]
		var current_town = generated_towns[i]
		current_town.set_visited(town_data.visited)
		_restore_town_inventory_from_save(current_town, town_data.inventory)


func _restore_town_inventory_from_save(town: Town, inventory_data: Dictionary) -> void:
	for item in town.get_trading_items():
		var item_save_data = inventory_data[str(item.good_id)]
		item.stock = item_save_data.stock
		item.cached_stock = item_save_data.cached_stock
		item.last_updated = item_save_data.last_updated


func _serialize_town_save_data(town: Town) -> Dictionary:
	return {
		"visited": town.get_visited(),
		"inventory": _serialize_town_inventory(town)
	}


func _serialize_town_inventory(town: Town) -> Dictionary:
	var inventory_data: Dictionary = {}
	for item in town.get_trading_items():
		inventory_data[item.good_id] = {
			"stock": item.stock,
			"cached_stock": item.cached_stock,
			"last_updated": item.last_updated,
		}
	return inventory_data


func is_coast(player_position: Vector2) -> bool:
	var player_position_to_tile = sand_and_grass_layer.local_to_map(player_position)
	var tile_data : TileData = sand_and_grass_layer.get_cell_tile_data(player_position_to_tile)
	if tile_data:
		return tile_data.get_custom_data(COAST_TILE_DATA)
	else:
		return false


func generate_towns() -> Array[Town]:
	@warning_ignore("integer_division")
	var max_cities = int(width / city_denstity)
	var coast_arr = sand_arr.filter(func(pos): return not (pos in grass_arr) and is_coast(pos * get_tile_size()))
	var farm_arr = grass_arr.filter(func(pos): return not (pos in tree_arr))
	
	for i in range(max_cities):
		var town_name = HaborTownResource.name + " " + str(i)
		var town = _create_town(HaborTownResource, town_name, coast_arr.pick_random())
		towns.add_child(town)
		
	@warning_ignore("integer_division")
	for i in range(max_cities / 2):
		var town_name = FarmTownResource.name + " " + str(i)
		var town = _create_town(FarmTownResource, town_name, farm_arr.pick_random())
		towns.add_child(town)

	@warning_ignore("integer_division")
	for i in range(max_cities / 2):
		var town_name = WoodCampTownResource.name + " " + str(i)
		var town = _create_town(WoodCampTownResource, town_name, tree_arr.pick_random())
		towns.add_child(town)

	return get_towns()


func _create_town(town_resource: TownResource, town_name: String, pos: Vector2i) -> Town:
	var town: Town = TownScene.instantiate()
	town.town_resource = town_resource
	town.town_name = town_name
	town.name = town_name
	town.global_position = pos * get_tile_size()
	return town
	

func get_towns() -> Array[Town]:
	var typed: Array[Town] = []
	typed.assign(towns.get_children())
	return typed
