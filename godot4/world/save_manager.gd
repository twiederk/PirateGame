extends Node


func save(player: Player, proc_gen_world: ProcGenWorld, slot_number: int) -> void:
	var game_state := _collect_game_state(player, proc_gen_world)
	_save_file(game_state, slot_number)


func _collect_game_state(player: Player, proc_gen_world: ProcGenWorld) -> Dictionary:
	var game_state: Dictionary = {}
	game_state.merge(player.get_save_data(), true)
	game_state.merge(proc_gen_world.get_save_data(), true)
	return game_state


func _save_file(game_state: Dictionary, slot_number: int) -> void:
	var make_dir_error := DirAccess.make_dir_recursive_absolute("user://saves")
	if make_dir_error != OK:
		return

	var save_path = "user://saves/save_slot_%d.json" % slot_number
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	if save_file == null:
		return
	save_file.store_string(JSON.stringify(game_state))
	save_file.close()
