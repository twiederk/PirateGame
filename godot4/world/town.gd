class_name Town
extends Area2D


signal town_entered(town_resource: TownResource)

@export var town_resource: TownResource

var _stock: int
var _cached_stock: int
var _last_update: float


func _ready() -> void:
	_stock = town_resource.stock
	_cached_stock = town_resource.stock


func _on_body_entered(_body):
	town_entered.emit(self)


func get_background_color() -> Color:
	return town_resource.background_color


func get_cached_stock() -> int:
	return _cached_stock
	

func get_stock() -> int:
	return _stock


func set_stock(amount: int) -> void:
	_stock = amount


func update_cached_stock(current_game_time: float) -> void:
	_cached_stock = _stock
	_last_update = current_game_time
