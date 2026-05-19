class_name City
extends Control

var trading_system: TradingSystem = TradingSystem.new()

var player: Dictionary = trading_system.player
var city: Dictionary = trading_system.cities[player.current_city]

@onready var city_name = $CenterContainer/VBoxContainer/CityName
@onready var player_gold = $CenterContainer/VBoxContainer/PlayerGold
@onready var city_fish_amount = $CenterContainer/VBoxContainer/CityGoodFish/CityFishAmount
@onready var city_fish_price = $CenterContainer/VBoxContainer/CityGoodFish/CityFishPrice
@onready var city_grain_amount = $CenterContainer/VBoxContainer/CityGoodGrain/CityGrainAmount
@onready var city_grain_price = $CenterContainer/VBoxContainer/CityGoodGrain/CityGrainPrice
@onready var buy_fish_button = $CenterContainer/VBoxContainer/CityGoodFish/BuyFishButton


func _ready():
	_update_gui()
	

func _update_gui() -> void:
	city_name.text = city.name
	player_gold.text = "Gold: " + str(player.gold)
	city_fish_amount.text = str(city.market.fish.stock)
	city_fish_price.text = str(trading_system.get_price(city, "fish")) + "$"
	city_grain_amount.text = str(city.market.grain.stock)
	city_grain_price.text = str(trading_system.get_price(city, "grain")) + "$"


func _on_buy_fish_button_pressed():
	trading_system.buy("fish", 1)
	player_gold.text = "Gold: " + str(player.gold)
	city_fish_amount.text = str(city.market.fish.stock)
	city_fish_price.text = str(trading_system.get_price(city, "fish")) + "$"


func _on_sell_fish_button_pressed():
	trading_system.sell("fish", 1)
	player_gold.text = "Gold: " + str(player.gold)
	city_fish_amount.text = str(city.market.fish.stock)
	city_fish_price.text = str(trading_system.get_price(city, "fish")) + "$"


func _on_travel_button_pressed():
	trading_system.travel("B")
	_update_gui()
