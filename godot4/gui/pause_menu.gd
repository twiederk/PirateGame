class_name PauseMenu
extends Control

signal save_button_pressed

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton


func _on_resume_button_pressed():
	get_tree().paused = false
	hide()


func _on_menu_button_pressed():
	SaveManager.load_game_state = {}
	get_tree().paused = false
	get_tree().change_scene_to_file("res://gui/start_gui.tscn")


func _on_save_button_pressed():
	save_button_pressed.emit()


func show_menu():
	get_tree().paused = true
	resume_button.grab_focus()
	show()
