class_name ProcGenWorld
extends Node2D

@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D
@export var seed_value: int = 0

const TownScene = preload("res://world/town.tscn")
const HaborTownResource = preload("res://world/town_habor.tres")
const FarmTownResource = preload("res://world/town_farm.tres")

var width : int = 100
var height : int =  100

var noise : Noise
var tree_noise : Noise

var water_tile = Vector2i(0,1)
var random_palm_tree_array = [Vector2i(12, 2), Vector2i(15,2) ]
var tree_tile = Vector2i(15,6)

var sand_arr: Array[Vector2i] = []
var grass_arr: Array[Vector2i] = []
var dirt_arr: Array[Vector2i] = []
var cliff_arr: Array[Vector2i] = []

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


func generate_world() -> Vector2i:
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
			
	sand_and_grass_layer.set_cells_terrain_connect(sand_arr, 3, 0)
	sand_and_grass_layer.set_cells_terrain_connect(grass_arr, 1, 0)
	cliff_layer.set_cells_terrain_connect(cliff_arr, 4, 0)

	if grass_arr.is_empty():
		return Vector2i.ZERO
	return grass_arr.pick_random() * water_layer.tile_set.tile_size


func _place_sand(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val > 0:
		sand_arr.append(curr_pos)


func _place_grass(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val > 0.2:
		grass_arr.append(curr_pos)
		if noise_val > 0.3:
			#random grass
			farm_field_layer.set_cell(curr_pos, 0, random_grass_tile_arr.pick_random())


func _place_cliffs(noise_val: float, curr_pos: Vector2i) -> void:
		#setting cliffs
		if noise_val > 0.6:
			cliff_arr.append(curr_pos)


func _place_water(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val <= 0:
		water_layer.set_cell(curr_pos, 0, water_tile)


func _place_trees(tree_noise_val: float, noise_val: float, curr_pos: Vector2i) -> void:
	#setting trees where there are no cliffs
	if (tree_noise_val > 0.9) and (noise_val > 0.3) and (noise_val < 0.5):
		environment_layer.set_cell(curr_pos, 0, tree_tile)


func _place_palm_trees(tree_noise_val: float, noise_val: float, curr_pos: Vector2i) -> void:
	# setting palm trees on sand, between water and grass
	if (noise_val > 0.0) and (noise_val < 0.18):
		if tree_noise_val > 0.92:
			environment_layer.set_cell(curr_pos, 0, random_palm_tree_array.pick_random())


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
		return tile_data.get_custom_data("coast")
	else:
		return false


func generate_towns() -> Array[Town]:
	for i in range(5):
		var town: Town = TownScene.instantiate()
		town.town_resource = FarmTownResource
		town.town_name = FarmTownResource.name + " " + str(i)
		town.name = town.town_name
		town.global_position = grass_arr.pick_random() * get_tile_size()
		towns.add_child(town)
		
	for i in range(5):
		var town: Town = TownScene.instantiate()
		town.town_resource = HaborTownResource
		town.town_name = HaborTownResource.name + " " + str(i)
		town.name = town.town_name
		town.global_position = sand_arr.pick_random() * get_tile_size()
		towns.add_child(town)
		
	return get_towns()


func get_towns() -> Array[Town]:
	var typed: Array[Town] = []
	typed.assign(towns.get_children())
	return typed
