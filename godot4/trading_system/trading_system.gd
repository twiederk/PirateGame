class_name TradingSystem


var goods = {
	"fish": { "base_price": 10 },
	"grain": { "base_price": 15 }
}


var cities = {
	"A": {
		"name": "Harbor",
		"produces": ["fish"],
		"consumes": ["grain"],
		"market": {
			"fish": { "stock": 50 },
			"grain": { "stock": 10 }
		}
	},
	"B": {
		"name": "Farm",
		"produces": ["grain"],
		"consumes": ["fish"],
		"market": {
			"fish": { "stock": 10 },
			"grain": { "stock": 50 }
		}
	}
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


func get_price(city_id: String, good_id: String) -> int:
	var base = goods[good_id]["base_price"]
	var stock = cities[city_id]["market"][good_id]["stock"]

	# Simple rule:
	# low stock → expensive, high stock → cheap
	var price = base * (20.0 / max(stock, 1))
	var min_price = base * 0.5
	var max_price = base * 3

	return clampi(price, min_price, max_price)


func get_used_capacity() -> int:
	var total = 0
	for g in player.inventory:
		total += player.inventory[g]
	return total


func has_space(amount: int) -> bool:
	return get_used_capacity() + amount <= player.cargo_capacity
	
	
func buy(good_id: String, amount: int):
	var city = player.current_city
	var price = get_price(city, good_id)
	var total_cost = price * amount

	if player.gold < total_cost:
		return

	if not has_space(amount):
		return

	if cities[city]["market"][good_id]["stock"] < amount:
		return

	# apply transaction
	player.gold -= total_cost
	player.inventory[good_id] += amount
	cities[city]["market"][good_id]["stock"] -= amount


func sell(good_id: String, amount: int):
	var city = player.current_city
	var price = get_price(city, good_id)

	if player.inventory[good_id] < amount:
		return

	var total_gain = price * amount

	player.gold += total_gain
	player.inventory[good_id] -= amount
	cities[city]["market"][good_id]["stock"] += amount


func update_market(city_id: String):
	var city = cities[city_id]

	for good_id in city.market:
		if good_id in city.produces:
			city.market[good_id]["stock"] += 5
		if good_id in city.consumes:
			city.market[good_id]["stock"] -= 3

		city.market[good_id]["stock"] = max(1, city.market[good_id]["stock"])
