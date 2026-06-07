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
	print("TradingSystem.simulation()")
	for town in _towns:
		update_market(town)


func update_market(town: Town):
	for trading_item in town.inventory.values():
		if should_update_prices(trading_item):
			trading_item.update_cached_stock(current_game_time)
	
	for good in town.town_resource.produces:
		town.inventory[good.id].stock += 5
	for good in town.town_resource.consumes:
		town.inventory[good.id].stock -= 3
		town.inventory[good.id].stock = max(0, town.inventory[good.id].stock)


func get_price(trading_item: TradingItem) -> int:
	var base = trading_item.good.base_price
	var min_price = int(base * 0.5)
	var max_price = int(base * 3)
	var cached_stock = trading_item.cached_stock
	
	# Return min price when no cached stock data
	if cached_stock == 0:
		return min_price
	
	# Price based on cached stock, not actual stock
	var price = int(base * (20.0 / max(cached_stock, 1)))
	return clampi(price, min_price, max_price)


func should_update_prices(trade_item: TradingItem) -> bool:
	var last_update = trade_item.last_updated
	return current_game_time - last_update >= price_update_interval


func buy(trading_item: TradingItem, amount: int):
	var price = get_price(trading_item)
	var total_cost = price * amount

	if _player.gold < total_cost:
		return

	if not _player.has_space(amount):
		return

	if trading_item.stock < amount:
		return

	_player.gold -= total_cost
	_player.inventory[trading_item.good.id].stock += amount
	trading_item.stock -= amount


func sell(player_trading_item: TradingItem, town_trading_item: TradingItem, amount: int):
	var price = get_price(town_trading_item)

	if player_trading_item.stock < amount:
		return

	var total_gain = price * amount

	_player.gold += total_gain
	player_trading_item.stock -= amount
	town_trading_item.stock += amount
