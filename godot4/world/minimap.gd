class_name Minimap
extends Control


@onready var minimap_texture = $MapTextureRect
@onready var player_sprite = $AnimatedSpriteD


func _ready() -> void:
	get_viewport().size_changed.connect(center_on_screen)


func set_image(minimap_image: Image) -> void:
	minimap_texture.texture = ImageTexture.create_from_image(minimap_image)
	minimap_texture.size = minimap_image.get_size() * 2
	size = minimap_texture.size


func center_on_screen() -> void:
	position = (get_viewport_rect().size - size) * 0.5


func set_player_position(player_position: Vector2) -> void:
	player_sprite.position = player_position
