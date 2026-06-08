class_name DebugScreen
extends Control


@onready var seed_label: Label = $VBoxContainer/SeedLabel


func _input(_event) -> void:
	if Input.is_action_just_pressed("debug_screen"):
		if visible:
			hide()
		else:
			show()


func set_seed(seed: int) -> void:
	seed_label.text = "Seed: " + str(seed)
