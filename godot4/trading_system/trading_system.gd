class_name TradingSystem


var goods = {
	"fish": { "base_price": 10 },
	"grain": { "base_price": 15 }
}



var player = {
	"gold": 100,
	"cargo_capacity": 20,
	"inventory": {
		"fish": 0,
		"grain": 0
	},
	"current_city": "A"
}

var current_game_time = 0.0
var price_update_interval = 5.0


func get_price(town: TownTile, good_id: String) -> int:
	var base = goods[good_id]["base_price"]
	var cached_stock = town.get_cached_stock()
	
	# Preis basiert auf gecachtem Stock, nicht echtem Stock
	var price = base * (20.0 / max(cached_stock, 1))
	var min_price = base * 0.5
	var max_price = base * 3
	return clampi(price, min_price, max_price)


func should_update_prices(town: TownTile) -> bool:
	var last_update = town._last_update
	return current_game_time - last_update >= price_update_interval


func get_used_capacity() -> int:
	var total = 0
	for g in player.inventory:
		total += player.inventory[g]
	return total


func has_space(amount: int) -> bool:
	return get_used_capacity() + amount <= player.cargo_capacity
	
	
func buy(town: TownTile, good_id: String, amount: int):
	var price = get_price(town, good_id)
	var total_cost = price * amount

	if player.gold < total_cost:
		return

	if not has_space(amount):
		return

	if town.get_stock() < amount:
		return

	player.gold -= total_cost
	player.inventory[good_id] += amount
	town.set_stock(town.get_stock() - amount)


func sell(town: TownTile, good_id: String, amount: int):
	var price = get_price(town, good_id)

	if player.inventory[good_id] < amount:
		return

	var total_gain = price * amount

	player.gold += total_gain
	player.inventory[good_id] -= amount
	town.set_stock(town.get_stock() + amount)


func simulation(towns: Array) -> void:
	print("TradingSystem.simulation")
	for town in towns:
		update_market(town)


func update_market(town: TownTile):
	print("TradingSystem.update_market: " + town.name)
	if should_update_prices(town):
		town.update_cached_stock(current_game_time)
	
	# Update echter Stock basierend auf Produktion/Verbrauch
	if "fish" in town.town_resource.produces:
		town.set_stock(town.get_stock() + 5)
	if "fish" in town.town_resource.consumes:
		town.set_stock(town.get_stock() - 3)
	town.set_stock(max(1, town.get_stock()))


func advance_time(delta: float):
	current_game_time += delta
