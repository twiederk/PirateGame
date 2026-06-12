extends Node


func collect_game_state(player: Player, proc_gen_world: ProcGenWorld) -> Dictionary:
	var game_state: Dictionary = {}
	game_state.merge(player.get_save_data(), true)
	game_state.merge(proc_gen_world.get_save_data(), true)
	return game_state
