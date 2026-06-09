extends GutTest


var town: Town


func before_each():
	town = Town.new()


func after_each():
	town.free()


func test_town_initialized_with_goods():
	# arrange
	var fish_item = TradingItem.new(load("res://trading_system/good_fish.tres"), 50)
	town.inventory[1] = fish_item
	
	var grain_item = TradingItem.new(load("res://trading_system/good_grain.tres"), 10)
	town.inventory[2] = grain_item
	
	# assert
	assert_not_null(town.inventory[1], "Town should have fish in inventory")
	assert_not_null(town.inventory[2], "Town should have grain in inventory")
	assert_eq(town.inventory[1].stock, 50, "Fish item should reference fish good")
	assert_eq(town.inventory[2].stock, 10, "Grain item should reference grain good")	


func test_get_trading_item():
	# arrange
	var fish_item = TradingItem.new(load("res://trading_system/good_fish.tres"), 50)
	town.inventory[1] = fish_item
	
	# act
	var trading_item = town.get_trading_item(1)
	
	# assert
	assert_not_null(trading_item)
	assert_eq(trading_item.good.id, 1, "Should return trading item for fish")
