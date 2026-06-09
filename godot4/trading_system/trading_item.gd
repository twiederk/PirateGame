class_name TradingItem
extends Resource


var good: GoodResource

var cached_stock: int
var last_updated: float
var good_id: int:
	get:
		return good.id
var stock: int:
	set(value):
		_stock = max(value, 0)
	get:
		return _stock
var _stock: int


func _init(a_good: GoodResource, a_stock: int = 0):
	good = a_good
	stock = a_stock
	cached_stock = a_stock


func update_cached_stock(current_game_time: float) -> void:
	cached_stock = stock
	last_updated = current_game_time
