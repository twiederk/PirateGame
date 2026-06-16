class_name PauseMenu
extends Control

signal save_button_pressed

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var message_label = $CenterContainer/VBoxContainer/MessageLabel


func _on_resume_button_pressed():
	get_tree().paused = false
	message_label.text = ""
	hide()


func _on_menu_button_pressed():
	SaveManager.load_game_state = {}
	get_tree().paused = false
	get_tree().change_scene_to_file("res://gui/start_gui.tscn")


func _on_save_button_pressed():
	save_button_pressed.emit()
	message_label.text = "Spiel gespeichert"



func show_menu():
	get_tree().paused = true
	resume_button.grab_focus()
	show()
