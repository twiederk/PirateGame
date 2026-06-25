extends GutTest


var trading_system: TradingSystem = null
var trading_system_serializer: TradingSystemSerializer = null


func before_each():
	trading_system = TradingSystem.new()
	trading_system_serializer = TradingSystemSerializer.new()


func after_each():
	trading_system.free()


func test_get_save_data():
	# arrange
	trading_system.current_game_time = 123.5
	trading_system.accumulator = 17.25

	# act
	var save_data = trading_system_serializer.get_save_data(trading_system)

	# assert
	assert_true(save_data.has("trading_system"), "Save data should contain trading_system section")
	assert_eq(save_data.trading_system.current_game_time, 123.5, "Should persist current_game_time")
	assert_eq(save_data.trading_system.accumulator, 17.25, "Should persist accumulator")
