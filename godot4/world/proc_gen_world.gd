class_name ProcGenWorld
extends Node2D

@export var width : int = 200
@export var height : int = 200
@export var seed_value: int = 0
@export var town_percentage: float = 0.05
@export var fish_percentage: float = 0.125
@export var grain_percentage: float = 0.05
@export var wood_percentage: float = 0.05
@export var raider_percentage: float = 0.02
@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D

const TownScene = preload("res://world/town.tscn")
const GoodScene = preload("res://world/good.tscn")
const RaiderScene = preload("res://world/raider.tscn")

const TOWN_HABOR = preload("res://world/town_habor.tres")
const TOWN_FARM = preload("res://world/town_farm.tres")
const TOWN_WOOD_CAMP = preload("res://world/town_wood_camp.tres")

const GOOD_FISH = preload("res://trading_system/good_fish.tres")
const GOOD_GRAIN = preload("res://trading_system/good_grain.tres")
const GOOD_WOOD = preload("res://trading_system/good_wood.tres")

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
const TREE_1_TILE = Vector2i(6,1)
const TREE_2_TILE = Vector2i(7,1)
const PALM_TREE_1_TILE = Vector2i(6, 0)
const PALM_TREE_2_TILE = Vector2i(7, 0)

const TREE_TILES = [TREE_1_TILE, TREE_2_TILE]
const PALM_TREE_TILES = [PALM_TREE_1_TILE, PALM_TREE_2_TILE]
const GRASS_TILES: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0)]

const SIMULATION_STEP: float = 30.0

var noise : Noise
var tree_noise : Noise

var deep_water_arr: Array[Vector2i] = []
var shallow_water_arr: Array[Vector2i] = []
var sand_arr: Array[Vector2i] = []
var grass_arr: Array[Vector2i] = []
var cliff_arr: Array[Vector2i] = []
var tree_arr: Array[Vector2i] = []

var spawn_accumulator: float = 0.0

@onready var water_layer: TileMapLayer = $WaterLayer
@onready var sand_and_grass_layer: TileMapLayer = $SandAndGrassLayer
@onready var farm_field_layer: TileMapLayer = $FarmFieldLayer
@onready var cliff_layer: TileMapLayer = $CliffLayer
@onready var environment_layer: TileMapLayer = $EnvironmentLayer
@onready var towns: Node2D = $Towns
@onready var goods = $Goods
@onready var raiders = $Raiders


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
	return grass_arr.pick_random() * get_tile_size()


