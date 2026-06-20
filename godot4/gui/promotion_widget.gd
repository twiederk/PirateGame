class_name PromotionWidget
extends Control

@onready var promotion_label = $PromotionLabel


func show_promotion(new_rank: PrestigeRank) -> void:
	show()
	var message = "Du hat den neuen Titel: " + new_rank.title + " erhalten!" 
	promotion_label.text = message
