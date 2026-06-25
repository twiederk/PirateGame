extends GutTest


const GOOD_FISH = preload("res://trading_system/good_fish.tres")

var proc_gen_world: ProcGenWorld = null
var proc_gen_world_serializer: ProcGenWorldSerializer = null


func before_each():
	proc_gen_world = ProcGenWorld.new()
	proc_gen_world_serializer = ProcGenWorldSerializer.new()

func after_each():
	proc_gen_world.free()


func test_get_save_data():
	# arrange
	proc_gen_world.spawn_accumulator = 0.5
	proc_gen_world.seed_value = 12345
	var towns_root = Node2D.new()
	var town = Town.new()
	town.set_visited(true)
	var town_item = TradingItem.new(GOOD_FISH, 50)
	town_item.cached_stock = 45
	town_item.last_updated = 1234.5
	town.add_trading_item(town_item)
	towns_root.add_child(town)
	proc_gen_world.towns = towns_root
	
	var goods_root = Node2D.new()
	var good = Good.new()
	good.good_resource = GOOD_FISH
	good.global_position = Vector2i(10, 20)
	goods_root.add_child(good)
	proc_gen_world.goods = goods_root

	# act
	var save_data = proc_gen_world_serializer.get_save_data(proc_gen_world)

	# assert
	assert_eq(save_data.world.seed_value, 12345, "Save data should include the world seed")
	assert_eq(save_data.world.spawn_accumulator, 0.5, "Save data should include the spawn accumulator")
	assert_eq(save_data.world.towns.size(), 1, "Save data should include one serialized town")
	var loaded_town = save_data.world.towns[0]
	assert_eq(loaded_town.size(), 2, "Save data should include one serialized town")
	assert_true(loaded_town.visited, "Town visited should be serialized")
	assert_eq(loaded_town.inventory[1].stock, 50, "Town inventory stock should be serialized")
	assert_eq(loaded_town.inventory[1].cached_stock, 45, "Town inventory cached_stock should be serialized")
	assert_eq(loaded_town.inventory[1].last_updated, 1234.5, "Town inventory last_updated should be serialized")
	var loaded_fish = save_data.world.goods[0]
	assert_not_null(loaded_fish)
	assert_eq(loaded_fish.resource_path, GOOD_FISH.resource_path, "Should store good resouce path")
	assert_eq(loaded_fish.position.x, 10.0, "Should store x position")
	assert_eq(loaded_fish.position.y, 20.0, "Should store y position")

	# tear down
	towns_root.free()
	goods_root.free()


func test_set_save_data():
	# arrange
	var towns_root = Node2D.new()
	var town = Town.new()
	var town_item = TradingItem.new(GOOD_FISH, 1)
	town_item.cached_stock = 2
	town_item.last_updated = 3.0
	town.add_trading_item(town_item)
	towns_root.add_child(town)
	proc_gen_world.towns = towns_root
	
	var goods_root = Node2D.new()
	proc_gen_world.goods = goods_root

	var save_data = {
		"world": {
			"spawn_accumulator": 0.5,
			"towns": [
				{
					"visited": true,
					"inventory": {
						"1": {
							"stock": 50,
							"cached_stock": 45,
							"last_updated": 1234.5,
						}
					}
				}
			],
			"goods": [
				{
					"resource_path": GOOD_FISH.resource_path,
					"position": {"x": 10, "y": 20},
				}
			]
		}
	}

	# act
	proc_gen_world_serializer.set_save_data(proc_gen_world, save_data)

	# assert
	assert_eq(proc_gen_world.spawn_accumulator, 0.5, "should restore spawn accumulator")
	assert_true(town.get_visited(), "should restore visited")
	assert_eq(town_item.stock, 50, "should restore town item stock")
	assert_eq(town_item.cached_stock, 45, "should restore town item cached_stock")
	assert_eq(town_item.last_updated, 1234.5, "should restore town item last_updated")
	var goods = proc_gen_world.get_goods()
	assert_eq(goods.size(), 1, "Should restore goods")
	var good = goods[0]
	assert_eq(good.good_resource.resource_path, GOOD_FISH.resource_path, "Should restore good resource of good")
	assert_eq(good.global_position, Vector2(10, 20), "Should restore position of good")
	
	# tear down
	towns_root.free()
	goods_root.free()
