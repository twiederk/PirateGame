extends GutTest


const GOOD_FISH = preload("res://trading_system/good_fish.tres")
const TREASURE_COMMON = preload("res://world/treasure_common.tres")

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

	var treasure = Treasure.new()
	treasure.global_position = Vector2(40, 50)
	treasure.gold = 10_000
	treasure.price = 1_000
	treasure.active = true
	treasure.resource = TREASURE_COMMON

	var town = Town.new()
	town.set_visited(true)
	var town_item = TradingItem.new(GOOD_FISH, 50)
	town_item.cached_stock = 45
	town_item.last_updated = 1234.5
	town.add_trading_item(town_item)
	town.treasure = treasure
	var towns_root = Node2D.new()
	towns_root.add_child(town)
	proc_gen_world.towns = towns_root
	
	var goods_root = Node2D.new()
	var good = Good.new()
	good.good_resource = GOOD_FISH
	good.global_position = Vector2i(10, 20)
	goods_root.add_child(good)
	proc_gen_world.goods = goods_root

	var raiders_root = Node2D.new()
	var raider = Raider.new()
	raider.global_position = Vector2(20, 30)
	raiders_root.add_child(raider)
	proc_gen_world.raiders = raiders_root

	var treasures_root = Node2D.new()
	treasures_root.add_child(treasure)
	proc_gen_world.treasures = treasures_root

	# act
	var save_data = proc_gen_world_serializer.get_save_data(proc_gen_world)

	# assert
	assert_eq(save_data.world.seed_value, 12345, "Should include the world seed")
	assert_eq(save_data.world.spawn_accumulator, 0.5, "Should include the spawn accumulator")
	assert_eq(save_data.world.towns.size(), 1, "Should include one serialized town")

	var town_data = save_data.world.towns[0]
	assert_true(town_data.visited, "Town visited should be serialized")
	assert_eq(town_data.inventory[1].stock, 50, "Town inventory stock should be serialized")
	assert_eq(town_data.inventory[1].cached_stock, 45, "Town inventory cached_stock should be serialized")
	assert_eq(town_data.inventory[1].last_updated, 1234.5, "Town inventory last_updated should be serialized")
	assert_true(town_data.has("treasure"))
	assert_eq(town_data.treasure.x, 40)
	assert_eq(town_data.treasure.y, 50)

	var good_data = save_data.world.goods[0]
	assert_not_null(good_data)
	assert_eq(good_data.resource_path, GOOD_FISH.resource_path, "Should store good resouce path")
	assert_eq(good_data.position.x, 10.0, "Should store x position")
	assert_eq(good_data.position.y, 20.0, "Should store y position")

	var raider_data = save_data.world.raiders[0]
	assert_not_null(raider_data)
	assert_eq(raider_data.position.x, 20.0, "Should store raider x position")
	assert_eq(raider_data.position.y, 30.0, "Should store raider y position")

	var treasure_data = save_data.world.treasures[0]
	assert_not_null(treasure_data)
	assert_eq(treasure_data.position.x, 40.0, "Should store treasure x position")
	assert_eq(treasure_data.position.y, 50.0, "Should store treasure y position")
	assert_eq(treasure_data.gold, 10_000, "Should store treasure gold")
	assert_eq(treasure_data.price, 1_000, "Should store treasure price")
	assert_true(treasure_data.active, "Should store treasure active")
	assert_eq(treasure_data.resource_path, "res://world/treasure_common.tres", "should store resource path")

	# tear down
	towns_root.free()
	goods_root.free()
	raiders_root.free()
	treasures_root.free()


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
	
	var raiders_root = Node2D.new()
	proc_gen_world.raiders = raiders_root
	
	var treasures_root = Node2D.new()
	proc_gen_world.treasures = treasures_root

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
					},
					"treasure": {
						"x": 50,
						"y": 60,
					}
				}
			],
			"goods": [
				{
					"resource_path": GOOD_FISH.resource_path,
					"position": {"x": 10, "y": 20},
				}
			],
			"raiders": [
				{
					"position": {"x": 30, "y": 40},
				}
			],
			"treasures": [
				{
					"gold": 10_000,
					"price": 1_000,
					"active": true,
					"position": {"x": 50, "y": 60},
					"resource_path": "res://world/treasure_common.tres",
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
	assert_eq(town.treasure.position, Vector2(50, 60), "Should restore treasure of town")
	
	var goods = proc_gen_world.get_goods()
	assert_eq(goods.size(), 1, "Should restore goods")
	var good = goods[0]
	assert_eq(good.good_resource.resource_path, GOOD_FISH.resource_path, "Should restore good resource of good")
	assert_eq(good.global_position, Vector2(10, 20), "Should restore position of good")

	var raiders = proc_gen_world.get_raiders()
	assert_eq(raiders.size(), 1, "Should restore raiders")
	var raider = raiders[0]
	assert_eq(raider.global_position, Vector2(30, 40), "Should restore position of raider")
	
	var treasurs = proc_gen_world.get_treasures()
	assert_eq(treasurs.size(), 1, "Should restore treasurs")
	var treasure = treasurs[0]
	assert_eq(treasure.global_position, Vector2(50, 60), "Should restore position of treasure")
	assert_eq(treasure.gold, 10_000, "Should restore gold of treasure")
	assert_eq(treasure.price, 1_000, "Should restore price of treasure")
	assert_true(treasure.active, "Should restore active of treasure")
	assert_not_null(treasure.texture, "Should restore texture of treasure")

	# tear down
	towns_root.free()
	goods_root.free()
	raiders_root.free()
	treasures_root.free()


func test_set_save_data_missing_data_use_defaults():
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
	
	var raiders_root = Node2D.new()
	proc_gen_world.raiders = raiders_root
	
	var treasures_root = Node2D.new()
	proc_gen_world.treasures = treasures_root

	var save_data = {
		"world": {
			"towns": [
				{
					"inventory": {
						"1": { }
					}
				}
			]
		}
	}

	# act
	proc_gen_world_serializer.set_save_data(proc_gen_world, save_data)

	# assert
	assert_eq(proc_gen_world.spawn_accumulator, 0.0, "Should use default value for accumulator")
	assert_false(town.get_visited(), "Should use default value for visited")
	assert_eq(town_item.stock, 0, "Should use default value for town item stock")
	assert_eq(town_item.cached_stock, 0, "Should use default value for town item cached_stock")
	assert_eq(town_item.last_updated, 0.0, "Should use default value for town item last_updated")
	assert_eq(proc_gen_world.get_goods().size(), 0, "Should not create goods")
	assert_eq(proc_gen_world.get_raiders().size(), 0, "Should not create raiders")
	assert_eq(proc_gen_world.get_treasures().size(), 0, "Should not create treasure")
	
	# tear down
	towns_root.free()
	goods_root.free()
	raiders_root.free()
	treasures_root.free()
