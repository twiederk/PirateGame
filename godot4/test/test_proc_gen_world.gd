extends GutTest

const GOOD_FISH = preload("res://trading_system/good_fish.tres")

var proc_gen_world: ProcGenWorld = null


func before_each():
	proc_gen_world = ProcGenWorld.new()


func after_each():
	proc_gen_world.free()




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
	proc_gen_world.set_save_data(save_data)

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
