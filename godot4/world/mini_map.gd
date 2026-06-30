class_name MiniMap
extends Control


@onready var map_texture_rect = $MapTextureRect


func set_image(minimap_image: Image) -> void:
	map_texture_rect.texture = ImageTexture.create_from_image(minimap_image)


func set_player_position(pos: Vector2) -> void:
	map_texture_rect.player_position = pos
