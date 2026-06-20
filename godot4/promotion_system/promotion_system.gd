class_name PromotionSystem
extends Node


const GOLD_TITLES: Dictionary = {
	0: "Krämer",
	500: "Händler",
	1_000: "Großhändler",
	2_500: "Kaufmann",
	5_000: "Großkaufmann",
	7_500: "Zunftmeister",
	10_000: "Handelsfürst",
}


func get_gold_title(gold: int) -> String:
	var gold_title = GOLD_TITLES[0]
	for gold_threadhold in GOLD_TITLES:
		if gold >= gold_threadhold:
			gold_title = GOLD_TITLES[gold_threadhold]
	return gold_title
