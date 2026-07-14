class_name TreasureResource
extends Resource


enum Rareness {
	COMMON,
	RARE,
	VERY_RARE,
}


@export var price_range: Vector2i = Vector2i(10, 50)
@export var gold_range: Vector2i = Vector2i(5, 10)
@export var treasure_map_size: Vector2i = Vector2i(100, 100)
@export var rare_type: Rareness = Rareness.COMMON


func get_price() -> int:
	return randi_range(price_range.x, price_range.y) * 10


func get_gold() -> int:
	return randi_range(gold_range.x, gold_range.y) * 100
