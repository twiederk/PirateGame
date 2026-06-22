class_name Main
extends Node2D

var towns: Array[Town]

@onready var proc_gen_world: ProcGenWorld = $ProcGenWorld
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var map_borders: MapBorders = $MapBorders
@onready var zoom_widget: ZoomWidget = $gui/ZoomWidget
@onready var town_menu: TownMenu = $gui/TownMenu
@onready var trading_system: TradingSystem = $TradingSystem
@onready var debug_screen: DebugScreen = $gui/DebugScreen
@onready var pause_menu: PauseMenu = $gui/PauseMenu
@onready var promotion_system: PromotionSystem = $PromotionSystem
@onready var promotion_widget: PromotionWidget = $gui/PromotionWidget
@onready var inventory_screen: InventoryScreen = $gui/InventoryScreen


func _ready() -> void:
	var world_seed = _get_seed()
	proc_gen_world.generate_world(world_seed)
	towns = proc_gen_world.generate_towns()
	_connect_signals()
	_setup_limits_and_borders()

	debug_screen.set_seed(proc_gen_world.seed_value)
	zoom_widget.set_zoom(camera.zoom)
	
	if SaveManager.is_game_loaded():
		player.set_save_data(SaveManager.load_game_state)
		proc_gen_world.set_save_data(SaveManager.load_game_state)
		trading_system.set_save_data(SaveManager.load_game_state)
	else:
		player.position = proc_gen_world.get_starting_position()
		player.gold = 100


func _process(delta):
	if player.in_town():
		return
	trading_system.simulation(delta, towns)


func _setup_limits_and_borders() -> void:
	var tile_map_used_rect = proc_gen_world.get_used_rect()
	var tile_size = proc_gen_world.get_tile_size()
	var north_limit = tile_map_used_rect.position.y * tile_size.y
	var south_limit = (tile_map_used_rect.position.y + tile_map_used_rect.size.y) * tile_size.y
	var west_limit = tile_map_used_rect.position.x * tile_size.x
	var east_limit = (tile_map_used_rect.position.x + tile_map_used_rect.size.x) * tile_size.x

	map_borders.set_borders(north_limit, south_limit, west_limit, east_limit)
	_camera_limits(north_limit, south_limit, west_limit, east_limit)


func _get_seed() -> int:
	if SaveManager.load_game_state.is_empty():
		return 0
	return SaveManager.load_game_state.world.seed_value


func _connect_signals() -> void:
	for town in towns:
		town.town_entered.connect(_on_town_tile_town_entered)
		town.town_entered.connect(player._on_town_tile_town_entered)
	player.gold_changed.connect(promotion_system.evaluate)
	promotion_system.rank_promoted.connect(_on_rank_promoted)


func _input(_event) -> void:
	_camera_zoom()
	_board_ship()
	_pause_game()
	_inventory_screen()
	
	
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
		


func _pause_game() -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu.show_menu()


func _board_ship() -> void:
	if Input.is_action_just_pressed("board_ship") and _is_coast():
		player.board_ship()


func _is_coast() -> bool:
	return proc_gen_world.is_coast(player.position)


func _inventory_screen() -> void:
	if Input.is_action_just_pressed("inventory_screen"):
		if inventory_screen.visible:
			inventory_screen.hide()
		else:
			inventory_screen.show_inventory(player)
	
	
func _camera_limits(north_limit: float, south_limit: float, west_limit: float, east_limit: float) -> void:
	camera.set_limit(SIDE_LEFT, int(west_limit))
	camera.set_limit(SIDE_RIGHT, int(east_limit))
	camera.set_limit(SIDE_TOP, int(north_limit))
	camera.set_limit(SIDE_BOTTOM, int(south_limit))


func _on_town_tile_town_entered(town: Town):
	proc_gen_world.hide()
	player.hide()
	town_menu.init(town, player, trading_system)
	town_menu.show()


func _on_town_menu_town_left():
	proc_gen_world.show()
	player.show()
	town_menu.hide()


func _on_pause_menu_save_button_pressed():
	SaveManager.save(player, proc_gen_world, trading_system, 1)


func _on_rank_promoted(new_rank: PrestigeRank):
	promotion_widget.show_promotion(new_rank)
