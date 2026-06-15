extends GutTest

const BOAT:= preload("res://trading_system/ship_boat.tres")

var player: Player = null


func before_each():
	player = Player.new()


func after_each():
	player.free()


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
	player.current_state = Player.STATE.IN_TOWN
	player.get_trading_item(1).stock = 5
	player.get_trading_item(2).stock = 7

	# act
	var save_data = player.get_save_data()

	# assert
	assert_eq(save_data.player.gold, 321, "Collected data should include player gold")
	assert_eq(save_data.player.position.x, 17.0, "Collected data should include player position")
	assert_eq(save_data.player.position.y, 29.0, "Collected data should include player position")
	assert_eq(save_data.player.current_state, Player.STATE.IN_TOWN, "Collected data should include player current_state")
	assert_eq(save_data.player.inventory[1].stock, 5, "Collected data should include serialized player inventory stock")
	assert_eq(save_data.player.inventory[2].stock, 7, "Collected data should include serialized player inventory stock")


func test_set_save_data_restores_current_state():
	# arrange
	player.current_state = Player.STATE.ON_SHIP
	var save_data = {
		"player": {
			"gold": 123,
			"position": {"x": 11, "y": 13},
			"current_state": Player.STATE.IN_TOWN
		}
	}

	# act
	player.set_save_data(save_data)

	# assert
	assert_eq(player.current_state, Player.STATE.IN_TOWN, "set_save_data should restore player current_state")
	assert_eq(player.gold, 123, "set_save_data should restore player gold")
	assert_eq(player.position.x, 11.0, "set_save_data should restore player position x")
	assert_eq(player.position.y, 13.0, "set_save_data should restore player position y")


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
	assert_eq(trading_items.size(), 2, "Player should store a trading item for each good")
