class_name Player
extends CharacterBody2D

@export var SPEED : float = 150.0

enum STATE { ON_LAND, ON_SHIP, IN_TOWN }

var current_state = STATE.ON_LAND

var direction : Vector2 = Vector2.ZERO

var has_ship : bool = false
var gold : int = 100
var cargo_capacity : int = 20
var _inventory: Dictionary = {
		1: TradingItem.new(load("res://trading_system/good_fish.tres")),
		2: TradingItem.new(load("res://trading_system/good_grain.tres"))
	}
@onready var animation_player = $WandererSprite2D/AnimationPlayer
@onready var animation_tree = $WandererSprite2D/AnimationTree
@onready var wanderer_sprite: Sprite2D = $WandererSprite2D
@onready var ship_sprite: Sprite2D = $ShipSprite2D


func _ready():
	animation_tree.active = true


func _process(_delta):
	_update_animation_parameters()


func _physics_process(_delta):
	if current_state == STATE.IN_TOWN:
		return

	direction = Input.get_vector("left", "right","up","down").normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func _update_animation_parameters():
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/is_chopping"] = false
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true

	if direction != Vector2.ZERO:
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction


func board_ship() -> void:
	if not has_ship:
		return
	
	wanderer_sprite.visible = !wanderer_sprite.visible
	ship_sprite.visible = !ship_sprite.visible
	if current_state == STATE.ON_LAND:
		set_collision_mask_value(2, false)
		set_collision_mask_value(3, true)
		current_state = STATE.ON_SHIP
	else:
		set_collision_mask_value(2, true)
		set_collision_mask_value(3, false)
		current_state = STATE.ON_LAND


func _on_town_tile_town_entered(_town: Town) -> void:
	current_state = STATE.IN_TOWN


func _on_town_menu_town_left() -> void:
	current_state = STATE.ON_LAND


func in_town() -> bool:
	return current_state == STATE.IN_TOWN


func has_space(amount: int) -> bool:
	return get_used_capacity() + amount <= cargo_capacity


func get_used_capacity() -> int:
	var total = 0
	for good_id in _inventory:
		total += _inventory[good_id].stock
	return total


func get_trading_item(good_id: int) -> TradingItem:
	return _inventory[good_id]
