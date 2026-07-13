extends GutTest

var raiders_generator: RaidersGenerator = null


func before_each():
	raiders_generator = RaidersGenerator.new()



func test_raider_spawns_in_raider_distance():
	# arrange
	var player_position = Vector2(200.0, 200.0)
	var tile_position = Vector2i(12, 12)
	
	# act
	var result = raiders_generator._in_raider_distance(player_position, tile_position)
	
	# assert
	assert_true(result, "Raider spawned in detection distance to player")


func test_raider_spawns_outside_raider_distance():
	# arrange
	var player_position = Vector2(200.0, 200.0) # global_position
	var tile_position = Vector2i(50, 100) # tile coords
	
	# act
	var result = raiders_generator._in_raider_distance(player_position, tile_position)
	
	# assert
	assert_false(result, "Raider spawned in detection distance to player")
