class_name TownTile
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


func _to_string() -> String:
	if town_resource == null:
		return "TownTile{name=%s, stock=%d, cached_stock=%d, last_update=%.2f, town_resource=null}" % [name, _stock, _cached_stock, _last_update]

	return "TownTile{name=%s, stock=%d, cached_stock=%d, last_update=%.2f, town_resource={name=%s, background_color=%s, produces=%s, consumes=%s, stock=%d}}" % [
		name,
		_stock,
		_cached_stock,
		_last_update,
		town_resource.name,
		str(town_resource.background_color),
		str(town_resource.produces),
		str(town_resource.consumes),
		town_resource.stock
	]
