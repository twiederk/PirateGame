class_name MessageWidget
extends Control

@onready var message_label: Label = $MessageLabel
@onready var background_rect: TextureRect = $TextureRect
@onready var timer = $Timer


func _ready():
	MessageBus.message_send.connect(_on_message_send)


func _on_message_send(message: String, color: Color = Color.CHOCOLATE) -> void:
	message_label.text = message
	background_rect.self_modulate = color
	timer.start()
	show()


func _on_timer_timeout() -> void:
	hide()
