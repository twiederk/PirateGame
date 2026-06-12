class_name StartMenu
extends Control


@onready var start_button = $CenterContainer/VBoxContainer/StartButton


func _ready():
	start_button.grab_focus()


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://world/main.tscn")


func _on_load_button_pressed():
	SaveManager.load_game_state = {
		"world_seed": 67890,
		"player": {
			"gold": 99,
		}
	}
	get_tree().change_scene_to_file("res://world/main.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
