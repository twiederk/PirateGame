extends GutTest

const BOAT = preload("res://trading_system/ship_boat.tres")
const TRADER_RANK_01 = preload("res://promotion_system/trader_rank_01.tres")
const TRADER_RANK_06 = preload("res://promotion_system/trader_rank_06.tres")
const SAILER_RANK_01 = preload("res://promotion_system/sailer_rank_01.tres")
const SAILER_RANK_02 = preload("res://promotion_system/sailer_rank_02.tres")

var player: Player = null


func before_each():
	player = Player.new()


func after_each():
	player.free()


func test_player_starts_with_kraemer_rank():
	# assert
	assert_eq(player.trader_rank.title, TRADER_RANK_01.title, "New player should start with title Krämer")


func test_player_starts_with_landratte_rank():
	# assert
	assert_eq(player.sailer_rank.title, SAILER_RANK_01.title, "New player should start with title Landratte")

	

func test_trader_rank_serialized_in_save_data():
	# arrange
	player.trader_rank = TRADER_RANK_01

	# act
	var save_data = player.get_save_data()

	# assert
	assert_eq(save_data.player.trader_rank, "res://promotion_system/trader_rank_01.tres", "Collected data should include player trader rank resource")


func test_sailer_rank_serialized_in_save_data():
	# arrange
	player.sailer_rank = SAILER_RANK_01

	# act
	var save_data = player.get_save_data()

	# assert
	assert_eq(save_data.player.sailer_rank, "res://promotion_system/sailer_rank_01.tres", "Collected data should include player sailer rank resource")


func test_set_save_data():
	# arrange
	player.current_state = Player.State.ON_SHIP
	player.get_trading_item(1).stock = 100
	player.get_trading_item(2).stock = 200
	player.trader_rank = TRADER_RANK_01
	player.sailer_rank = SAILER_RANK_01
	var save_data = {
		"player": {
			"gold": 123,
			"position": {"x": 11, "y": 13},
			"trader_rank": "res://promotion_system/trader_rank_06.tres",
			"sailer_rank": "res://promotion_system/sailer_rank_02.tres",
			"current_state": Player.State.IN_TOWN,
			"inventory": {
				1: {"stock": 5},
				2: {"stock": 7},
				3: {"stock": 0},
			}
		}
	}

	# act
	player.set_save_data(save_data)

	# assert
	assert_eq(player.current_state, Player.State.IN_TOWN, "set_save_data should restore player current_state")
	assert_eq(player.gold, 123, "set_save_data should restore player gold")
	assert_eq(player.position.x, 11.0, "set_save_data should restore player position x")
	assert_eq(player.position.y, 13.0, "set_save_data should restore player position y")
	assert_eq(player.get_trading_item(1).stock, 5, "set_save_data should restore inventory stock for key 1")
	assert_eq(player.get_trading_item(2).stock, 7, "set_save_data should restore inventory stock for key 2")
	assert_eq(player.trader_rank.title, "Zunftmeister", "set_save_data should restore player trader rank")
	assert_eq(player.sailer_rank.title, "Kapitän", "set_save_data should restore player sailer rank")


func test_missing_save_data_use_defaults():
	# arrange
	var save_data = {
		"player": {
			"gold": 123,
			"position": {"x": 0, "y": 0},
			"current_state": Player.State.ON_LAND,
			"inventory": {
				1: {"stock": 0},
				2: {"stock": 0},
				3: {"stock": 0},
			}
		}
	}

	# act
	player.set_save_data(save_data)

	# assert
	assert_eq(player.trader_rank.title, TRADER_RANK_01.title, "Missing trader_rank in save should default to trader rank 1")
	assert_eq(player.sailer_rank.title, SAILER_RANK_01.title, "Missing sailer_rank in save should default to sailer rank 1")


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


func test_get_save_data():
	# arrange
	player.gold = 321
	player.position = Vector2(17, 29)
	player.current_state = Player.State.IN_TOWN
	player.get_trading_item(1).stock = 5
	player.get_trading_item(2).stock = 7

	# act
	var save_data = player.get_save_data()

	# assert
	assert_eq(save_data.player.gold, 321, "Collected data should include player gold")
	assert_eq(save_data.player.position.x, 17.0, "Collected data should include player position")
	assert_eq(save_data.player.position.y, 29.0, "Collected data should include player position")
	assert_eq(save_data.player.current_state, Player.State.IN_TOWN, "Collected data should include player current_state")
	assert_eq(save_data.player.inventory[1].stock, 5, "Collected data should include serialized player inventory stock")
	assert_eq(save_data.player.inventory[2].stock, 7, "Collected data should include serialized player inventory stock")


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
