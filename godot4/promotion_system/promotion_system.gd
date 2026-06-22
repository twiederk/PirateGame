class_name PromotionSystem
extends Node


signal rank_promoted(new_rank: PrestigeRank)

var trader_ranks: Dictionary = {
	0: preload("res://promotion_system/trader_rank_01.tres"),
	500: preload("res://promotion_system/trader_rank_02.tres"),
	1_000: preload("res://promotion_system/trader_rank_03.tres"),
	2_500: preload("res://promotion_system/trader_rank_04.tres"),
	5_000: preload("res://promotion_system/trader_rank_05.tres"),
	7_500: preload("res://promotion_system/trader_rank_06.tres"),
	10_000: preload("res://promotion_system/trader_rank_07.tres"),
}

var sailer_ranks: Dictionary = {
	0: preload("res://promotion_system/sailer_rank_01.tres"),
	1: preload("res://promotion_system/sailer_rank_02.tres"),
	2: preload("res://promotion_system/sailer_rank_03.tres"),
}


func get_trader_rank(gold: int) -> PrestigeRank:
	var trader_rank = trader_ranks[0]
	for gold_threadhold in trader_ranks:
		if gold >= gold_threadhold:
			trader_rank = trader_ranks[gold_threadhold]
	return trader_rank


func get_sailer_rank(ship: ShipResource) -> PrestigeRank:
	var ship_id = 0
	if ship != null:
		ship_id = ship.id
	var sailer_rank = sailer_ranks[ship_id]
	for ship_threadhold in sailer_ranks:
		if ship_id >= ship_threadhold:
			sailer_rank = sailer_ranks[ship_id]
	return sailer_rank


func evaluate(player: Player) -> void:
	var new_trader_rank = get_trader_rank(player.gold)
	if new_trader_rank.is_greater_than(player.trader_rank):
		player.trader_rank = new_trader_rank
		rank_promoted.emit(new_trader_rank)

	var new_sailer_rank = get_sailer_rank(player.get_ship())
	if new_sailer_rank.is_greater_than(player.sailer_rank):
		player.sailer_rank = new_sailer_rank
		rank_promoted.emit(new_sailer_rank)
