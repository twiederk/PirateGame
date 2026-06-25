class_name TradingSystemSerializer


func get_save_data(trading_system: TradingSystem) -> Dictionary:
	var trading_system_data = {
			"current_game_time": trading_system.current_game_time,
			"accumulator": trading_system.accumulator
		}
	return { "trading_system": trading_system_data }
