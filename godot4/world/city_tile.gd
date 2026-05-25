class_name CityTile
extends Area2D


signal city_entered


func _on_body_entered(_body):
	city_entered.emit()
