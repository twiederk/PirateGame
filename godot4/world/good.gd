class_name Good
extends Area2D

@export var good_resource: GoodResource


func _on_body_entered(body):
	if not body is Player:
		return

	var player = body as Player
	var amount = randi_range(1, 5)
	player.collect(good_resource, amount)
	var message = str("Du hast ", amount, " ", good_resource.name, " eingesammelt.")
	MessageBus.message_send.emit(message)
	queue_free()
