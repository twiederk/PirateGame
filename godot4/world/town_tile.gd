class_name TownTile
extends Area2D


signal town_entered(town_resource: TownResource)

@export var town_resource: TownResource

var _stock: int
var _cached_stock: int


func _ready() -> void:
	_stock = town_resource.stock
	_cached_stock = town_resource.stock


func _on_body_entered(_body):
	town_entered.emit(self)


func get_background_color() -> Color:
	return town_resource.background_color
	
func get_cached_stock(good_id: String) -> int:
	return _cached_stock
	

func get_stock(good_id: String) -> int:
	return _stock


func set_stock(amount: int) -> void:
	_stock = amount
