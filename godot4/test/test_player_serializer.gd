extends GutTest


const TRADER_RANK_01 = preload("res://promotion_system/trader_rank_01.tres")
const TRADER_RANK_06 = preload("res://promotion_system/trader_rank_06.tres")
const SAILER_RANK_01 = preload("res://promotion_system/sailer_rank_01.tres")
const SAILER_RANK_02 = preload("res://promotion_system/sailer_rank_02.tres")
const BOAT = preload("res://trading_system/ship_boat.tres")
const SAILING = preload("res://trading_system/ship_sailing.tres")

var player: Player = null
var player_serializer = null


func before_each():
	player = Player.new()
	player_serializer = PlayerSerializer.new()


func after_each():
	player.free()


func test_get_save_data():
	# arrange
	player.gold = 321
	player.position = Vector2(17, 29)
	player.current_state = Player.State.IN_TOWN
	player.add_ship(BOAT)
	player.add_ship(SAILING)
	player.get_trading_item(1).stock = 5
	player.get_trading_item(2).stock = 7

	# act
	var save_data = player_serializer.get_save_data(player)

	# assert
	assert_eq(save_data.player.gold, 321, "Collected data should include player gold")
	assert_eq(save_data.player.position.x, 17.0, "Collected data should include player position")
	assert_eq(save_data.player.position.y, 29.0, "Collected data should include player position")
	assert_eq(save_data.player.current_state, Player.State.IN_TOWN, "Collected data should include player current_state")
	assert_eq(save_data.player.inventory[1].stock, 5, "Collected data should include serialized player inventory stock")
	assert_eq(save_data.player.inventory[2].stock, 7, "Collected data should include serialized player inventory stock")
	assert_eq(save_data.player.trader_rank, "res://promotion_system/trader_rank_01.tres", "Collected data should include player trader rank resource")
	assert_eq(save_data.player.sailer_rank, "res://promotion_system/sailer_rank_01.tres", "Collected data should include player sailer rank resource")
	assert_eq(save_data.player.ships.size(), 2, "Collected data should include serialized owned ships")
	assert_eq(save_data.player.current_ship_index, 1, "Collected data should include active ship index")


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
			"ships": [
				{"resource_path": "res://trading_system/ship_boat.tres"},
				{"resource_path": "res://trading_system/ship_sailing.tres"},
			],
			"current_ship_index": 1,
			"inventory": {
				1: {"stock": 5},
				2: {"stock": 7},
				3: {"stock": 0},
			}
		}
	}

	# act
	player_serializer.set_save_data(player, save_data)

	# assert
	assert_eq(player.current_state, Player.State.IN_TOWN, "set_save_data should restore player current_state")
	assert_eq(player.gold, 123, "set_save_data should restore player gold")
	assert_eq(player.position.x, 11.0, "set_save_data should restore player position x")
	assert_eq(player.position.y, 13.0, "set_save_data should restore player position y")
	assert_eq(player.get_trading_item(1).stock, 5, "set_save_data should restore inventory stock for key 1")
	assert_eq(player.get_trading_item(2).stock, 7, "set_save_data should restore inventory stock for key 2")
	assert_eq(player.trader_rank.title, "Zunftmeister", "set_save_data should restore player trader rank")
	assert_eq(player.sailer_rank.title, "Kapitän", "set_save_data should restore player sailer rank")
	assert_eq(player.get_ships().size(), 2, "set_save_data should restore all owned ships")
	assert_eq(player.get_ship().resource_path, "res://trading_system/ship_sailing.tres", "set_save_data should restore active ship by index")


func test_set_save_data_missing_data_use_defaults():
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
	player_serializer.set_save_data(player, save_data)

	# assert
	assert_eq(player.trader_rank.title, TRADER_RANK_01.title, "Missing trader_rank in save should default to trader rank 1")
	assert_eq(player.sailer_rank.title, SAILER_RANK_01.title, "Missing sailer_rank in save should default to sailer rank 1")


func test_set_save_data_legacy_ship_field_migrates_to_ships_array():
	# arrange
	var save_data = {
		"player": {
			"gold": 123,
			"position": {"x": 0, "y": 0},
			"current_state": Player.State.ON_LAND,
			"ship": {"resource_path": "res://trading_system/ship_boat.tres"},
			"inventory": {
				1: {"stock": 0},
				2: {"stock": 0},
				3: {"stock": 0},
			}
		}
	}

	# act
	player_serializer.set_save_data(player, save_data)

	# assert
	assert_eq(player.get_ships().size(), 1, "Legacy ship save should restore one owned ship")
	assert_eq(player._current_ship_index, 0, "Legacy ship save should set active ship index to 0")
	assert_eq(player.get_ship().resource_path, "res://trading_system/ship_boat.tres", "Legacy ship save should set active ship")
