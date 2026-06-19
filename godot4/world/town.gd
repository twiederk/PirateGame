class_name Town
extends Area2D


signal town_entered(town_resource: TownResource)

@export var town_resource: TownResource

var town_name: String
var _visited: bool = false
var _inventory: Dictionary = {}

@onready var name_label = $NameLabel


func _ready() -> void:
	name_label.text = town_name
	var goods = town_resource.consumes + town_resource.produces
	for good in goods:
		var stock = _init_stock(good)
		_inventory[good.id] = TradingItem.new(good, stock)


func _init_stock(good: GoodResource) -> int:
		var stock = 0
		if good in town_resource.consumes:
			stock = 10
		if good in town_resource.produces:
			stock = 50
		return stock


func _on_body_entered(body):
	if body is Player:
		set_visited(true)
		town_entered.emit(self)


func get_visited() -> bool:
	return _visited


func set_visited(visited: bool) -> void:
	_visited = visited
	if name_label:
		name_label.visible = visited


func get_background_color() -> Color:
	return town_resource.background_color


func get_cached_stock(good_id: int) -> int:
	return _inventory[good_id].cached_stock


func get_trading_item(good_id: int) -> TradingItem:
	return _inventory[good_id]


func get_trading_items() -> Array[TradingItem]:
	var typed: Array[TradingItem] = []
	typed.assign(_inventory.values())
	return typed


func add_trading_item(trading_item: TradingItem) -> void:
	_inventory[trading_item.good_id] = trading_item


func get_ship_resources() -> Array[ShipResource]:
	return town_resource.ships
