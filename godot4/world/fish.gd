class_name Fish
extends Area2D

@export var good: GoodResource


func _on_body_entered(body):
	if not body is Player:
		return

	var player = body as Player
	var amount = randi_range(1, 5)
	player.collect(good, amount)
	var message = str("Du hast ", amount, " ", good.name, " eingesammelt.")
	MessageBus.message_send.emit(message)
	queue_free()