func _place_sand(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val > WATER_LEVEL:
		sand_arr.append(curr_pos)


func _place_grass(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val > GRASS_LEVEL:
		grass_arr.append(curr_pos)
		if noise_val > FIELD_LEVEL:
			farm_field_layer.set_cell(curr_pos, WORLD_TILE_SET, GRASS_TILES.pick_random())


func _place_cliffs(noise_val: float, curr_pos: Vector2i) -> void:
		if noise_val > CLIFF_LEVEL:
			cliff_arr.append(curr_pos)


func _place_water(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val <= DEEP_WATER_LEVEL:
		water_layer.set_cell(curr_pos, WORLD_TILE_SET, DEEP_WATER_TILE)
		deep_water_arr.append(curr_pos)
	elif noise_val <= WATER_LEVEL:
		water_layer.set_cell(curr_pos, WORLD_TILE_SET, SHALLOW_WATER_TILE)
		shallow_water_arr.append(curr_pos)

func _place_trees(tree_noise_val: float, noise_val: float, curr_pos: Vector2i) -> void:
	#setting trees where there are no cliffs
	if (tree_noise_val > TREE_CHANCE) and (noise_val > FIELD_LEVEL) and (noise_val < CLIFF_LEVEL):
		environment_layer.set_cell(curr_pos, WORLD_TILE_SET, TREE_TILES.pick_random())
		tree_arr.append(curr_pos)


func _place_palm_trees(tree_noise_val: float, noise_val: float, curr_pos: Vector2i) -> void:
	# setting palm trees on sand, between water and grass
	if (noise_val > WATER_LEVEL) and (noise_val < GRASS_LEVEL):
		if tree_noise_val > PALM_TREE_CHANCE:
			environment_layer.set_cell(curr_pos, WORLD_TILE_SET, PALM_TREE_TILES.pick_random())


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


func is_coast(player_position: Vector2) -> bool:
	var player_position_to_tile = sand_and_grass_layer.local_to_map(player_position)
	var tile_data : TileData = sand_and_grass_layer.get_cell_tile_data(player_position_to_tile)
	if tile_data:
		return tile_data.get_custom_data(COAST_TILE_DATA)
	else:
		return false


func generate_towns() -> Array[Town]:
	var max_cities = int(width * town_percentage)
	var coast_arr = sand_arr.filter(func(pos): return not (pos in grass_arr) and is_coast(pos * get_tile_size()))
	var farm_arr = grass_arr.filter(func(pos): return not (pos in tree_arr))
	
	for i in range(max_cities * 1.0):
		var town_name = TownResource.name_dictionary[TownResource.Type.Habor].pick_random()
		var town = _create_town(TOWN_HABOR, town_name, coast_arr.pick_random())
		towns.add_child(town)
		
	for i in range(max_cities * 0.5):
		var town_name = TownResource.name_dictionary[TownResource.Type.Farm].pick_random()
		var town = _create_town(TOWN_FARM, town_name, farm_arr.pick_random())
		towns.add_child(town)

	for i in range(max_cities * 0.5):
		var town_name = TownResource.name_dictionary[TownResource.Type.Woodcamp].pick_random()
		var town = _create_town(TOWN_WOOD_CAMP, town_name, tree_arr.pick_random())
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


func get_goods() -> Array[Good]:
	var typed: Array[Good] = []
	typed.assign(goods.get_children())
	return typed


func get_raiders() -> Array[Raider]:
	var typed: Array[Raider] = []
	typed.assign(raiders.get_children())
	return typed


func get_goods_by_type(good_resource: GoodResource) -> Array[Good]:
	return get_goods().filter(func(good): return good.good_resource == good_resource)


func generate_goods():
	var farm_arr = grass_arr.filter(func(pos): return not (pos in tree_arr))
	_generate_goods_of_type(GOOD_FISH, int(width * grain_percentage * 0.33), shallow_water_arr)
	_generate_goods_of_type(GOOD_FISH, int(width * grain_percentage * 0.66), deep_water_arr)
	_generate_goods_of_type(GOOD_GRAIN, int(width * grain_percentage), farm_arr)
	_generate_goods_of_type(GOOD_WOOD, int(width * wood_percentage), tree_arr)


func _generate_goods_of_type(good_resource: GoodResource, max_good: int, positions: Array[Vector2i]) -> void:
	var goods_to_generate = max_good - get_goods_by_type(good_resource).size()
	for i in range(goods_to_generate):
		var good: Good = GoodScene.instantiate() 
		good.good_resource = good_resource
		good.global_position = positions.pick_random() * get_tile_size()
		goods.add_child(good)


func generate_raiders() -> void:
	var max_raiders = int(width * raider_percentage)
	var raiders_to_generate = max_raiders - get_raiders().size()
	for i in range(raiders_to_generate):
		var raider: Raider = RaiderScene.instantiate() 
		raider.global_position = grass_arr.pick_random() * get_tile_size()
		raiders.add_child(raider)


func simulation(delta: float) -> void:
	spawn_accumulator += delta
	if spawn_accumulator >= SIMULATION_STEP:
		generate_goods()
		generate_raiders()
		spawn_accumulator = 0.0


func generate_minimap() -> Image:
	var minimap: Image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	minimap.fill(Color.BLACK)
	for pos in deep_water_arr:
		minimap.set_pixelv(pos, Color.DARK_BLUE)
	for pos in shallow_water_arr:
		minimap.set_pixelv(pos, Color.DODGER_BLUE)
	return minimap
