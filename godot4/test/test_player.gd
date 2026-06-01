extends GutTest

var player: Player = null


func before_each():
	player = Player.new()


func after_each():
	player.free()


func test_get_used_capacity():
	# act
	var capacity = player.get_used_capacity()
	
	# arrange
	assert_eq(capacity, 0, "No goods have 0 capacity")


#func test_has_space_left():
	## act
	#var result = trading_system.has_space(10)
	#
	## assert
	#assert_true(result, "Capacity is larger then addition capacity of goods")
	
	
#func test_has_space_filled():
	## act
	#var result = trading_system.has_space(100)
	#
	## assert
	#assert_false(result, "Capacity is lower then addition capacity of goods")
