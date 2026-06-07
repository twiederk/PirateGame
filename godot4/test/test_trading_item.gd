extends GutTest


func test_trading_item_creation():
	# arrange
	var good = GoodResource.new()
	good.id = 1
	good.name = "Fish"
	good.base_price = 10
	
	# act
	var item = TradingItem.new(load("res://trading_system/good_fish.tres"), 100)
	
	# assert
	assert_eq(item.good.id, 1, "TradingItem should store the good")
	assert_eq(item.stock, 100, "TradingItem should store stock")
	assert_eq(item.cached_stock, 100, "TradingItem should store cached_stock")
	assert_eq(item.last_updated, 0.0, "TradingItem should store last_updated")
