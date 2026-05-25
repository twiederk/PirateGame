class_name TownMenu
extends Control


signal town_left

var trading_system: TradingSystem = TradingSystem.new()

var player: Dictionary = trading_system.player
var _town: TownTile

@onready var town_name = $CenterContainer/VBoxContainer/TownName
@onready var player_gold = $CenterContainer/VBoxContainer/PlayerGold
@onready var player_weight = $CenterContainer/VBoxContainer/PlayerWeight
@onready var background = $Background

@onready var good_name = $CenterContainer/VBoxContainer/GoodRow/GoodName
@onready var good_price = $CenterContainer/VBoxContainer/GoodRow/GoodPrice
@onready var player_amount = $CenterContainer/VBoxContainer/GoodRow/PlayerAmount
@onready var town_amount = $CenterContainer/VBoxContainer/GoodRow/TownAmount
@onready var buy_button = $CenterContainer/VBoxContainer/GoodRow/BuyButton
@onready var sell_button = $CenterContainer/VBoxContainer/GoodRow/SellButton


func _process(delta: float):
	trading_system.advance_time(delta)


func _update_gui() -> void:
	town_name.text = _town.name
	background.self_modulate = _town.get_background_color()
	player_gold.text = "Gold: " + str(player.gold)
	player_weight.text = "Laderaum: " + str(trading_system.get_used_capacity()) + " / " + str(player.cargo_capacity)
	
	good_name.text = "Fisch"
	good_price.text = str(trading_system.get_price(_town, "fish")) + "$"
	player_amount.text = str(player.inventory.fish)
	town_amount.text = str(_town.get_stock())

func _on_buy_fish_button_pressed():
	trading_system.buy(_town, "fish", 1)
	_update_gui()


func _on_sell_fish_button_pressed():
	trading_system.sell(_town, "fish", 1)
	_update_gui()


func _on_travel_button_pressed():
	#if trading_system.player.current_city == "A":
		#trading_system.travel("B")
	#else:
		#trading_system.travel("A")
	#town = trading_system.cities[player.current_city]
	_update_gui()
	town_left.emit()


func set_town(town: TownTile) -> void:
	_town = town
	_update_gui()
	
