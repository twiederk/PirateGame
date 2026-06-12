class_name StartGui
extends CanvasLayer


func _ready():
	if not OS.has_feature("editor"):
		get_window().mode = Window.MODE_FULLSCREEN
