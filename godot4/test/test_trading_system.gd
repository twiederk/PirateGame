extends GutTest

var trading_system: TradingSystem = null


func before_each():
	trading_system = TradingSystem.new()


func test_execute():
	
	# act
	var price = trading_system.get_price()
	
	# assert
	assert_eq(price, 1, "Price should always be 1")
