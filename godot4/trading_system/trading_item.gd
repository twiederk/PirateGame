class_name TradingItem
extends Resource


var cached_stock: int
var last_updated: float
var good_base_price: int:
	get:
		return _good_resource.base_price
var good_id: int:
	get:
		return _good_resource.id
var stock: int:
	set(value):
		_stock = max(value, 0)
	get:
		return _stock
var _stock: int
var _good_resource: GoodResource


func _init(good_resource: GoodResource, a_stock: int = 0):
	_good_resource = good_resource
	stock = a_stock
	cached_stock = a_stock


func update_cached_stock(current_game_time: float) -> void:
	cached_stock = stock
	last_updated = current_game_time
