class_name ProcGenWorld
extends Node2D


@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D
@export var seed_value: int = 0


const TILE_SIZE: int = 16

var width : int = 300
var height : int =  300

var noise : Noise
var tree_noise : Noise

var water_tile_atlas = Vector2i(0,1)
var tree_atlas = Vector2i(12,2)
var tree_atlas2 = Vector2i(15,6)

var sand_arr = []
var grass_arr = []
var dirt_arr = []
var cliff_arr = []

var random_grass_atlas_arr = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0)]


@onready var tile_map = $TileMap
@onready var camera_2d = $Player/Camera2D
@onready var player: CharacterBody2D = $Player
@onready var water_layer: TileMapLayer = $TileMap/water_layer
@onready var ground_layer: TileMapLayer = $TileMap/ground_layer
@onready var ground_2_layer: TileMapLayer = $TileMap/ground2_layer
@onready var cliff_layer: TileMapLayer = $TileMap/cliff_layer
@onready var environment_layer: TileMapLayer = $TileMap/environment_layer


func _ready() -> void:
	if not OS.has_feature("editor"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	
	@warning_ignore("integer_division")
	player.global_position = Vector2(width / 2, height / 2) * TILE_SIZE

	noise = noise_texture.noise
	tree_noise = tree_noise_texture.noise

	_generate_world()


func _generate_world() -> void:
	var noise_val: float
	var tree_noise_val: float
	_generate_seed()
	
	for x in range(width):
		for y in range(height):
			var position: Vector2i = Vector2i(x, y)
			noise_val = noise.get_noise_2d(x,y)
			tree_noise_val = tree_noise.get_noise_2d(x,y)
			
			#setting cliffs
			if noise_val > 0.6:
				cliff_arr.append(position)
			
			#setting all grass tiles
			if noise_val > 0.2:
				grass_arr.append(position)
				if noise_val > 0.3:
					#random grass
					ground_2_layer.set_cell(position, 0, random_grass_atlas_arr.pick_random())
			
			#setting trees where there are no cliffs
			_place_trees(tree_noise_val, noise_val, position)
		
			# setting sand and palm trees between water and grass
			if noise_val > 0:
				sand_arr.append(position)
				if noise_val < 0.18:
					if tree_noise_val > 0.92:
						environment_layer.set_cell(position, 0,tree_atlas)
			
			water_layer.set_cell(position, 0, water_tile_atlas)

	ground_layer.set_cells_terrain_connect(sand_arr, 3, 0)
	ground_layer.set_cells_terrain_connect(grass_arr, 1, 0)
	cliff_layer.set_cells_terrain_connect(cliff_arr, 4, 0)


func _place_trees(tree_noise_val: float, noise_val: float, position: Vector2i) -> void:
	if (tree_noise_val > 0.9) and (noise_val > 0.3) and (noise_val < 0.5):
		environment_layer.set_cell(position, 0, tree_atlas2)



func _generate_seed() -> void:
	if seed_value == 0:
		seed_value = randi()
	noise.seed = seed_value
	tree_noise.seed = seed_value


func _input(_event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val =camera_2d.zoom.x + 0.1
		
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	elif Input.is_action_just_pressed("zoom_out"):
		var zoom_val =camera_2d.zoom.x - 0.1
		if zoom_val == 0:
			zoom_val =camera_2d.zoom.x - 0.2
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	elif Input.is_action_just_pressed("quit"):
		get_tree().quit(0)
