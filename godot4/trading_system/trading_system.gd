class_name TradingSystem
extends Node


const SIMULATION_STEP: float = 5.0

var current_game_time: float = 0.0
var price_update_interval: float = 2.5
var accumulator: float = 0.0

var _player: Player
var _towns: Array[Town]

var goods: Dictionary = {
	1: preload("res://trading_system/good_fish.tres"),
	2: preload("res://trading_system/good_grain.tres")
}



func _process(delta):
	if _player.in_town():
		return

	advance_time(delta)
	accumulator += delta
	while accumulator >= SIMULATION_STEP:
		simulation()
		accumulator -= SIMULATION_STEP


func init(player: Player, towns: Array[Town]):
	_player = player
	_towns = towns


func advance_time(delta: float):
	current_game_time += delta

func simulation() -> void:
	for town in _towns:
		update_market(town)


func update_market(town: Town):
	if should_update_prices(town):
		town.update_cached_stock(current_game_time)
	
	# Update echter Stock basierend auf Produktion/Verbrauch
	if "fish" in town.town_resource.produces:
		town.set_stock(town.get_stock() + 5)
	if "fish" in town.town_resource.consumes:
		town.set_stock(town.get_stock() - 3)
	town.set_stock(max(1, town.get_stock()))


func get_price(trading_item: TradingItem) -> int:
	var base = trading_item.good.base_price
	var cached_stock = trading_item.cached_stock
	
	# Return min price when no cached stock data
	if cached_stock == 0:
		return int(base * 0.5)
	
	# Preis basiert auf gecachtem Stock, nicht echtem Stock
	var price = base * (20.0 / max(cached_stock, 1))
	var min_price = base * 0.5
	var max_price = base * 3
	return clampi(price, min_price, max_price)


func should_update_prices(town: Town) -> bool:
	var last_update = town._last_update
	return current_game_time - last_update >= price_update_interval


func buy(town: Town, good_id: int, amount: int):
	var trading_item = town.inventory[good_id]
	var price = get_price(trading_item)
	var total_cost = price * amount

	if _player.gold < total_cost:
		return

	if not _player.has_space(amount):
		return

	if town.get_stock() < amount:
		return

	_player.gold -= total_cost
	_player.inventory[good_id] += amount
	town.set_stock(town.get_stock() - amount)


func sell(town: Town, good_id: int, amount: int):
	var trading_item = town.inventory[good_id]
	var price = get_price(trading_item)

	if _player.inventory[good_id] < amount:
		return

	var total_gain = price * amount

	_player.gold += total_gain
	_player.inventory[good_id] -= amount
	town.set_stock(town.get_stock() + amount)
