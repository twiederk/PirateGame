extends GutTest

const GOOD_FISH = preload("res://trading_system/good_fish.tres")
const GOOD_GRAIN = preload("res://trading_system/good_grain.tres")
const TOWN_HABOR = preload("res://world/town_habor.tres")
const TOWN_FARM = preload("res://world/town_farm.tres")

var trading_system: TradingSystem = null


func before_each():
	trading_system = TradingSystem.new()


func after_each():
	trading_system.free()


func test_goods_dictionary_populated():
	
	# act
	var goods_dict = trading_system.goods
	
	# assert
	assert_not_null(goods_dict, "TradingSystem should have a goods dictionary")
	assert_true(goods_dict.has(1), "Goods dictionary should contain fish (id: 1)")
	assert_true(goods_dict.has(2), "Goods dictionary should contain grain (id: 2)")
	
	var fish_resource = goods_dict[1]
	assert_is(fish_resource, GoodResource, "Fish entry should be a GoodResource")
	assert_eq(fish_resource.base_price, 10, "Fish should have base_price of 10")
	
	var grain_resource = goods_dict[2]
	assert_is(grain_resource, GoodResource, "Grain entry should be a GoodResource")
	assert_eq(grain_resource.base_price, 15, "Grain should have base_price of 15")


func test_price_in_habor_for_fish():
	# arrange
	var fish_item = TradingItem.new(GOOD_FISH, 50)
	
	# act
	var price = trading_system.get_price(fish_item)
	
	# assert
	assert_eq(price, 5, "Price should not fall below min price")



func test_player_buys_fish_in_habor():
	# arrange
	var town_item = TradingItem.new(GOOD_FISH, 50)
	var player_item = TradingItem.new(GOOD_FISH)
	
	var player = Player.new()
	player.gold = 100
	
	# act
	trading_system.buy(player, player_item, town_item, 5)
	
	# assert
	assert_eq(town_item.stock, 45, "Fish is removed from stock of habor")
	assert_eq(player.gold, 75, "Gold is reduced from player")
	assert_eq(player_item.stock, 5, "Fish is put in inventory of player")

	# tear down
	player.free()


func test_player_sells_fish_in_habor():
	# arrange
	var town_trading_item = TradingItem.new(GOOD_FISH, 50)
	town_trading_item.cached_stock = 50
	
	var player = Player.new()
	player.gold = 100
	var player_trading_item: TradingItem = player.get_trading_item(town_trading_item.good_id)
	player_trading_item.stock = 5
	
	# act
	trading_system.sell(player, player_trading_item, town_trading_item, 5)
	
	# assert
	assert_eq(town_trading_item.stock, 55, "Fish is added to stock of habor")
	assert_eq(player.gold, 125, "Gold is added to player")
	assert_eq(player_trading_item.stock, 0, "Fish is removed from inventory of player")
	
	# tear down
	player.free()


func test_update_town_habor():
	# arrange
	var town = Town.new()
	town.town_resource = TOWN_HABOR
	town.add_trading_item(TradingItem.new(GOOD_FISH, 50))
	town.add_trading_item(TradingItem.new(GOOD_GRAIN, 10))
	
	# act
	trading_system.update_town(town)
	
	# assert
	assert_eq(town.get_trading_item(1).stock, 55, "Fish is produced in habor")
	assert_eq(town.get_trading_item(2).stock, 7, "Grain is consumed in habor")
	
	# tear down
	town.free()


func test_simulation():
	# arrange
	var habor = Town.new()
	habor.town_resource = TOWN_HABOR
	habor.add_trading_item(TradingItem.new(GOOD_FISH, 50))
	habor.add_trading_item(TradingItem.new(GOOD_GRAIN, 10))
	
	var farm = Town.new()
	farm.town_resource = TOWN_FARM
	farm.add_trading_item(TradingItem.new(GOOD_FISH, 10))
	farm.add_trading_item(TradingItem.new(GOOD_GRAIN, 50))
	
	# act
	trading_system.simulation(trading_system.SIMULATION_STEP, [habor, farm])
	
	# assert
	assert_eq(habor.get_trading_item(1).stock, 55, "Fish is produced in habor")
	assert_eq(habor.get_trading_item(2).stock, 7, "Grain is consumed in habor")
	assert_eq(farm.get_trading_item(1).stock, 7, "Fish is consumed in farm")
	assert_eq(farm.get_trading_item(2).stock, 55, "Grain is produced in farm")
	
	# tear down
	habor.free()
	farm.free()
