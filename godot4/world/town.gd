class_name Town
extends Area2D


signal town_entered(town_resource: TownResource)

@export var town_resource: TownResource

var inventory: Dictionary = {}


func initialize_inventory(trading_system: TradingSystem) -> void:
	inventory.clear()
	for good_id in trading_system.goods:
		var good = trading_system.goods[good_id]
		var stock = init_stock(good)
		inventory[good_id] = TradingItem.new(good, stock)


func init_stock(good: GoodResource) -> int:
		var stock = 0
		if good in town_resource.consumes:
			stock = 10
		if good in town_resource.produces:
			stock = 50
		return stock


func _on_body_entered(_body):
	town_entered.emit(self)


func get_town_name() -> String:
	return town_resource.name


func get_background_color() -> Color:
	return town_resource.background_color


func get_cached_stock(good_id: int) -> int:
	if inventory.has(good_id):
		return inventory[good_id].cached_stock
	return 0
	
