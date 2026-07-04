class_name PauseMenu
extends Control

signal save_button_pressed

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var message_label = $CenterContainer/VBoxContainer/MessageLabel


func _input(_event) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("pause"):
		get_tree().root.set_input_as_handled()
		hide_menu()


func _on_resume_button_pressed():
	hide_menu()


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


func hide_menu():
	get_tree().paused = false
	message_label.text = ""
	hide()
