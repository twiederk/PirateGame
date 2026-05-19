extends GutTest

var trading_system: TradingSystem = null


func before_each():
	trading_system = TradingSystem.new()


func test_price_in_habor_for_fish():
	
	# act
	var price = trading_system.get_price("A", "fish")
	
	# assert
	assert_eq(price, 5, "Price should not fall below min price")
