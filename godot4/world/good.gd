class_name Good
extends Area2D

@export var good_resource: GoodResource
@onready var sprite_2d = $Sprite2D


func _ready() -> void:
	sprite_2d.frame = good_resource.frame


func _on_body_entered(body) -> void:
	if not body is Player:
		return

	if body.get_free_capacity() <= 0:
		MessageBus.message_send.emit("Du hast keinen Platz mehr im Laderaum.")
		return

	var player = body as Player
	var amount = randi_range(1, 5)
	player.collect(good_resource, amount)
	Sound.play(Sound.good_pickup)
	var message = str("Du hast ", amount, " ", good_resource.name, " eingesammelt.")
	MessageBus.message_send.emit(message)
	queue_free()
