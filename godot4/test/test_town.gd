extends GutTest


var town: Town


func before_each():
	town = Town.new()


func after_each():
	town.free()


func test_town_initialized_with_goods():
	# arrange
	var fish_item = TradingItem.new()
	fish_item.good = load("res://trading_system/good_fish.tres")
	town.inventory[1] = fish_item
	
	var grain_item = TradingItem.new()
	grain_item.good = load("res://trading_system/good_grain.tres")
	town.inventory[2] = grain_item
	
	# assert
	assert_not_null(town.inventory[1], "Town should have fish in inventory")
	assert_not_null(town.inventory[2], "Town should have grain in inventory")
	assert_eq(town.inventory[1].good.id, 1, "Fish item should reference fish good")
	assert_eq(town.inventory[2].good.id, 2, "Grain item should reference grain good")
