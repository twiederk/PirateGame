class_name Player
extends CharacterBody2D

signal gold_changed(player: Player)

const LAND_SPEED: float = 200.0
const NO_SHIP: int = -1

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

var _ship_resources: Array[ShipResource] = []
var _current_ship_index: int = NO_SHIP
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
	return not _ship_resources.is_empty()


func add_ship(ship_resource: ShipResource) -> bool:
	for existing_ship in _ship_resources:
		if existing_ship.id == ship_resource.id:
			return false
	_ship_resources.append(ship_resource)
	_set_active_ship_index(_ship_resources.size() - 1)
	return true


func set_active_ship(ship_resource: ShipResource) -> bool:
	if ship_resource == null:
		return false
	if current_state == State.ON_SHIP:
		return false
	for i in _ship_resources.size():
		if _ship_resources[i].id == ship_resource.id:
			_set_active_ship_index(i)
			return true
	return false


func _set_active_ship_index(index: int) -> void:
	_current_ship_index = index
	if ship_sprite != null:
		ship_sprite.texture = _ship_resources[index].texture


func board_ship() -> void:
	if not owns_ship():
		return
	if get_ship() == null:
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
	var active_ship = get_ship()
	if active_ship == null:
		return
	current_state = State.ON_SHIP
	current_speed = active_ship.speed
	set_collision_mask_value(MASK_LAND, true)
	set_collision_mask_value(MASK_WATER, false)
	if active_ship.ocean_going:
		set_collision_mask_value(MASK_OCEAN, false)
	else:
		set_collision_mask_value(MASK_OCEAN, true)


func _move_on_land() -> void:
	current_state = State.ON_LAND
	current_speed = LAND_SPEED
	set_collision_mask_value(MASK_LAND, false)
	set_collision_mask_value(MASK_WATER, true)
	set_collision_mask_value(MASK_OCEAN, true)


func _on_town_entered(_town: Town) -> void:
	_previous_state = current_state
	current_state = State.IN_TOWN


func _on_town_left() -> void:
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
	if ship_resource == null:
		return
	if set_active_ship(ship_resource):
		return
	for existing_ship in _ship_resources:
		if existing_ship.id == ship_resource.id:
			return
	_ship_resources.append(ship_resource)
	_set_active_ship_index(_ship_resources.size() - 1)


func get_trading_items() -> Array[TradingItem]:
	var typed: Array[TradingItem] = []
	typed.assign(_inventory.values())
	return typed


func get_previous_state() -> State:
	return _previous_state


func get_ship() -> ShipResource:
	if _current_ship_index == NO_SHIP:
		return null
	return _ship_resources[_current_ship_index]


func get_ships() -> Array[ShipResource]:
	return _ship_resources


func collect(good: GoodResource, amount: int) -> void:
	var free_space = get_free_capacity()
	var collectable_amount = min(amount, free_space)
	var trading_item = get_trading_item(good.id)
	trading_item.stock += collectable_amount


func get_free_capacity():
	return cargo_capacity - get_used_capacity()


func lose_gold(loss_percentage: float) -> void:
	gold -= int(gold * loss_percentage)
	
	
func lose_goods(loss_percentage: float) -> void:
	for trading_item in get_trading_items():
		trading_item.stock = int(trading_item.stock * loss_percentage)
