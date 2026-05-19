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
