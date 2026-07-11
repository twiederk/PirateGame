class_name ProcGenWorldSerializer

const GoodScene = preload("res://world/good.tscn")
const RaiderScene = preload("res://world/raider.tscn")
const TreasureScene = preload("res://world/treasure.tscn")

func get_save_data(proc_gen_world: ProcGenWorld) -> Dictionary:
	var world_data = {
		"seed_value": proc_gen_world.seed_value,
		"spawn_accumulator": proc_gen_world.spawn_accumulator,
	}
	world_data.towns = []
	for town in proc_gen_world.get_towns():
		world_data.towns.append(_serialize_town(town))
	world_data.goods = []
	for good in proc_gen_world.get_goods():
		world_data.goods.append(_serialize_good(good))
	world_data.raiders =[]
	for raider in proc_gen_world.get_raiders():
		world_data.raiders.append(_serialize_raider(raider))
	world_data.treasures = []
	for treasure in proc_gen_world.get_treasures():
		world_data.treasures.append(_serialize_treasure(treasure))
	return {"world": world_data}


func _serialize_town(town: Town) -> Dictionary:
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


func _serialize_good(good: Good) -> Dictionary:
	return {
		"resource_path": good.good_resource.resource_path,
		"position": {
			"x": good.position.x,
			"y": good.position.y,
		}
	}

func _serialize_raider(raider: Raider) -> Dictionary:
	return {
		"position": {
			"x": raider.position.x,
			"y": raider.position.y,
		}
	}


func _serialize_treasure(treasure: Treasure) -> Dictionary:
	return {
		"gold": treasure.gold,
		"price": treasure.price,
		"active": treasure.active,
		"position": {
			"x": treasure.position.x,
			"y": treasure.position.y,
		}
	}


func set_save_data(proc_gen_world: ProcGenWorld, save_data: Dictionary) -> void:
	if not save_data.has("world"):
		return

	var world_data: Dictionary = save_data.world
	_restore_world(proc_gen_world, world_data)
	_restore_towns(proc_gen_world, world_data)
	_restore_goods(proc_gen_world, world_data)
	_restore_raiders(proc_gen_world, world_data)
	_restore_treasures(proc_gen_world, world_data)


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


func _restore_raiders(proc_gen_world: ProcGenWorld, world_data: Dictionary):
	if world_data.has("raiders"):
		for raider_data in world_data.raiders:
			var raider = _restore_raider(raider_data)
			proc_gen_world.raiders.add_child(raider)


func _restore_raider(raider_data: Dictionary) -> Raider:
	var raider: Raider = RaiderScene.instantiate()
	var pos = Vector2i(int(raider_data.position.x), int(raider_data.position.y))
	raider.global_position = pos
	return raider


func _restore_treasures(proc_gen_world: ProcGenWorld, world_data: Dictionary):
	if world_data.has("treasures"):
		for treasure_data in world_data.treasures:
			var treasure = _restore_treasure(proc_gen_world, treasure_data)
			proc_gen_world.treasures.add_child(treasure)


func _restore_treasure(proc_gen_world: ProcGenWorld, treasure_data: Dictionary) -> Treasure:
	var treasure: Treasure = TreasureScene.instantiate()
	var pos = Vector2i(int(treasure_data.position.x), int(treasure_data.position.y))
	treasure.global_position = pos
	treasure.gold = treasure_data.gold
	treasure.price = treasure_data.price
	treasure.active = treasure_data.active
	var treasure_map_image = proc_gen_world.create_treasure_map(treasure.global_position)
	treasure.texture = ImageTexture.create_from_image(treasure_map_image)
	return treasure
