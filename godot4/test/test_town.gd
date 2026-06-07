extends GutTest


var town: Town


func before_each():
	town = Town.new()


func after_each():
	town.free()


func test_town_initalized_with_goods():
	# arrange
	var fish_item = TradingItem.new()
	fish_item.good = load("res://trading_system/good_fish.tres")
	town.inventory[1] = fish_item
	
	var grain_item = TradingItem.new()
	grain_item.good = load("res://trading_system/good_grain.tres")
	town.inventory[2] = grain_item
	
	# act - verify inventory was set correctly
	var retrieved_fish = town.inventory[1]
	var retrieved_grain = town.inventory[2]
	
	# assert
	assert_not_null(retrieved_fish, "Town should have fish in inventory")
	assert_not_null(retrieved_grain, "Town should have grain in inventory")
	assert_eq(retrieved_fish.good.id, 1, "Fish item should reference fish good")
	assert_eq(retrieved_grain.good.id, 2, "Grain item should reference grain good")
