class_name PromotionWidget
extends Control


@onready var promotion_label = $PromotionLabel
@onready var timer = $Timer


func show_promotion(new_rank: PrestigeRank) -> void:
	promotion_label.text = "Du hat den neuen Titel: " + new_rank.title + " erhalten!" 
	timer.start()
	show()


func _on_timer_timeout():
	hide()
