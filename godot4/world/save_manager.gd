extends Node

var load_game_state : Dictionary = {}


func save(player: Player, proc_gen_world: ProcGenWorld, trading_system: TradingSystem, slot_number: int) -> void:
	var game_state: Dictionary = _collect_game_state(player, proc_gen_world, trading_system)
	_save_file(game_state, slot_number)


func _collect_game_state(player: Player, proc_gen_world: ProcGenWorld, trading_system: TradingSystem) -> Dictionary:
	var game_state: Dictionary = {}
	game_state.merge(player.get_save_data(), true)
	game_state.merge(proc_gen_world.get_save_data(), true)
	game_state.merge(trading_system.get_save_data(), true)
	return game_state


func _save_file(game_state: Dictionary, slot_number: int) -> void:
	var make_dir_error := DirAccess.make_dir_recursive_absolute("user://saves")
	if make_dir_error != OK:
		return

	var save_path = _build_save_slot_path(slot_number)
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	if save_file == null:
		return
	save_file.store_string(JSON.stringify(game_state))
	save_file.close()


func load(slot_number: int) -> bool:
	var save_path = _build_save_slot_path(slot_number)
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	if save_file == null:
		load_game_state = {}
		return false

	var saved_text: String = save_file.get_as_text()
	save_file.close()

	var parsed_game_state = JSON.parse_string(saved_text)
	if parsed_game_state is Dictionary:
		load_game_state = parsed_game_state
		return true

	load_game_state = {}
	return false


func _build_save_slot_path(slot_number: int) -> String:
	return "user://saves/save_slot_%d.json" % slot_number


func is_game_loaded() -> bool:
	return not load_game_state.is_empty()
