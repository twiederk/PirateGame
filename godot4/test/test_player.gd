extends GutTest

const BOAT = preload("res://trading_system/ship_boat.tres")
const TRADER_RANK_01 = preload("res://promotion_system/trader_rank_01.tres")
const SAILER_RANK_01 = preload("res://promotion_system/sailer_rank_01.tres")
const GOOD_FISH = preload("res://trading_system/good_fish.tres")
const GOOD_GRAIN = preload("res://trading_system/good_grain.tres")


var player: Player = null


func before_each():
	player = Player.new()


func after_each():
	player.free()


func test_init():
	# assert
	assert_eq(player.trader_rank.title, TRADER_RANK_01.title, "New player should start with title Krämer")
	assert_eq(player.sailer_rank.title, SAILER_RANK_01.title, "New player should start with title Landratte")


func test_get_used_capacity():
	# act
	var capacity = player.get_used_capacity()
	
	# arrange
	assert_eq(capacity, 0, "No goods have 0 capacity")


func test_has_space_left():
	# act
	var result = player.has_space(10)
	
	# assert
	assert_true(result, "Capacity is larger then addition capacity of goods")


func test_has_space_filled():
	# act
	var result = player.has_space(100)
	
	# assert
	assert_false(result, "Capacity is lower then addition capacity of goods")


func test_get_trading_item():
	# act
	var trading_item = player.get_trading_item(1)
	
	# assert
	assert_not_null(trading_item)
	assert_eq(trading_item.good_id, 1, "Should return trading item for fish")


func test_player_owns_ship_returns_false_when_no_ship():
	# act
	var result = player.owns_ship()

	# assert
	assert_false(result, "Player should report no ship when no ship is equipped")


func test_player_equip_ship_assigns_ship_resource():
	# arrange
	var sprite2D = Sprite2D.new()
	player.ship_sprite = sprite2D

	# act
	player.equip_ship(BOAT)

	# assert
	assert_eq(player._ship_resource, BOAT, "Player should store the provided ShipResource when equipped")
	
	# tear down
	sprite2D.free()


func test_get_trading_items():
	# act
	var trading_items = player.get_trading_items()
	
	# assert
	assert_eq(trading_items.size(), 3, "Player should store a trading item for each good")


func test_on_town_tile_town_entered():
	# act
	player._on_town_tile_town_entered(null)

	# assert
	assert_true(player.in_town(), "Player should be in town after entering a town tile")
	assert_eq(player.get_previous_state(), Player.State.ON_LAND, "Player should store previous state")


func test_on_town_menu_town_left():
	# assert
	player._previous_state = Player.State.ON_SHIP
	
	# act
	player._on_town_menu_town_left()

	# assert
	assert_eq(player.current_state, Player.State.ON_SHIP, "Player should return to previous state")


func test_collect_fish():
	# assert
	player.get_trading_item(GOOD_GRAIN.id).stock = 17
	
	# act
	player.collect(GOOD_FISH, 5)
	
	# assert
	var fish_stock = player.get_trading_item(GOOD_FISH.id).stock
	assert_eq(fish_stock, 3, "Should only collect amount which is free in storeroom")


func test_get_free_capacity():
	# assert
	player.get_trading_item(GOOD_GRAIN.id).stock = 17

	# act
	var result = player.get_free_capacity()
	
	# assert
	assert_eq(result, 3, "Should have free capacity of 3")
