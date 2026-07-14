class_name RaidersGenerator
extends Generator


@export var raider_percentage: float = 0.02

const RAIDER_DISTANCE: float = 350.0

const RaiderScene = preload("res://world/raider.tscn")


func generate_raiders(proc_gen_world: ProcGenWorld, player_position: Vector2) -> void:
	var width = proc_gen_world.width
	var viewport = proc_gen_world.get_viewport()
	var raiders_root = proc_gen_world.raiders
	
	var max_raiders = int(width * raider_percentage)
	var raiders_to_generate = max_raiders - proc_gen_world.get_raiders().size()
	var raiders_positions = _create_raiders_positions(proc_gen_world)
	for i in range(raiders_to_generate):
		var spawn_position = _pick_hidden_tile_position(viewport, raiders_positions)
		if spawn_position == INVALID_TILE_POSITION:
			continue
		if _in_raider_distance(player_position, spawn_position):
			continue
		var raider: Raider = RaiderScene.instantiate() 
		raider.global_position = spawn_position * ProcGenWorld.TILE_SIZE
		raiders_root.add_child(raider)


func _create_raiders_positions(proc_gen_world: ProcGenWorld) -> Array[Vector2i]:
	return proc_gen_world.grass_arr.filter(func(pos): return not pos in proc_gen_world.cliff_arr)


func _in_raider_distance(player_position, spawn_position) -> bool:
	return player_position.distance_to(Vector2(spawn_position * ProcGenWorld.TILE_SIZE)) <= RAIDER_DISTANCE
