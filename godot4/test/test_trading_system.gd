extends GutTest

var trading_system: TradingSystem = null


func before_each():
	trading_system = TradingSystem.new()


func test_price_in_habor_for_fish():
	# arrange
	var city = trading_system.cities.A
	
	# act
	var price = trading_system.get_price(city, "fish")
	
	# assert
	assert_eq(price, 5, "Price should not fall below min price")
	

func test_get_used_capacity():
	# act
	var capacity = trading_system.get_used_capacity()
	
	# arrange
	assert_eq(capacity, 0, "No goods have 0 capacity")
	

func test_has_space_left():
	# act
	var result = trading_system.has_space(10)
	
	# assert
	assert_true(result, "Capacity is larger then addition capacity of goods")
	
	
func test_has_space_filled():
	# act
	var result = trading_system.has_space(100)
	
	# assert
	assert_false(result, "Capacity is lower then addition capacity of goods")


func test_player_buys_fish_in_habor():
	# act
	trading_system.buy("fish", 5)
	
	# assert
	assert_eq(trading_system.cities.A.market.fish.stock, 45, "Fish is removed from stock of habor")
	assert_eq(trading_system.player.gold, 75, "Gold is reduced from player")
	assert_eq(trading_system.player.inventory.fish, 5, "Fish is put in inventory of player")


func test_player_sells_fish_in_habor():
	# arrange
	trading_system.player.inventory.fish = 5
	
	# act
	trading_system.sell("fish", 5)
	
	# assert
	assert_eq(trading_system.cities.A.market.fish.stock, 55, "Fish is added to stock of habor")
	assert_eq(trading_system.player.gold, 125, "Gold is added to player")
	assert_eq(trading_system.player.inventory.fish, 0, "Fish is removed from inventory of player")


func test_update_market_of_habor():
	# act
	trading_system.update_market("A")
	
	# assert
	assert_eq(trading_system.cities.A.market.fish.stock, 55, "Fish is produced in habor")
	assert_eq(trading_system.cities.A.market.grain.stock, 7, "Grain is consumed in habor")
	

func test_travel():
	# act
	trading_system.travel("B")
	
	# assert
	assert_eq("B", trading_system.player.current_city, "Player travelled to farm")
	assert_eq(trading_system.cities.A.market.fish.stock, 55, "Fish is produced in habor")
	assert_eq(trading_system.cities.A.market.grain.stock, 7, "Grain is consumed in habor")
	assert_eq(trading_system.cities.B.market.fish.stock, 7, "Fish is consumed in farm")
	assert_eq(trading_system.cities.B.market.grain.stock, 55, "Grain is produced in farm")
	
