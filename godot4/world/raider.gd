class_name Raider
extends CharacterBody2D


const LAND_SPEED: float = 200.0

var current_speed: float = LAND_SPEED
var direction: Vector2 = Vector2.ZERO


@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var animation_tree = $Sprite2D/AnimationTree


func _ready() -> void:
	animation_tree.active = true


func _process(_delta: float) -> void:
	_update_animation_parameters()


func _physics_process(_delta: float):
	move_and_slide()


func _update_animation_parameters():
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true

	if direction != Vector2.ZERO:
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction
