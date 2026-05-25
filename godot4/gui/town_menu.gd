class_name TownMenu
extends Control


signal town_left


var trading_system: TradingSystem = TradingSystem.new()

var player: Dictionary = trading_system.player
var city: Dictionary = trading_system.cities[player.current_city]

@onready var city_name = $CenterContainer/VBoxContainer/CityName
@onready var player_gold = $CenterContainer/VBoxContainer/PlayerGold
@onready var player_weight = $CenterContainer/VBoxContainer/PlayerWeight
@onready var background = $Background

@onready var good_name = $CenterContainer/VBoxContainer/GoodRow/GoodName
@onready var good_price = $CenterContainer/VBoxContainer/GoodRow/GoodPrice
@onready var player_amount = $CenterContainer/VBoxContainer/GoodRow/PlayerAmount
@onready var city_amount = $CenterContainer/VBoxContainer/GoodRow/CityAmount
@onready var buy_button = $CenterContainer/VBoxContainer/GoodRow/BuyButton
@onready var sell_button = $CenterContainer/VBoxContainer/GoodRow/SellButton



func _ready():
	_update_gui()


func _process(delta: float):
	trading_system.advance_time(delta)


func _update_gui() -> void:
	city_name.text = city.name
	background.self_modulate = city.background_color
	player_gold.text = "Gold: " + str(player.gold)
	player_weight.text = "Laderaum: " + str(trading_system.get_used_capacity()) + " / " + str(player.cargo_capacity)
	
	good_name.text = "Fisch"
	good_price.text = str(trading_system.get_price(city, "fish")) + "$"
	player_amount.text = str(player.inventory.fish)
	city_amount.text = str(city.market.fish.stock)

func _on_buy_fish_button_pressed():
	trading_system.buy("fish", 1)
	_update_gui()


func _on_sell_fish_button_pressed():
	trading_system.sell("fish", 1)
	_update_gui()


func _on_travel_button_pressed():
	#if trading_system.player.current_city == "A":
		#trading_system.travel("B")
	#else:
		#trading_system.travel("A")
	#city = trading_system.cities[player.current_city]
	#_update_gui()
	town_left.emit()
