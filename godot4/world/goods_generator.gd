class_name GoodsGenerator
extends Generator


@export var fish_percentage: float = 0.125
@export var grain_percentage: float = 0.05
@export var wood_percentage: float = 0.05

const GOOD_FISH = preload("res://trading_system/good_fish.tres")
const GOOD_GRAIN = preload("res://trading_system/good_grain.tres")
const GOOD_WOOD = preload("res://trading_system/good_wood.tres")

const GoodScene = preload("res://world/good.tscn")


func generate_goods(proc_gen_world: ProcGenWorld):
	var width = proc_gen_world.width
	var viewport = proc_gen_world.get_viewport()
	var goods_root = proc_gen_world.goods
	var all_goods = proc_gen_world.get_goods()
	
	var shallow_water_arr = proc_gen_world.shallow_water_arr
	var deep_water_arr = proc_gen_world.deep_water_arr
	var tree_arr = proc_gen_world.tree_arr
	var farm_arr = proc_gen_world.grass_arr.filter(func(pos): return not (pos in tree_arr))

	var goods_to_generate = int(width * fish_percentage * 0.33) - _get_goods_by_type(all_goods, GOOD_FISH).size()
	_generate_goods_of_type(GOOD_FISH, goods_to_generate, shallow_water_arr, goods_root, viewport)
	
	goods_to_generate = int(width * fish_percentage * 0.66) - _get_goods_by_type(all_goods, GOOD_FISH).size()
	_generate_goods_of_type(GOOD_FISH, goods_to_generate, deep_water_arr, goods_root, viewport)
	
	goods_to_generate = int(width * grain_percentage) - _get_goods_by_type(all_goods, GOOD_GRAIN).size()
	_generate_goods_of_type(GOOD_GRAIN, goods_to_generate, farm_arr, goods_root, viewport)
	
	goods_to_generate = int(width * wood_percentage) - _get_goods_by_type(all_goods, GOOD_WOOD).size()
	_generate_goods_of_type(GOOD_WOOD, int(width * wood_percentage), tree_arr, goods_root, viewport)


func _generate_goods_of_type(good_resource: GoodResource, goods_to_generate: int, positions: Array[Vector2i], goods_root: Node2D, viewport: Viewport) -> void:
	for i in range(goods_to_generate):
		var spawn_position = _pick_hidden_tile_position(viewport, positions)
		if spawn_position == INVALID_TILE_POSITION:
			continue
		var good: Good = GoodScene.instantiate() 
		good.good_resource = good_resource
		good.global_position = spawn_position * ProcGenWorld.TILE_SIZE
		goods_root.add_child(good)


func _get_goods_by_type(all_goods: Array[Good], good_resource: GoodResource) -> Array[Good]:
	return all_goods.filter(func(good): return good.good_resource == good_resource)
