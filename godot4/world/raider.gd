class_name Raider
extends CharacterBody2D

const FightCloudScene = preload("res://world/fight_cloud.tscn")

const SPEED: float = 200.0

enum State { IDLE, CHASE }


var direction: Vector2 = Vector2.ZERO
var player: Player = null
var current_state: State = State.IDLE


@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var animation_tree = $Sprite2D/AnimationTree


func _ready() -> void:
	current_state = State.IDLE
	animation_tree.active = true


func _process(_delta: float) -> void:
	_update_animation_parameters()


func _physics_process(_delta: float) -> void:
	if PauseManager.is_simulation_paused():
		direction = Vector2.ZERO
		velocity = Vector2.ZERO
		return

	if current_state == State.IDLE:
		return
	
	direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()


func _update_animation_parameters() -> void:
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true

	if direction != Vector2.ZERO:
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction


func _on_detection_zone_body_entered(body) -> void:
	if not body is Player:
		return
	player = body as Player
	current_state = State.CHASE


func _on_detection_zone_body_exited(body) -> void:
	if not body is Player:
		return
	player = null
	current_state = State.IDLE


func _on_robbery_zone_body_entered(body) -> void:
	if not body is Player:
		return
	_rob_player()
	Sound.play(Sound.raider_catch)
	_show_animation()
	queue_free()


func _rob_player() -> void:
	if player == null:
		return
	player.lose_gold(0.5)
	player.lose_goods(0.5)
	MessageBus.message_send.emit("Räuberangriff! Du verlierst die Hälfte deines Goldes und deiner Waren.")


func _show_animation() -> void:
	var fight_cloud = FightCloudScene.instantiate()
	fight_cloud.position = global_position
	get_parent().add_child(fight_cloud)
