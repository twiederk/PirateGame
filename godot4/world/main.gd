class_name Main
extends Node2D


@onready var proc_gen_world: ProcGenWorld = $ProcGenWorld
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var map_borders: MapBorders = $MapBorders
@onready var zoom_widget: ZoomWidget = $gui/ZoomWidget
@onready var town_menu: TownMenu = $gui/TownMenu
@onready var trading_system = $TradingSystem


func _ready() -> void:
	if not OS.has_feature("editor"):
		get_window().mode = Window.MODE_FULLSCREEN

	zoom_widget.set_zoom(camera.zoom)
	var starting_pos = proc_gen_world.generate_world()
	var towns = proc_gen_world.generate_towns()
	_connect_signals(towns)
	_setup_limits_and_borders()
	
	trading_system.init(towns)

	player.global_position = starting_pos


func _setup_limits_and_borders() -> void:
	var tile_map_used_rect = proc_gen_world.get_used_rect()
	var tile_size = proc_gen_world.get_tile_size()
	var north_limit = tile_map_used_rect.position.y * tile_size.y
	var south_limit = (tile_map_used_rect.position.y + tile_map_used_rect.size.y) * tile_size.y
	var west_limit = tile_map_used_rect.position.x * tile_size.x
	var east_limit = (tile_map_used_rect.position.x + tile_map_used_rect.size.x) * tile_size.x

	map_borders.set_borders(north_limit, south_limit, west_limit, east_limit)
	_camera_limits(north_limit, south_limit, west_limit, east_limit)


func _connect_signals(towns: Array[TownTile]) -> void:
	for town in towns:
		town.town_entered.connect(_on_town_tile_town_entered)
		town.town_entered.connect(player._on_town_tile_town_entered)


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
	return proc_gen_world.is_coast(player.position)


func _camera_limits(north_limit: float, south_limit: float, west_limit: float, east_limit: float) -> void:
	camera.set_limit(SIDE_LEFT, int(west_limit))
	camera.set_limit(SIDE_RIGHT, int(east_limit))
	camera.set_limit(SIDE_TOP, int(north_limit))
	camera.set_limit(SIDE_BOTTOM, int(south_limit))


func _on_town_tile_town_entered(town: TownTile):
	proc_gen_world.hide()
	player.hide()
	town_menu.init(town, trading_system.player, trading_system)
	town_menu.show()


func _on_town_menu_town_left():
	proc_gen_world.show()
	player.show()
	town_menu.hide()
