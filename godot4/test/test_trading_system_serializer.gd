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


func test_set_save_data():
	# arrange
	var save_data = {
		"trading_system": {
			"current_game_time": 456.75,
			"accumulator": 9.5,
		}
	}

	# act
	trading_system_serializer.set_save_data(trading_system, save_data)

	# assert
	assert_eq(trading_system.current_game_time, 456.75, "Should restore current_game_time from save data")
	assert_eq(trading_system.accumulator, 9.5, "Should restore accumulator from save data")
	
	
func test_set_save_data_missing_data_use_defaults():
	# arrange
	var save_data = {
		"trading_system": { }
	}
	
	# act
	trading_system_serializer.set_save_data(trading_system, save_data)

	# assert
	assert_eq(trading_system.current_game_time, 0.0, "Should use default data for current_game_time")
	assert_eq(trading_system.accumulator, 0.0, "Should use default data for accumulator")
