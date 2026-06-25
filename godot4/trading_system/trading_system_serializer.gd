class_name TradingSystemSerializer


func get_save_data(trading_system: TradingSystem) -> Dictionary:
	var trading_system_data = {
			"current_game_time": trading_system.current_game_time,
			"accumulator": trading_system.accumulator
		}
	return { "trading_system": trading_system_data }


func set_save_data(trading_system: TradingSystem, save_data: Dictionary) -> void:
	var trading_system_data = save_data.trading_system
	trading_system.current_game_time = trading_system_data.current_game_time
	trading_system.accumulator = trading_system_data.accumulator
