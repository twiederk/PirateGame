class_name Player
extends CharacterBody2D

signal gold_changed(player: Player)

const LAND_SPEED: float = 200.0

const MASK_WATER: int = 2
const MASK_LAND: int = 3
const MASK_OCEAN: int = 5

enum State { ON_LAND, ON_SHIP, IN_TOWN }

var current_state: State = State.ON_LAND
var _previous_state: State = current_state
var current_speed: float = LAND_SPEED
var direction: Vector2 = Vector2.ZERO
var trader_rank: PrestigeRank = preload("res://promotion_system/trader_rank_01.tres") as PrestigeRank
var sailer_rank: PrestigeRank = preload("res://promotion_system/sailer_rank_01.tres") as PrestigeRank

var _ship_resource: ShipResource = null
var gold: int:
	set(value):
		gold = value
		gold_changed.emit(self)
var cargo_capacity: int = 20
var _inventory: Dictionary = {
		1: TradingItem.new(load("res://trading_system/good_fish.tres")),
		2: TradingItem.new(load("res://trading_system/good_grain.tres")),
		3: TradingItem.new(load("res://trading_system/good_wood.tres")),
	}

@onready var wanderer_animation_tree = $WandererSprite2D/WandererAnimationTree
@onready var wanderer_sprite: Sprite2D = $WandererSprite2D
@onready var ship_animation_tree = $ShipSprite2D/ShipAnimationTree
@onready var ship_sprite: Sprite2D = $ShipSprite2D


func _ready() -> void:
	wanderer_animation_tree.active = true
	ship_animation_tree.active = false


func _process(_delta: float) -> void:
	_update_animation_parameters()


func _physics_process(_delta: float):
	if current_state == State.IN_TOWN:
		return

	direction = Input.get_vector("left", "right","up","down").normalized()
	if direction:
		velocity = direction * current_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func _update_animation_parameters():
	if velocity == Vector2.ZERO:
		wanderer_animation_tree["parameters/conditions/is_idle"] = true
		wanderer_animation_tree["parameters/conditions/is_moving"] = false
	else:
		wanderer_animation_tree["parameters/conditions/is_idle"] = false
		wanderer_animation_tree["parameters/conditions/is_moving"] = true

	if direction != Vector2.ZERO:
		wanderer_animation_tree["parameters/idle/blend_position"] = direction
		wanderer_animation_tree["parameters/walk/blend_position"] = direction
		ship_animation_tree.set("parameters/blend_position", velocity.normalized())


func owns_ship() -> bool:
	return _ship_resource != null


func board_ship() -> void:
	if not owns_ship():
		return
	
	wanderer_sprite.visible = !wanderer_sprite.visible
	ship_sprite.visible = !ship_sprite.visible
	
	wanderer_animation_tree.active = !wanderer_animation_tree.active
	ship_animation_tree.active = !ship_animation_tree.active
	
	if current_state == State.ON_LAND:
		_move_on_ship()
	else:
		_move_on_land()


func _move_on_ship() -> void:
	current_state = State.ON_SHIP
	current_speed = _ship_resource.speed
	set_collision_mask_value(MASK_LAND, true)
	set_collision_mask_value(MASK_WATER, false)
	if _ship_resource.ocean_going:
		set_collision_mask_value(MASK_OCEAN, false)
	else:
		set_collision_mask_value(MASK_OCEAN, true)


func _move_on_land() -> void:
	current_state = State.ON_LAND
	current_speed = LAND_SPEED
	set_collision_mask_value(MASK_LAND, false)
	set_collision_mask_value(MASK_WATER, true)
	set_collision_mask_value(MASK_OCEAN, true)


func _on_town_tile_town_entered(_town: Town) -> void:
	_previous_state = current_state
	current_state = State.IN_TOWN


func _on_town_menu_town_left() -> void:
	current_state = _previous_state


func in_town() -> bool:
	return current_state == State.IN_TOWN


func has_space(amount: int) -> bool:
	return get_used_capacity() + amount <= cargo_capacity


func get_used_capacity() -> int:
	var total = 0
	for good_id in _inventory:
		total += _inventory[good_id].stock
	return total


func get_trading_item(good_id: int) -> TradingItem:
	return _inventory[good_id]


func equip_ship(ship_resource: ShipResource) -> void:
	_ship_resource = ship_resource
	ship_sprite.texture = ship_resource.texture


func get_save_data() -> Dictionary:
	var player_data = {
		"gold": gold,
		"position": {
			"x": position.x,
			"y": position.y,
		},
		"trader_rank": trader_rank.resource_path,
		"sailer_rank": sailer_rank.resource_path,
		"current_state": current_state,
		"inventory": _serialize_inventory_stock(),
	}
	if _ship_resource != null:
		player_data.ship = {"resource_path": _ship_resource.resource_path}

	return {"player": player_data}


func _serialize_inventory_stock() -> Dictionary:
	var inventory_data = {}
	for good_id in _inventory:
		inventory_data[good_id] = {"stock": _inventory[good_id].stock}
	return inventory_data


func set_save_data(save_data: Dictionary) -> void:
	var player_data = save_data.player
	var pos_data = player_data.position
	position = Vector2i(int(pos_data.x), int(pos_data.y))
	gold = int(player_data.gold)
	current_state = int(player_data.current_state) as State
	if player_data.has("trader_rank"):
		trader_rank = load(player_data.trader_rank)
	else:
		trader_rank = load("res://promotion_system/trader_rank_01.tres")
	if player_data.has("inventory"):
		_restore_inventory_stock(player_data.inventory)
	if player_data.has("ship"):
		var resource_path = player_data.ship.resource_path
		equip_ship(load(resource_path))
	if current_state == State.ON_SHIP:
		current_state = State.ON_LAND
		board_ship()


func _restore_inventory_stock(inventory_data: Dictionary) -> void:
	for good_id in inventory_data:
		var item_data = inventory_data[good_id]
		get_trading_item(int(good_id)).stock = int(item_data.stock)


func get_trading_items() -> Array[TradingItem]:
	var typed: Array[TradingItem] = []
	typed.assign(_inventory.values())
	return typed


func get_previous_state() -> State:
	return _previous_state
