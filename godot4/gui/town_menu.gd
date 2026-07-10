class_name TownMenu
extends Control


signal town_left

const ShipRowScene = preload("res://gui/ship_row.tscn")
const TradingRowScene = preload("res://gui/trading_row.tscn")

var number_format = NumberFormat.new()

var _trading_system: TradingSystem
var _player: Player
var _town: Town
var _treasures: Array[Treasure] = []

@onready var town_name = $CenterContainer/VBoxContainer/TownName
@onready var player_gold = $CenterContainer/VBoxContainer/PlayerGold
@onready var player_weight = $CenterContainer/VBoxContainer/PlayerWeight
@onready var ship_item_table = $CenterContainer/VBoxContainer/ShipItemTable
@onready var background = $Background
@onready var trading_item_table = $CenterContainer/VBoxContainer/TradingItemTable
@onready var travel_button = $CenterContainer/VBoxContainer/TravelButton
@onready var message = $CenterContainer/VBoxContainer/Message
@onready var treasure_map_table = $CenterContainer/VBoxContainer/TreasureTable
@onready var treasure_label = $CenterContainer/VBoxContainer/TreasureTable/HBoxContainer/TreasureLabel


func init(town: Town, player: Player, trading_system: TradingSystem, treasures: Array[Treasure]) -> void:
	_town = town
	_player = player
	_trading_system = trading_system
	_treasures = treasures
	_create_treasure_row()
	_create_ship_rows()
	_create_trading_rows()
	_update_gui()
	travel_button.grab_focus()
	message.text = ""


func _update_gui() -> void:
	town_name.text = "Name: " + _town.town_name
	background.self_modulate = _town.get_background_color()
	player_gold.text = "Gold: " + number_format.format(_player.gold)
	player_weight.text = "Laderaum: " + str(_player.get_used_capacity()) + " / " + str(_player.cargo_capacity)
	_update_all_rows()


func _update_all_rows() -> void:
	for child in trading_item_table.get_children():
		if child is TradingRow:
			child.update_display()


func _create_treasure_row():
	if _player.has_treasure_map() || _treasures.is_empty():
		treasure_map_table.visible = false
		return
	treasure_map_table.visible = true
	treasure_label.text = "Schatzkarte (%d Gold)" % _treasures[0].price
	

func _create_ship_rows() -> void:
	var ship_resources = _town.get_ship_resources()
	ship_item_table.visible = not ship_resources.is_empty()

	for ship_resource in ship_resources:
		var row = ShipRowScene.instantiate()
		row.init(ship_resource)
		row.ship_bought.connect(_on_buy_ship)
		ship_item_table.add_child(row)


func _create_trading_rows() -> void:
	for good_id in _trading_system.goods:
		var row = TradingRowScene.instantiate()
		row.init(good_id, _trading_system, _player, _town)
		row.buy_requested.connect(_on_buy_requested)
		row.sell_requested.connect(_on_sell_requested)
		trading_item_table.add_child(row)


func _on_buy_requested(good_id: int, amount: int) -> void:
	var town_item = _town.get_trading_item(good_id)
	var player_item = _player.get_trading_item(good_id)
	message.text = _trading_system.buy(_player, player_item, town_item, amount)
	_update_gui()


func _on_sell_requested(good_id: int, amount: int) -> void:
	var player_item = _player.get_trading_item(good_id)
	var town_item = _town.get_trading_item(good_id)
	message.text = _trading_system.sell(_player, player_item, town_item, amount)
	_update_gui()


func _on_travel_button_pressed():
	_clear_ship_rows()
	_clear_trading_rows()
	town_left.emit()


func _clear_trading_rows() -> void:
	var children_to_remove = []
	for child in trading_item_table.get_children():
		if child is TradingRow:
			children_to_remove.append(child)
	
	for child in children_to_remove:
		child.queue_free()


func _clear_ship_rows() -> void:
	var children_to_remove = []
	for child in ship_item_table.get_children():
		if child is ShipRow:
			children_to_remove.append(child)
	
	for child in children_to_remove:
		child.queue_free()


func _on_buy_ship(ship_resource: ShipResource) -> void:
	message.text = _buy_ship(ship_resource)
	
	
func _buy_ship(ship_resource: ShipResource) -> String:
	if _player.gold < ship_resource.price:
		return "Nicht genug Gold."
		
	if not _player.add_ship(ship_resource):
		return "Schiff wird bereits besessen."
		
	_player.gold -= ship_resource.price
	_update_gui()
	return "Schiff gekauft."


func _on_buy_treasure() -> void:
	message.text = _buy_treasure()


func _buy_treasure() -> String:
	var treasure = _treasures[0]
	if _player.gold < treasure.price:
		return "Nicht genug Gold."
	_player.buy_treasure(treasure)
	treasure.active = true
	return "Schatzkarte gekauft"
