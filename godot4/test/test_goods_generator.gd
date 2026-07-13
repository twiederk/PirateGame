extends GutTest

const GOOD_FISH = preload("res://trading_system/good_fish.tres")
const GOOD_GRAIN = preload("res://trading_system/good_grain.tres")

var goods_generator: GoodsGenerator = null


func before_each():
	goods_generator = GoodsGenerator.new()


func test_get_good_by_type():
	# arrange
	var fish = Good.new()
	fish.good_resource = GOOD_FISH
	var grain = Good.new()
	grain.good_resource = GOOD_GRAIN
	var all_goods: Array[Good] = [ fish, grain ]
	
	#act
	var result = goods_generator._get_goods_by_type(all_goods, GOOD_FISH)	
	
	# assert
	assert_eq(result.size(), 1, "Should get all fishs in world")
	
	# tear down
	fish.free()
	grain.free()
