extends GutTest

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

	# act
	var save_data = player.get_save_data()

	# assert
	assert_eq(save_data["player"]["gold"], 321, "Collected data should include player gold")
	assert_eq(save_data["player"]["position"]["x"], 17.0, "Collected data should include player position")
	assert_eq(save_data["player"]["position"]["y"], 29.0, "Collected data should include player position")


func test_player_ship_resource_initialized_as_null():
	# assert
	assert_null(player._ship_resource, "Player should start without a ship_resource")


func test_player_owns_ship_returns_false_when_no_ship():
	# act
	var result = player.owns_ship()

	# assert
	assert_false(result, "Player should report no ship when no ship is equipped")


func test_player_equip_ship_assigns_ship_resource():
	# arrange
	var ship: ShipResource = load("res://trading_system/ship_boat.tres")
	player.ship_sprite = Sprite2D.new()

	# act
	player.equip_ship(ship)

	# assert
	assert_eq(player._ship_resource, ship, "Player should store the provided ShipResource when equipped")
