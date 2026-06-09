extends GutTest


const GOOD_FISH = preload("res://trading_system/good_fish.tres")

func test_trading_item_creation():
	
	# act
	var trading_item = TradingItem.new(GOOD_FISH, 100)
	
	# assert
	assert_eq(trading_item.good_id, 1, "TradingItem should store the good")
	assert_eq(trading_item.stock, 100, "TradingItem should store stock")
	assert_eq(trading_item.cached_stock, 100, "TradingItem should store cached_stock")
	assert_eq(trading_item.last_updated, 0.0, "TradingItem should store last_updated")


# Test List
func test_stock_can_be_set_positive_value():
	# arrange
	var trading_item = TradingItem.new(GOOD_FISH, 50)
	
	# act
	trading_item.stock = 100
	
	# assert
	assert_eq(trading_item.stock, 100, "Stock should be set to positive value 100")


func test_stock_initialized_with_negative_value_should_be_set_to_zero():
	# arrange
	var trading_item = TradingItem.new(GOOD_FISH, 5)
	
	# act
	trading_item.stock -= 10
	
	# assert
	assert_eq(trading_item.stock, 0, "Stock should be set to zero")


func test_get_good_id():
	# act
	var good_id = TradingItem.new(GOOD_FISH, 5).good_id
	
	# assert
	assert_eq(good_id, GOOD_FISH.id, "Should return id of good")
