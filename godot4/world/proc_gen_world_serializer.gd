class_name ProcGenWorldSerializer

func get_save_data(proc_gen_world: ProcGenWorld) -> Dictionary:
	var world_data = {
		"seed_value": proc_gen_world.seed_value,
		"spawn_accumulator": proc_gen_world.spawn_accumulator,
	}
	world_data.towns = []
	for town in proc_gen_world.get_towns():
		world_data.towns.append(_serialize_town_save_data(town))
	world_data.goods = []
	for good in proc_gen_world.get_goods():
		world_data.goods.append(_serialize_good_save_data(good))
	return {"world": world_data}


func _serialize_town_save_data(town: Town) -> Dictionary:
	return {
		"visited": town.get_visited(),
		"inventory": _serialize_town_inventory(town)
	}


func _serialize_town_inventory(town: Town) -> Dictionary:
	var inventory_data: Dictionary = {}
	for item in town.get_trading_items():
		inventory_data[item.good_id] = {
			"stock": item.stock,
			"cached_stock": item.cached_stock,
			"last_updated": item.last_updated,
		}
	return inventory_data


func _serialize_good_save_data(good: Good) -> Dictionary:
	return {
		"resource_path": good.good_resource.resource_path,
		"position": {
			"x": good.position.x,
			"y": good.position.y,
		}
	}
