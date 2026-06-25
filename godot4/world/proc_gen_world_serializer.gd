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
	var world_data: Dictionary = save_data.world
	if world_data.has("spawn_accumulator"):
		proc_gen_world.spawn_accumulator = world_data.spawn_accumulator

	var towns_data: Array = world_data.towns
	var generated_towns : Array[Town] = proc_gen_world.get_towns()
	for i in range(towns_data.size()):
		var town_data: Dictionary = towns_data[i]
		var current_town = generated_towns[i]
		if town_data.has("visited"):
			current_town.set_visited(town_data.visited)
		_restore_town_inventory_from_save(current_town, town_data.inventory)

	if world_data.has("goods"):
		var goods_data: Array = world_data.goods
		for i in range(goods_data.size()):
			var good_data: Dictionary = goods_data[i]
			var good: Good = GoodScene.instantiate()
			var good_resource = load(good_data.resource_path)
			good.good_resource = good_resource
			var pos = Vector2i(int(good_data.position.x), int(good_data.position.y))
			good.global_position = pos
			proc_gen_world.goods.add_child(good)


func _restore_town_inventory_from_save(town: Town, inventory_data: Dictionary) -> void:
	for item in town.get_trading_items():
		var item_save_data = inventory_data[str(item.good_id)]
		item.stock = item_save_data.stock
		item.cached_stock = item_save_data.cached_stock
		item.last_updated = item_save_data.last_updated
