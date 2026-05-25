class_name TownTile
extends Area2D


signal town_entered(town_resource: TownResource)

@export var town_resource: TownResource

var market: Dictionary

func _ready() -> void:
	market = town_resource.market.duplicate(true)


func _on_body_entered(_body):
	town_entered.emit(self)


func get_background_color() -> Color:
	return town_resource.background_color
	

func get_cached_stock(good_id: String) -> int:
	return market[good_id]["cached_stock"]
