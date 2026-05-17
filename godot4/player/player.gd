class_name Player
extends CharacterBody2D

@export var SPEED : float = 150.0

enum STATE { ON_LAND, IN_BOAT }

var current_state = STATE.ON_LAND

var direction : Vector2 = Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var player_sprite: Sprite2D = $Sprite2D
@onready var boat_sprite: Sprite2D = $BoatSprite2D


func _ready():
	animation_tree.active = true


func _process(_delta):
	_update_animation_parameters()


func _physics_process(_delta):
	direction = Input.get_vector("left", "right","up","down").normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func _update_animation_parameters():
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/is_chopping"] = false
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true

	if direction != Vector2.ZERO:
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction


func enter_exit_boat():
	player_sprite.visible = !player_sprite.visible
	boat_sprite.visible = !boat_sprite.visible
	if current_state == STATE.ON_LAND:
		set_collision_mask_value(2, false)
		set_collision_mask_value(3, true)
		current_state = STATE.IN_BOAT
	else:
		set_collision_mask_value(2, true)
		set_collision_mask_value(3, false)
		current_state = STATE.ON_LAND
