class_name MessageWidget
extends Control

@onready var message_label: Label = $MessageLabel
@onready var timer = $Timer


func show_message(message: String) -> void:
	message_label.text = message
	timer.start()
	show()


func _on_timer_timeout():
	hide()
