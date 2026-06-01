class_name TownMenu
extends Control


signal town_left


var _trading_system: TradingSystem
var _player: Player
var _town: Town

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



func _update_gui() -> void:
	town_name.text = "Name: " + _town.get_town_name()
	background.self_modulate = _town.get_background_color()
	player_gold.text = "Gold: " + str(_player.gold)
	player_weight.text = "Laderaum: " + str(_trading_system.get_used_capacity()) + " / " + str(_player.cargo_capacity)
	
	good_name.text = "Fisch"
	good_price.text = str(_trading_system.get_price(_town, "fish"))
	player_amount.text = str(_player.inventory.fish)
	town_amount.text = str(_town.get_stock())

func _on_buy_fish_button_pressed():
	_trading_system.buy(_town, "fish", 1)
	_update_gui()


func _on_sell_fish_button_pressed():
	_trading_system.sell(_town, "fish", 1)
	_update_gui()


func _on_travel_button_pressed():
	town_left.emit()


func init(town: Town, player: Player, trading_system: TradingSystem) -> void:
	_town = town
	_player = player
	_trading_system = trading_system
	_update_gui()
