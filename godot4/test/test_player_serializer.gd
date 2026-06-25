extends GutTest

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
