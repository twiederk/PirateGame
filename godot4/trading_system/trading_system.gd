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
			"fish": { "stock": 50, "cached_stock": 50, "last_update": 0 },
			"grain": { "stock": 10, "cached_stock": 10, "last_update": 0 }
		}
	},
	"B": {
		"name": "Farm",
		"produces": ["grain"],
		"consumes": ["fish"],
		"market": {
			"fish": { "stock": 10, "cached_stock": 10, "last_update": 0 },
			"grain": { "stock": 50, "cached_stock": 50, "last_update": 0 }
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

var current_game_time = 0.0
var price_update_interval = 60.0 # Preis aktualisiert sich alle 60 Sekunden

# Berechnet Preis basierend auf GECACHTEM Stock
func get_price(city: Dictionary, good_id: String) -> int:
	var base = goods[good_id]["base_price"]
	var cached_stock = city["market"][good_id]["cached_stock"]
	
	# Preis basiert auf gecachtem Stock, nicht echtem Stock
	var price = base * (20.0 / max(cached_stock, 1))
	var min_price = base * 0.5
	var max_price = base * 3
	return clampi(price, min_price, max_price)


func should_update_prices(city: Dictionary, good_id: String) -> bool:
	var last_update = city["market"][good_id]["last_update"]
	return current_game_time - last_update >= price_update_interval


func update_cached_stock(city: Dictionary, good_id: String):
	# Aktualisiere gecachten Stock zum echten Stock
	city["market"][good_id]["cached_stock"] = city["market"][good_id]["stock"]
	city["market"][good_id]["last_update"] = current_game_time


func get_used_capacity() -> int:
	var total = 0
	for g in player.inventory:
		total += player.inventory[g]
	return total


func has_space(amount: int) -> bool:
	return get_used_capacity() + amount <= player.cargo_capacity
	
	
func buy(good_id: String, amount: int):
	var city = cities[player.current_city]
	var price = get_price(city, good_id)
	var total_cost = price * amount

	if player.gold < total_cost:
		return

	if not has_space(amount):
		return

	if city["market"][good_id]["stock"] < amount:
		return

	# apply transaction
	player.gold -= total_cost
	player.inventory[good_id] += amount
	city["market"][good_id]["stock"] -= amount


func sell(good_id: String, amount: int):
	var city = cities[player.current_city]
	var price = get_price(city, good_id)

	if player.inventory[good_id] < amount:
		return

	var total_gain = price * amount

	player.gold += total_gain
	player.inventory[good_id] -= amount
	city["market"][good_id]["stock"] += amount


func update_market(city_id: String):
	var city = cities[city_id]
	for good_id in city.market:
		# Aktualisiere gecachte Preise wenn Zeit abgelaufen
		if should_update_prices(city, good_id):
			update_cached_stock(city, good_id)
		
		# Update echter Stock basierend auf Produktion/Verbrauch
		if good_id in city.produces:
			city.market[good_id]["stock"] += 5
		if good_id in city.consumes:
			city.market[good_id]["stock"] -= 3
		
		city.market[good_id]["stock"] = max(1, city.market[good_id]["stock"])


func travel(to_city: String):
	player.current_city = to_city
	current_game_time += 10.0 # Reise dauert 10 Sekunden
	# Beim Stadtwechsel: Sofort Preise aktualisieren
	for good_id in cities[to_city].market:
		update_cached_stock(cities[to_city], good_id)
	# simulate production/consumption
	update_market("A")
	update_market("B")




func advance_time(delta: float):
	# Rufe diese Funktion jedes Frame auf
	current_game_time += delta
