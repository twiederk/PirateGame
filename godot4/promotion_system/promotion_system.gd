class_name PromotionSystem
extends Node


var trader_ranks: Dictionary = {
	0: PrestigeRank.new("Krämer", 1),
	500: PrestigeRank.new("Händler", 1),
	1_000: PrestigeRank.new("Großhändler", 1),
	2_500: PrestigeRank.new("Kaufmann", 1),
	5_000: PrestigeRank.new("Großkaufmann", 1),
	7_500: PrestigeRank.new("Zunftmeister", 1),
	10_000: PrestigeRank.new("Handelsfürst", 1),
}


func get_trader_rank(gold: int) -> PrestigeRank:
	var trader_rank = trader_ranks[0]
	for gold_threadhold in trader_ranks:
		if gold >= gold_threadhold:
			trader_rank = trader_ranks[gold_threadhold]
	return trader_rank
