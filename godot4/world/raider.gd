class_name Raider
extends CharacterBody2D


const SPEED: float = 150.0

enum State { IDLE, CHASE }


var direction: Vector2 = Vector2.ZERO
var player: Player = null
var current_state: State = State.IDLE


@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var animation_tree = $Sprite2D/AnimationTree


func _ready() -> void:
	animation_tree.active = true


func _process(_delta: float) -> void:
	_update_animation_parameters()


func _physics_process(_delta: float):
	if current_state == State.IDLE:
		return
	
	direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED
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


func _on_detection_zone_body_entered(body):
	if not body is Player:
		return
	player = body as Player
	current_state = State.CHASE


func _on_detection_zone_body_exited(body):
	if not body is Player:
		return
	player = null
	current_state = State.IDLE
