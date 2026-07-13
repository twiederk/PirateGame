extends GutTest


var treasures_generator: TreasuresGenerator = null


func before_each():
	treasures_generator = TreasuresGenerator.new()


func test_get_town_without_treasure_returns_town_without_treasure():
	# arrange
	var town_with_treasure = Town.new()
	var town_without_treasure = Town.new()
	var treasure = Treasure.new()
	town_with_treasure.treasure = treasure

	var all_towns: Array[Town] = []
	all_towns.append(town_with_treasure)
	all_towns.append(town_without_treasure)

	# act
	var result = treasures_generator._get_town_without_treasure(all_towns)

	# assert
	assert_eq(result, town_without_treasure, "Should return the town without treasure")

	# tear down
	treasure.free()
	town_with_treasure.free()
	town_without_treasure.free()
