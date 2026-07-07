class_name Main
extends Node2D


const ZOOM_OUT: float = 0.8
const ZOOM_IN: float = 1.2
const ZOOM_STEP: float = 0.1

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
@onready var inventory_screen: InventoryScreen = $gui/InventoryScreen
@onready var message_widget: MessageWidget = $gui/MessageWidget
@onready var minimap: Minimap = $gui/Minimap
@onready var fog_sector_manager: FogSectorManager = $FogSectorManager


func _ready() -> void:
	PauseManager.clear_all()
	var world_seed = _get_seed()
	proc_gen_world.generate_world(world_seed)
	fog_sector_manager.initialize(proc_gen_world.width, proc_gen_world.height)
	towns = proc_gen_world.generate_towns()
	fog_sector_manager.set_base_minimap_image(proc_gen_world.generate_minimap())
	_setup_limits_and_borders()


	debug_screen.set_seed(proc_gen_world.seed_value)
	zoom_widget.set_zoom(camera.zoom)
	
	if SaveManager.is_game_loaded():
		PlayerSerializer.new().set_save_data(player, SaveManager.load_game_state)
		ProcGenWorldSerializer.new().set_save_data( proc_gen_world, SaveManager.load_game_state)
		TradingSystemSerializer.new().set_save_data(trading_system, SaveManager.load_game_state)
	else:
		proc_gen_world.generate_goods()
		proc_gen_world.generate_raiders()
		player.position = proc_gen_world.get_starting_position()
		player.gold = 100
	_connect_signals()
	_setup_minimap()


func _physics_process(delta):
	if PauseManager.is_simulation_paused():
		return
	fog_sector_manager.update_fog(proc_gen_world.get_tile_size())
	trading_system.simulation(delta, towns)
	proc_gen_world.simulation(delta)


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
		town.town_entered.connect(_on_town_entered)
		town.town_entered.connect(player._on_town_entered)
	player.gold_changed.connect(promotion_system.evaluate)
	promotion_system.rank_promoted.connect(_on_rank_promoted)
	inventory_screen.active_ship_selected.connect(_on_inventory_ship_selected)


func _input(_event) -> void:
	_pause_game()
	_inventory_screen()
	_minimap()

	if PauseManager.is_simulation_paused():
		return

	_camera_zoom()
	_board_ship()
	
	
func _camera_zoom() -> void:
	if PauseManager.is_simulation_paused():
		return

	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera.zoom.x + ZOOM_STEP
		if zoom_val > ZOOM_IN:
			zoom_val = ZOOM_IN
		camera.zoom = Vector2(zoom_val, zoom_val)
		zoom_widget.set_zoom(camera.zoom)
	elif Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera.zoom.x - ZOOM_STEP
		if zoom_val < ZOOM_OUT:
			zoom_val = ZOOM_OUT
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
	if town_menu.visible:
		return

	if Input.is_action_just_pressed("inventory_screen"):
		if inventory_screen.visible:
			inventory_screen.hide()
			PauseManager.simulation_start()
		else:
			if minimap.visible:
				minimap.hide()
				PauseManager.simulation_start()
			inventory_screen.show_inventory(player)
			PauseManager.simulation_stop()


func _minimap() -> void:
	if town_menu.visible:
		return

	if Input.is_action_just_pressed("minimap"):
		if minimap.visible:
			minimap.hide()
			PauseManager.simulation_start()
		else:
			if inventory_screen.visible:
				inventory_screen.hide()
				PauseManager.simulation_start()
			_setup_minimap()
			minimap.show()
			minimap.set_player_position(player.position * ProcGenWorld.MINIMAP_PLAYER_SCALE)
			PauseManager.simulation_stop()


func _camera_limits(north_limit: float, south_limit: float, west_limit: float, east_limit: float) -> void:
	camera.set_limit(SIDE_LEFT, int(west_limit))
	camera.set_limit(SIDE_RIGHT, int(east_limit))
	camera.set_limit(SIDE_TOP, int(north_limit))
	camera.set_limit(SIDE_BOTTOM, int(south_limit))


func _on_town_entered(town: Town):
	PauseManager.simulation_stop()
	proc_gen_world.hide()
	player.hide()
	remove_chasing_raiders()
	town_menu.init(town, player, trading_system)
	town_menu.show()


func _on_town_left():
	PauseManager.simulation_start()
	proc_gen_world.show()
	player.show()
	town_menu.hide()


func _on_pause_menu_save_button_pressed():
	SaveManager.save(player, proc_gen_world, trading_system, 1)


func _on_rank_promoted(new_rank: PrestigeRank):
	var message = str("Du hast den neuen Titel: ", new_rank.title, " erhalten!")
	MessageBus.message_send.emit(message, Color.CORNFLOWER_BLUE)


func _on_inventory_ship_selected(ship_resource: ShipResource) -> void:
	if player.set_active_ship(ship_resource):
		inventory_screen.show_inventory(player)


func remove_chasing_raiders() -> void:
	var raiders = proc_gen_world.get_raiders()
	for raider in raiders:
		if raider.current_state == Raider.State.CHASE:
			raider.queue_free()


func _setup_minimap():
	var minimap_image = fog_sector_manager.generate_minimap_with_fog()
	minimap.set_image(minimap_image)
	minimap.center_on_screen()
