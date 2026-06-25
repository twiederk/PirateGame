class_name TradingSystem
extends Node

const SIMULATION_STEP: float = 30.0
const PRICE_UPDATE_INTERVAL: float = 10.0

var current_game_time: float = 0.0
var accumulator: float = 0.0


var goods: Dictionary = {
	1: preload("res://trading_system/good_fish.tres"),
	2: preload("res://trading_system/good_grain.tres"),
	3: preload("res://trading_system/good_wood.tres"),
}


func simulation(delta: float, towns: Array[Town]) -> void:
	advance_time(delta)
	accumulator += delta
	if accumulator >= SIMULATION_STEP:
		update_towns(towns)
		accumulator = 0.0


func advance_time(delta: float) -> void:
	current_game_time += delta


func update_towns(towns) -> void:
	for town in towns:
		update_town(town)


func update_town(town: Town):
	for trading_item in town.get_trading_items():
		if should_update_prices(trading_item):
			trading_item.update_cached_stock(current_game_time)
	
	for good in town.town_resource.produces:
		town.get_trading_item(good.id).stock += 5
	for good in town.town_resource.consumes:
		town.get_trading_item(good.id).stock -= 3


func get_price(trading_item: TradingItem) -> int:
	var base = trading_item.good_base_price
	var min_price = int(base * 0.5)
	var max_price = int(base * 3)
	var cached_stock = trading_item.cached_stock
		
	var price = int(base * (20.0 / max(cached_stock, 1)))
	return clampi(price, min_price, max_price)


func should_update_prices(trade_item: TradingItem) -> bool:
	var last_update = trade_item.last_updated
	return current_game_time - last_update >= PRICE_UPDATE_INTERVAL


func buy(player: Player, player_trading_item: TradingItem, town_trading_item: TradingItem, amount: int) -> String:
	var price = get_price(town_trading_item)
	var total_cost = price * amount

	if player.gold < total_cost:
		return "Nicht genug Gold"

	if not player.has_space(amount):
		return "Laderaum is voll."

	if town_trading_item.stock < amount:
		return "Ware ist ausverkauft."

	player.gold -= total_cost
	player_trading_item.stock += amount
	town_trading_item.stock -= amount
	return "Ware gekauft."


func sell(player: Player, player_trading_item: TradingItem, town_trading_item: TradingItem, amount: int) -> String:
	var price = get_price(town_trading_item)

	if player_trading_item.stock < amount:
		return "Keine Ware."

	var total_gain = price * amount

	player.gold += total_gain
	player_trading_item.stock -= amount
	town_trading_item.stock += amount
	
	return "Ware verkauft."
