class_name MapBorders
extends Node2D

@onready var north_border = $NorthBorder
@onready var south_border = $SouthBorder
@onready var west_border = $WestBorder
@onready var east_border = $EastBorder


func set_borders(north_limit: float, south_limit: float, west_limit: float, east_limit: float, margin: Vector2 = Vector2.ZERO) -> void:
	north_border.position = Vector2(margin.x, north_limit + margin.y)
	west_border.position = Vector2(west_limit + margin.x, margin.y)
	south_border.position = Vector2(margin.x, south_limit - margin.y)
	east_border.position = Vector2(east_limit - margin.x, margin.y)
