class_name ProcGenWorld
extends Node2D


@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D
@export var seed_value: int = 0


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


@onready var tile_map = $TileMap
@onready var player: CharacterBody2D = $Player
@onready var water_layer: TileMapLayer = $TileMap/water_layer
@onready var ground_layer: TileMapLayer = $TileMap/ground_layer
@onready var ground_2_layer: TileMapLayer = $TileMap/ground2_layer
@onready var cliff_layer: TileMapLayer = $TileMap/cliff_layer
@onready var environment_layer: TileMapLayer = $TileMap/environment_layer
@onready var camera: Camera2D = $Player/Camera2D
@onready var map_borders: MapBorders = $MapBorders
@onready var zoom_widget: ZoomWidget = $gui/ZoomWidget
@onready var town_menu = $gui/TownMenu


func _ready() -> void:
	if not OS.has_feature("editor"):
		get_window().mode = Window.MODE_FULLSCREEN

	noise = noise_texture.noise
	tree_noise = tree_noise_texture.noise
	zoom_widget.set_zoom(camera.zoom)
	var starting_pos = _generate_world()
	_setup_limits_and_borders()

	@warning_ignore("integer_division")
	player.global_position = starting_pos * water_layer.tile_set.tile_size


func _setup_limits_and_borders() -> void:
	var tile_map_used_rect = water_layer.get_used_rect()
	var tile_size = water_layer.tile_set.tile_size
	var north_limit = tile_map_used_rect.position.y * tile_size.y
	var south_limit = (tile_map_used_rect.position.y + tile_map_used_rect.size.y) * tile_size.y
	var west_limit = tile_map_used_rect.position.x * tile_size.x
	var east_limit = (tile_map_used_rect.position.x + tile_map_used_rect.size.x) * tile_size.x

	
	map_borders.set_borders(north_limit, south_limit, west_limit, east_limit)
	_camera_limits(north_limit, south_limit, west_limit, east_limit)


func _generate_world() -> Vector2i:
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
			
	ground_layer.set_cells_terrain_connect(sand_arr, 3, 0)
	ground_layer.set_cells_terrain_connect(grass_arr, 1, 0)
	cliff_layer.set_cells_terrain_connect(cliff_arr, 4, 0)

	if grass_arr.is_empty():
		return Vector2i.ZERO
	return grass_arr.pick_random()


func _place_sand(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val > 0:
		sand_arr.append(curr_pos)


func _place_grass(noise_val: float, curr_pos: Vector2i) -> void:
	if noise_val > 0.2:
		grass_arr.append(curr_pos)
		if noise_val > 0.3:
			#random grass
			ground_2_layer.set_cell(curr_pos, 0, random_grass_tile_arr.pick_random())


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


func _input(_event) -> void:
	_camera_zoom()
	_board_ship()
	_quit_game()
	
	
func _camera_zoom() -> void:
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera.zoom.x + 0.1
		if zoom_val > 2.0:
			zoom_val = 2.0
		camera.zoom = Vector2(zoom_val, zoom_val)
		zoom_widget.set_zoom(camera.zoom)
	elif Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera.zoom.x - 0.1
		if zoom_val < 0.5:
			zoom_val = 0.5
		camera.zoom = Vector2(zoom_val, zoom_val)
		zoom_widget.set_zoom(camera.zoom)	
	elif Input.is_action_just_pressed("zoom_reset"):
		camera.zoom = Vector2(1, 1)
		zoom_widget.set_zoom(camera.zoom)	
		


func _quit_game() -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit(0)


func _board_ship() -> void:
	if Input.is_action_just_pressed("board_ship") and _is_coast():
		player.board_ship()


func _is_coast() -> bool:
	var player_position_to_tile = ground_layer.local_to_map(player.position)
	var tile_data : TileData = ground_layer.get_cell_tile_data(player_position_to_tile)
	if tile_data:
		return tile_data.get_custom_data("coast")
	else:
		return false


func _camera_limits(north_limit: float, south_limit: float, west_limit: float, east_limit: float) -> void:
	camera.set_limit(SIDE_LEFT, int(west_limit))
	camera.set_limit(SIDE_RIGHT, int(east_limit))
	camera.set_limit(SIDE_TOP, int(north_limit))
	camera.set_limit(SIDE_BOTTOM, int(south_limit))


func _on_town_tile_town_entered():
	tile_map.hide()
	player.hide()
	town_menu.show()


func _on_town_menu_town_left():
	tile_map.show()
	player.show()
	town_menu.hide()
