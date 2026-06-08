class_name DebugScreen
extends Control


func _ready() -> void:
	pass


func _input(_event) -> void:
	if Input.is_action_just_pressed("debug_screen"):
		if visible:
			hide()
		else:
			show()
