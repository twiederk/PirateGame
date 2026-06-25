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
	}
	if player._ship_resource != null:
		player_data.ship = {"resource_path": player._ship_resource.resource_path}

	return {"player": player_data}


func _serialize_inventory_stock(player: Player) -> Dictionary:
	var inventory_data = {}
	for good_id in player._inventory:
		inventory_data[good_id] = {"stock": player._inventory[good_id].stock}
	return inventory_data


func set_save_data(player: Player, save_data: Dictionary) -> void:
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
	if player_data.has("ship"):
		var resource_path = player_data.ship.resource_path
		player.equip_ship(load(resource_path))
	if player.current_state == Player.State.ON_SHIP:
		player.current_state = Player.State.ON_LAND
		player.board_ship()


func _restore_inventory_stock(player: Player, inventory_data: Dictionary) -> void:
	for good_id in inventory_data:
		var item_data = inventory_data[good_id]
		player.get_trading_item(int(good_id)).stock = int(item_data.stock)
