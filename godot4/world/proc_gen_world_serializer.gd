class_name ProcGenWorldSerializer

const GoodScene = preload("res://world/good.tscn")


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


func set_save_data(proc_gen_world: ProcGenWorld, save_data: Dictionary) -> void:
	if not save_data.has("world"):
		return

	var world_data: Dictionary = save_data.world
	_restore_world(proc_gen_world, world_data)
	_restore_towns(proc_gen_world, world_data)
	_restore_goods(proc_gen_world, world_data)


func _restore_world(proc_gen_world: ProcGenWorld, world_data: Dictionary) -> void:
	if world_data.has("spawn_accumulator"):
		proc_gen_world.spawn_accumulator = world_data.spawn_accumulator


func _restore_towns(proc_gen_world: ProcGenWorld, world_data: Dictionary) -> void:
	if not world_data.has("towns"):
		return
	var towns : Array[Town] = proc_gen_world.get_towns()
	var towns_data = world_data.towns
	for i in range(towns_data.size()):
		_restore_town(towns[i], towns_data[i])


func _restore_town(town: Town, town_data: Dictionary) -> void:
	if town_data.has("visited"):
		town.set_visited(town_data.visited)
	if town_data.has("inventory"):
		_restore_town_inventory_from_save(town, town_data.inventory)


func _restore_town_inventory_from_save(town: Town, inventory_data: Dictionary) -> void:
	for item in town.get_trading_items():
		var item_data = inventory_data[str(item.good_id)]
		if item_data.has("stock"):
			item.stock = item_data.stock
		else:
			item.stock = 0
		if item_data.has("cached_stock"):
			item.cached_stock = item_data.cached_stock
		else:
			item.cached_stock = 0
		if item_data.has("last_updated"):
			item.last_updated = item_data.last_updated
		else:
			item.last_updated = 0


func _restore_goods(proc_gen_world: ProcGenWorld, world_data: Dictionary):
	if world_data.has("goods"):
		for good_data in world_data.goods:
			var good = _restore_good(good_data)
			proc_gen_world.goods.add_child(good)


func _restore_good(good_data: Dictionary) -> Good:
	var good: Good = GoodScene.instantiate()
	var good_resource = load(good_data.resource_path)
	good.good_resource = good_resource
	var pos = Vector2i(int(good_data.position.x), int(good_data.position.y))
	good.global_position = pos
	return good
