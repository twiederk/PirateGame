class_name TownMenu
extends Control


signal town_left

const TradingRowScene = preload("res://gui/trading_row.tscn")

var number_format = NumberFormat.new()

var _trading_system: TradingSystem
var _player: Player
var _town: Town

@onready var rows_container = $CenterContainer/VBoxContainer
@onready var town_name = $CenterContainer/VBoxContainer/TownName
@onready var player_gold = $CenterContainer/VBoxContainer/PlayerGold
@onready var player_weight = $CenterContainer/VBoxContainer/PlayerWeight
@onready var background = $Background
@onready var travel_button = $CenterContainer/VBoxContainer/TravelButton


func _update_gui() -> void:
	town_name.text = "Name: " + _town.get_town_name()
	background.self_modulate = _town.get_background_color()
	player_gold.text = "Gold: " + number_format.format(_player.gold)
	player_weight.text = "Laderaum: " + str(_player.get_used_capacity()) + " / " + str(_player.cargo_capacity)
	_update_all_rows()


func _update_all_rows() -> void:
	for child in rows_container.get_children():
		if child is HBoxContainer and child != rows_container.get_child(rows_container.get_child_count() - 1):
			# Check if this is a TradingRow by trying to call update_display
			if child.has_method("update_display"):
				child.update_display()


func _create_trading_rows() -> void:
	# Iterate over all goods in TradingSystem
	for good_id in _trading_system.goods:
		var row = TradingRowScene.instantiate()
		row.init(good_id, _trading_system, _player, _town)
		row.buy_requested.connect(_on_buy_requested)
		row.sell_requested.connect(_on_sell_requested)
		
		# Insert before TravelButton (which should be the last child)
		var travel_button_index = rows_container.get_child_count() - 1
		rows_container.add_child(row)
		rows_container.move_child(row, travel_button_index)


func _on_buy_requested(good_id: int, amount: int) -> void:
	var town_item = _town.get_trading_item(good_id)
	var player_item = _player.get_trading_item(good_id)
	_trading_system.buy(_player, player_item, town_item, amount)
	_update_gui()


func _on_sell_requested(good_id: int, amount: int) -> void:
	var player_item = _player.get_trading_item(good_id)
	var town_item = _town.get_trading_item(good_id)
	_trading_system.sell(_player, player_item, town_item, amount)
	_update_gui()


func _on_travel_button_pressed():
	_clear_trading_rows()
	town_left.emit()


func _clear_trading_rows() -> void:
	# Remove all trading rows, keeping only the header and travel button
	var children_to_remove = []
	for child in rows_container.get_children():
		if child is TradingRow:
			children_to_remove.append(child)
	
	for child in children_to_remove:
		child.queue_free()


func init(town: Town, player: Player, trading_system: TradingSystem) -> void:
	_town = town
	_player = player
	_trading_system = trading_system
	_create_trading_rows()
	_update_gui()
	travel_button.grab_focus()
