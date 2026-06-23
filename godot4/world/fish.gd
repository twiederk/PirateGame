class_name Fish
extends Area2D


@export var good: GoodResource


func _on_body_entered(body):
	if body is Player:
		var player = body as Player
		player.collect(good, randi_range(1, 5))
		queue_free()
