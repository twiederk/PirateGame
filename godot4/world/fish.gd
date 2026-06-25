class_name Fish
extends Area2D

signal good_collected(good: GoodResource, amount: int)

@export var good: GoodResource


func _on_body_entered(body):
	if body is Player:
		var player = body as Player
		var amount = randi_range(1, 5)
		player.collect(good, amount)
		good_collected.emit(good, amount)
		queue_free()
