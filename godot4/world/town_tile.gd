class_name TownTile
extends Area2D


signal town_entered


func _on_body_entered(_body):
	town_entered.emit()
