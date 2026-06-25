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
