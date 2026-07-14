class_name ProcGenWorld
extends Node2D


@export var width : int = 256
@export var height : int = 192
@export var seed_value: int = 0
@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D

const DEEP_WATER_LEVEL: float = -0.2
const WATER_LEVEL: float = 0
const GRASS_LEVEL: float = 0.2
const FIELD_LEVEL: float = 0.3
const CLIFF_LEVEL: float = 0.5
const TREE_CHANCE: float = 0.0
const PALM_TREE_CHANCE: float = 0.35

const WORLD_TILE_SET = 0
const MINIMAP_PLAYER_SCALE: float = 2.0 / 16.0
const MINIMAP_SCALE: float = 1.0 / 16.0
const TILE_SIZE: Vector2i = Vector2i(16, 16)

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
var farm_arr: Array[Vector2i] =[]
var cliff_arr: Array[Vector2i] = []
var tree_arr: Array[Vector2i] = []
var palm_tree_arr: Array[Vector2i] = []

var spawn_accumulator: float = 0.0

var _minimap_image: Image = null

var goods_generator: GoodsGenerator = GoodsGenerator.new()
var raiders_generator: RaidersGenerator = RaidersGenerator.new()
var towns_generator: TownsGenerator = TownsGenerator.new()
var treasures_generator: TreasuresGenerator = TreasuresGenerator.new()

@onready var water_layer: TileMapLayer = $WaterLayer
@onready var sand_and_grass_layer: TileMapLayer = $SandAndGrassLayer
@onready var farm_field_layer: TileMapLayer = $FarmFieldLayer
@onready var cliff_layer: TileMapLayer = $CliffLayer
@onready var environment_layer: TileMapLayer = $EnvironmentLayer
@onready var towns: Node2D = $Towns
@onready var goods: Node2D = $Goods
@onready var raiders: Node2D = $Raiders
@onready var treasures: Node2D = $Treasures


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
	for curr_pos in deep_water_arr:
		water_layer.set_cell(curr_pos, WORLD_TILE_SET, DEEP_WATER_TILE)
	for curr_pos in shallow_water_arr:
		water_layer.set_cell(curr_pos, WORLD_TILE_SET, SHALLOW_WATER_TILE)
	for curr_pos in farm_arr:
		farm_field_layer.set_cell(curr_pos, WORLD_TILE_SET, GRASS_TILES.pick_random())
	for curr_pos in tree_arr:
		environment_layer.set_cell(curr_pos, WORLD_TILE_SET, TREE_TILES.pick_random())
	for curr_pos in palm_tree_arr:
		environment_layer.set_cell(curr_pos, WORLD_TILE_SET, PALM_TREE_TILES.pick_random())



func get_starting_position() -> Vector2i:
	var starting_positions = grass_arr.filter(func(pos): return not pos in cliff_arr)
	if starting_positions.is_empty():
		return Vector2i.ZERO
	return starting_positions.pick_random() * TILE_SIZE


