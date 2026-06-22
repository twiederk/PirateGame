class_name InventoryScreen
extends Control


@onready var trader_rank = $CenterContainer/VBoxContainer/RankRow/TraderRank
@onready var sailer_rank = $CenterContainer/VBoxContainer/RankRow/SailerRank


func show_inventory(player: Player) -> void:
	trader_rank.text = player.trader_rank.title
	sailer_rank.text = player.sailer_rank.title
	show()
