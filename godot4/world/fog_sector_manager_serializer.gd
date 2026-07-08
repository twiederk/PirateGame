class_name FogSectorManagerSerializer


func get_save_data(fog_sector_manager: FogSectorManager) -> Dictionary:
	var fog_data = {
		"world_width": fog_sector_manager.world_width,
		"world_height": fog_sector_manager.world_height,
		"sector_size": fog_sector_manager.sector_size,
		"visited_sectors": fog_sector_manager.visited_sectors,
	}
	return {"fog": fog_data}


func set_save_data(fog_sector_manager: FogSectorManager, save_data: Dictionary) -> void:
	if not save_data.has("fog"):
		return

	var fog_data = save_data.fog
	
	var world_width = fog_data.get("world_width", 0)
	var world_height = fog_data.get("world_height", 0)
	var sector_size = fog_data.get("sector_size", FogSectorManager.DEFAULT_SECTOR_SIZE)
	
	fog_sector_manager.initialize(world_width, world_height, sector_size)
	
	if fog_data.has("visited_sectors"):
		fog_sector_manager.visited_sectors = fog_data.visited_sectors
	else:
		var total_sectors = fog_sector_manager.sector_width * fog_sector_manager.sector_height
		fog_sector_manager._reset_visited_sectors(total_sectors)
