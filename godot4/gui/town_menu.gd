class_name TownMenu
extends Control


signal town_left

const ShipRowScene = preload("res://gui/ship_row.tscn")
const TradingRowScene = preload("res://gui/trading_row.tscn")

var number_format = NumberFormat.new()

var _trading_system: TradingSystem
var _player: Player
var _town: Town
var _towns_with_treasure: Array[Town] = []

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
@onready var treasure_hint_table = $CenterContainer/VBoxContainer/TreasureHintTable
@onready var treasure_hint_label = $CenterContainer/VBoxContainer/TreasureHintTable/TreasureHintLabel


func init(town: Town, player: Player, trading_system: TradingSystem, towns_with_treasure: Array[Town]) -> void:
	_town = town
	_player = player
	_trading_system = trading_system
	_towns_with_treasure = towns_with_treasure
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
	if _player.has_treasure_map():
		treasure_map_table.visible = false
		treasure_hint_table.visible = false
	elif _town.has_treasure():
		_show_treasure_price()
	else:
		_show_treasure_hint()


func _show_treasure_hint():
	treasure_map_table.visible = false
	treasure_hint_table.visible = true
	treasure_hint_label.text = _build_treasure_hint_text()


func _build_treasure_hint_text() -> String:
	var nearest_town_with_treasure = _get_nearest_town_with_treasure()

	var rarity_text = _get_rarity_text(nearest_town_with_treasure.treasure.resource)
	if nearest_town_with_treasure.get_visited():
		return "In %s verkaufen sie eine %s." % [nearest_town_with_treasure.town_name, rarity_text]

	var direction = _get_cardinal_direction(nearest_town_with_treasure.global_position - _town.global_position)
	return "In einer Stadt im %s verkaufen sie eine %s." % [direction, rarity_text]


func _get_nearest_town_with_treasure() -> Town:
	var nearest_town: Town = null
	var nearest_distance_squared = INF

	for treasure_town in _towns_with_treasure:
		var distance_squared = _town.global_position.distance_squared_to(treasure_town.global_position)
		if distance_squared < nearest_distance_squared:
			nearest_distance_squared = distance_squared
			nearest_town = treasure_town

	return nearest_town


func _get_cardinal_direction(direction_vector: Vector2) -> String:
	var angle_deg = wrapf(rad_to_deg(atan2(-direction_vector.y, direction_vector.x)), 0.0, 360.0)
	if angle_deg >= 337.5 or angle_deg < 22.5:
		return "Osten"
	if angle_deg < 67.5:
		return "Nordosten"
	if angle_deg < 112.5:
		return "Norden"
	if angle_deg < 157.5:
		return "Nordwesten"
	if angle_deg < 202.5:
		return "Westen"
	if angle_deg < 247.5:
		return "Südwesten"
	if angle_deg < 292.5:
		return "Süden"
	return "Südosten"


func _get_rarity_text(treasure_resource: TreasureResource) -> String:
	match treasure_resource.rare_type:
		TreasureResource.Rareness.VERY_RARE:
			return "sehr seltene Schatzkarte"
		TreasureResource.Rareness.RARE:
			return "seltene Schatzkarte"
		_:
			return "Schatzkarte"


func _show_treasure_price():
	treasure_map_table.visible = true
	treasure_hint_table.visible = false
	treasure_label.text = "Schatzkarte (%d Gold)" % _town.treasure.price


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
	var treasure = _town.treasure
	if _player.gold < treasure.price:
		return "Nicht genug Gold."
	_player.buy_treasure(treasure)
	treasure.active = true
	return "Schatzkarte gekauft"