func _place_sand(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val > WATER_LEVEL:
		sand_arr.append(curr_pos)


func _place_grass(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val > GRASS_LEVEL:
		grass_arr.append(curr_pos)
		if noise_val > FIELD_LEVEL:
			farm_arr.append(curr_pos)


func _place_cliffs(noise_val: float, curr_pos: Vector2i) -> void:
		if noise_val > CLIFF_LEVEL:
			cliff_arr.append(curr_pos)


func _place_water(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val <= DEEP_WATER_LEVEL:
		deep_water_arr.append(curr_pos)
	elif noise_val <= WATER_LEVEL:
		shallow_water_arr.append(curr_pos)

func _place_trees(tree_noise_val: float, noise_val: float, curr_pos: Vector2i) -> void:
	#setting trees where there are no cliffs
	if (tree_noise_val > TREE_CHANCE) and (noise_val > FIELD_LEVEL) and (noise_val < CLIFF_LEVEL):
		tree_arr.append(curr_pos)


func _place_palm_trees(tree_noise_val: float, noise_val: float, curr_pos: Vector2i) -> void:
	# setting palm trees on sand, between water and grass
	if (noise_val > WATER_LEVEL) and (noise_val < GRASS_LEVEL):
		if tree_noise_val > PALM_TREE_CHANCE:
			palm_tree_arr.append(curr_pos)


func _generate_seed() -> void:
	if seed_value == 0:
		seed_value = randi()
	seed(seed_value)
	noise.seed = seed_value
	tree_noise.seed = seed_value


func get_used_rect() -> Rect2i:
	return water_layer.get_used_rect()


func is_coast(player_position: Vector2) -> bool:
	var player_position_to_tile = sand_and_grass_layer.local_to_map(player_position)
	var tile_data : TileData = sand_and_grass_layer.get_cell_tile_data(player_position_to_tile)
	if tile_data:
		return tile_data.get_custom_data(COAST_TILE_DATA)
	else:
		return false


func generate_towns() -> void:
	towns_generator.generate_towns(self)


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


func get_treasures() -> Array[Treasure]:
	var typed: Array[Treasure] = []
	typed.assign(treasures.get_children())
	return typed


func generate_goods():
	goods_generator.generate_goods(self)


func generate_raiders(player_position: Vector2) -> void:
	raiders_generator.generate_raiders(self, player_position)


func generate_treasures() -> void:
	treasures_generator.generate_treasures(self)


func create_treasure_map(global_pos: Vector2, treasure_map_size: Vector2i) -> Image:
	var minimap_position = Vector2i(global_pos / Vector2(TILE_SIZE))
	var region = Rect2i(minimap_position - Vector2i(Vector2(treasure_map_size) * 0.5), treasure_map_size)
	var treasure_map_image = get_minimap_image().get_region(region)
	_draw_mark(treasure_map_image, Vector2(treasure_map_size) * 0.5, Color.ORANGE_RED)
	return treasure_map_image


func simulation(delta: float, player_position: Vector2) -> void:
	spawn_accumulator += delta
	if spawn_accumulator >= SIMULATION_STEP:
		generate_goods()
		generate_raiders(player_position)
		generate_treasures()
		spawn_accumulator = 0.0


func _generate_minimap() -> Image:
	var minimap: Image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	minimap.fill(Color.BLACK)
	_draw_world(minimap)
	_draw_towns(minimap)
	return minimap


func _draw_world(minimap: Image) -> void:
	_draw_pixels(minimap, deep_water_arr, Color.DARK_BLUE)
	_draw_pixels(minimap, shallow_water_arr, Color.DODGER_BLUE)
	_draw_pixels(minimap, sand_arr, Color.SANDY_BROWN)
	_draw_pixels(minimap, grass_arr, Color.FOREST_GREEN)
	_draw_pixels(minimap, cliff_arr, Color.WHITE)
	_draw_pixels(minimap, tree_arr, Color.DARK_GREEN)


func _draw_pixels(minimap: Image, positions: Array[Vector2i], color: Color) -> void:
	for pos in positions:
		if _is_in_minimap_bounds(minimap, pos):
			minimap.set_pixelv(pos, color)


func _draw_towns(minimap: Image) -> void:
	for town in get_towns():
		var pos = town.position * MINIMAP_SCALE
		_draw_mark(minimap, pos, Color.DARK_RED)


func _draw_mark(minimap: Image, pos: Vector2i, color: Color) -> void:
	for x_offset in range(-1, 2):
		for y_offset in range(-1, 2):
			var pixel_pos = pos + Vector2i(x_offset, y_offset)
			if _is_in_minimap_bounds(minimap, pixel_pos):
				minimap.set_pixelv(pixel_pos, color)


func _is_in_minimap_bounds(minimap: Image, pixel_pos: Vector2i) -> bool:
	return pixel_pos.x >= 0 and pixel_pos.y >= 0 and pixel_pos.x < minimap.get_width() and pixel_pos.y < minimap.get_height()


func get_minimap_image() -> Image:
	if _minimap_image == null:
		_minimap_image = _generate_minimap()
	return _minimap_image
