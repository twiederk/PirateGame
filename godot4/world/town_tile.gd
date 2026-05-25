class_name CityTile
extends Area2D


signal town_entered


func _on_body_entered(_body):
	town_entered.emit()
