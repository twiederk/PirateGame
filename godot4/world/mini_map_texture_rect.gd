class_name MiniMapTextureRect
extends TextureRect

var player_position: Vector2 = Vector2.ZERO


func _draw():
	draw_circle(player_position, 5, Color.RED)
