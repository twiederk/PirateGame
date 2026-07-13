class_name GoodsGenerator


@export var fish_percentage: float = 0.125
@export var grain_percentage: float = 0.05
@export var wood_percentage: float = 0.05

const INVALID_TILE_POSITION: Vector2i = Vector2i(-1, -1)

const GOOD_FISH = preload("res://trading_system/good_fish.tres")
const GOOD_GRAIN = preload("res://trading_system/good_grain.tres")
const GOOD_WOOD = preload("res://trading_system/good_wood.tres")

const GoodScene = preload("res://world/good.tscn")


func generate_goods(proc_gen_world: ProcGenWorld):
	var width = proc_gen_world.width
	var viewport = proc_gen_world.get_viewport()
	var goods_root = proc_gen_world.goods
	var all_goods = proc_gen_world.get_goods()
	var farm_arr = proc_gen_world.grass_arr.filter(func(pos): return not (pos in proc_gen_world.tree_arr))

	var goods_to_generate = int(width * fish_percentage * 0.33) - proc_gen_world._goods_by_type(all_goods, GOOD_FISH).size()
	_generate_goods_of_type(GOOD_FISH, goods_to_generate, proc_gen_world.shallow_water_arr, goods_root, viewport)
	
	goods_to_generate = int(width * fish_percentage * 0.66) - proc_gen_world._goods_by_type(all_goods, GOOD_FISH).size()
	_generate_goods_of_type(GOOD_FISH, goods_to_generate, proc_gen_world.deep_water_arr, goods_root, viewport)
	
	goods_to_generate = int(width * grain_percentage) - proc_gen_world._goods_by_type(all_goods, GOOD_GRAIN).size()
	_generate_goods_of_type(GOOD_GRAIN, goods_to_generate, farm_arr, goods_root, viewport)
	
	goods_to_generate = int(width * wood_percentage) - proc_gen_world._goods_by_type(all_goods, GOOD_WOOD).size()
	_generate_goods_of_type(GOOD_WOOD, int(width * wood_percentage), proc_gen_world.tree_arr, goods_root, viewport)

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


func _pick_hidden_tile_position(viewport: Viewport, positions: Array[Vector2i]) -> Vector2i:
	if positions.is_empty():
		return INVALID_TILE_POSITION

	var hidden_positions: Array[Vector2i] = positions.filter(func(pos): return not _is_tile_position_visible(viewport, pos))
	if hidden_positions.is_empty():
		return INVALID_TILE_POSITION

	return hidden_positions.pick_random()

func _is_tile_position_visible(viewport: Viewport, tile_position: Vector2i) -> bool:
	if viewport == null:
		return false

	var camera: Camera2D = viewport.get_camera_2d()
	if camera == null:
		return false

	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var visible_size: Vector2 = viewport_size * camera.zoom
	var visible_origin: Vector2 = camera.get_screen_center_position() - (visible_size * 0.5)
	var visible_rect := Rect2(visible_origin, visible_size)

	var tile_size: Vector2i = ProcGenWorld.TILE_SIZE
	var tile_world_rect := Rect2(Vector2(tile_position * tile_size), Vector2(tile_size))
	return visible_rect.intersects(tile_world_rect)
