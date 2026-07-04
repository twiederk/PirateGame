extends Node

var _simulation_running = true


func simulation_stop() -> void:
	_simulation_running = false


func simulation_start() -> void:
	_simulation_running = true


func clear_all() -> void:
	_simulation_running = true


func is_simulation_paused() -> bool:
	return not _simulation_running
