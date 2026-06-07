class_name TradingItem
extends Resource


var good: GoodResource
var stock: int
var cached_stock: int
var last_updated: float


func _init(a_good: GoodResource, a_stock: int = 0):
	good = a_good
	stock = a_stock
	cached_stock = a_stock
