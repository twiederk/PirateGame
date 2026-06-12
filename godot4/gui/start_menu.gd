class_name StartMenu
extends Control


@onready var start_button = $CenterContainer/VBoxContainer/StartButton


func _ready():
	start_button.grab_focus()


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://world/main.tscn")


func _on_load_button_pressed():
	SaveManager.load(1)
	get_tree().change_scene_to_file("res://world/main.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
