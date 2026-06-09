extends GutTest

const GOOD_FISH = preload("res://trading_system/good_fish.tres")
const GOOD_GRAIN = preload("res://trading_system/good_grain.tres")

var town: Town


func before_each():
	town = Town.new()


func after_each():
	town.free()


func test_town_initialized_with_goods():
	# arrange
	town.add_trading_item(TradingItem.new(GOOD_FISH, 50))
	town.add_trading_item(TradingItem.new(GOOD_GRAIN, 10))
	
	
	# assert
	var town_fish_item = town.get_trading_item(1)
	var town_grain_item = town.get_trading_item(2)
	assert_not_null(town_fish_item, "Town should have fish in inventory")
	assert_not_null(town_grain_item, "Town should have grain in inventory")
	assert_eq(town_fish_item.stock, 50, "Fish item should reference fish good")
	assert_eq(town_grain_item.stock, 10, "Grain item should reference grain good")	


func test_get_trading_item():
	# arrange
	town.add_trading_item(TradingItem.new(GOOD_FISH, 50))
	
	# act
	var trading_item = town.get_trading_item(1)
	
	# assert
	assert_not_null(trading_item)
	assert_eq(trading_item.good_id, 1, "Should return trading item for fish")


func test_add_trading_item():
	# arrange
	var trading_item = TradingItem.new(GOOD_FISH, 50)
	
	# act
	town.add_trading_item(trading_item)
	
	# assert
	assert_eq(town._inventory.size(), 1, "Should contain the added trading item")


func test_get_trading_items():
	# arrange
	town.add_trading_item(TradingItem.new(GOOD_FISH, 50))
	town.add_trading_item(TradingItem.new(GOOD_GRAIN, 10))
	
	# act
	var trading_items = town.get_trading_items()
	
	# assert
	assert_not_null(trading_items)
	assert_eq(trading_items.size(), 2)
