class_name ZoomWidget
extends Control


@onready var zoom_label: Label = $ZoomLabel


func set_zoom(camera_zoom: Vector2) -> void:
	zoom_label.text = " Zoom: " + str(snapped(camera_zoom.x, 0.1))
