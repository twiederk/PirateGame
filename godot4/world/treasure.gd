class_name Treasure
extends Node2D

@export var gold: int = 10_000

var texture: ImageTexture = null
var player: Player = null


func _on_treasure_area_body_entered(body):
	if body is Player:
		player = body as Player


func _on_treasure_area_body_exited(body):
	if body is Player:
		player = null


func _input(_event: InputEvent):
	if Input.is_action_just_pressed("search") and _is_player_in_area():
		_found_treasure()


func _is_player_in_area() -> bool:
	return player != null
	
	
func _found_treasure() -> void:
	Sound.play(Sound.treasure_pickup)
	player.found_gold(gold)
	var message = str("Goldschat! Du hast ", gold, " Gold gefunden.")
	MessageBus.message_send.emit(message)
	queue_free()
