class_name PlayerSerializer


func get_save_data(player: Player) -> Dictionary:
	var player_data = {
		"gold": player.gold,
		"position": {
			"x": player.position.x,
			"y": player.position.y,
		},
		"trader_rank": player.trader_rank.resource_path,
		"sailer_rank": player.sailer_rank.resource_path,
		"current_state": player.current_state,
		"inventory": _serialize_inventory_stock(player),
		"ships": _serialize_ships(player),
		"current_ship_index": player._current_ship_index,
		"treasure": player.treasure != null
	}

	return {"player": player_data}


func _serialize_inventory_stock(player: Player) -> Dictionary:
	var inventory_data = {}
	for good_id in player._inventory:
		inventory_data[good_id] = {"stock": player._inventory[good_id].stock}
	return inventory_data


func _serialize_ships(player: Player) -> Array:
	var ships: Array = []
	for ship_resource in player.get_ships():
		ships.append({"resource_path": ship_resource.resource_path})
	return ships


func set_save_data(player: Player, save_data: Dictionary, treasures: Array[Treasure] = []) -> void:
	var player_data = save_data.player
	var pos_data = player_data.position
	player.position = Vector2i(int(pos_data.x), int(pos_data.y))
	player.gold = int(player_data.gold)
	player.current_state = int(player_data.current_state) as Player.State
	if player_data.has("trader_rank"):
		player.trader_rank = load(player_data.trader_rank)
	if player_data.has("sailer_rank"):
		player.sailer_rank = load(player_data.sailer_rank)
	if player_data.has("inventory"):
		_restore_inventory_stock(player, player_data.inventory)
	player._ship_resources.clear()
	player._current_ship_index = Player.NO_SHIP
	if player_data.has("ships"):
		_restore_ships(player, player_data)
	elif player_data.has("ship"):
		var resource_path = player_data.ship.resource_path
		player._ship_resources.append(load(resource_path))
		player._current_ship_index = 0
	if player.current_state == Player.State.ON_SHIP:
		if player.get_ship() == null:
			player.current_state = Player.State.ON_LAND
		else:
			player.current_state = Player.State.ON_LAND
			player.board_ship()
	if player_data.has("treasure"):
		player.treasure = _restore_treasure(player, treasures)

func _restore_ships(player: Player, player_data: Dictionary) -> void:
	for ship_data in player_data.ships:
		if ship_data.has("resource_path"):
			player._ship_resources.append(load(ship_data.resource_path))
	if player_data.has("current_ship_index"):
		player._current_ship_index = int(player_data.current_ship_index)


func _restore_inventory_stock(player: Player, inventory_data: Dictionary) -> void:
	for good_id in inventory_data:
		var item_data = inventory_data[good_id]
		player.get_trading_item(int(good_id)).stock = int(item_data.stock)


func _restore_treasure(player: Player, treasures: Array[Treasure]) -> Treasure:
	for treasure in treasures:
		if treasure.active:
			return treasure
	return null
