extends GutTest

const GOOD_FISH = preload("res://trading_system/good_fish.tres")

var proc_gen_world: ProcGenWorld = null


func before_each():
	proc_gen_world = ProcGenWorld.new()


func after_each():
	proc_gen_world.free()


func test_get_save_data():
	# arrange
	proc_gen_world.seed_value = 12345
	var towns_root = Node2D.new()
	var town = Town.new()
	var town_item = TradingItem.new(GOOD_FISH, 50)
	town_item.cached_stock = 45
	town_item.last_updated = 1234.5
	town.add_trading_item(town_item)
	towns_root.add_child(town)
	proc_gen_world.towns = towns_root

	# act
	var save_data = proc_gen_world.get_save_data()

	# assert
	assert_eq(save_data.world.seed_value, 12345, "Save data should include the world seed")
	assert_eq(save_data.world.towns.size(), 1, "Save data should include one serialized town")
	assert_eq(save_data.world.towns[0].inventory[1].stock, 50, "Town inventory stock should be serialized")
	assert_eq(save_data.world.towns[0].inventory[1].cached_stock, 45, "Town inventory cached_stock should be serialized")
	assert_eq(save_data.world.towns[0].inventory[1].last_updated, 1234.5, "Town inventory last_updated should be serialized")
