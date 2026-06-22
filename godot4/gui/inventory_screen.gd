class_name InventoryScreen
extends Control


var number_format = NumberFormat.new()

@onready var trader_rank = $CenterContainer/VBoxContainer/RankRow/TraderRank
@onready var sailer_rank = $CenterContainer/VBoxContainer/RankRow/SailerRank
@onready var gold = $CenterContainer/VBoxContainer/StatsRow/Gold
@onready var capacity = $CenterContainer/VBoxContainer/StatsRow/Capacity
@onready var ship = $CenterContainer/VBoxContainer/ShipRow/Ship
@onready var fish = $CenterContainer/VBoxContainer/InventoryTable/HBoxContainer/Fish
@onready var grain = $CenterContainer/VBoxContainer/InventoryTable/HBoxContainer2/Grain
@onready var wood = $CenterContainer/VBoxContainer/InventoryTable/HBoxContainer3/Wood


func show_inventory(player: Player) -> void:
	trader_rank.text = player.trader_rank.title
	sailer_rank.text = player.sailer_rank.title
	gold.text = number_format.format(player.gold)
	capacity.text = str(player.get_used_capacity()) + " / " + str(player.cargo_capacity)
	ship.text = _get_ship(player)
	fish.text = str(player.get_trading_item(1).stock)
	grain.text = str(player.get_trading_item(2).stock)
	wood.text = str(player.get_trading_item(3).stock)
	show()


func _get_ship(player: Player) -> String:
	var ship_resource: ShipResource = player.get_ship()
	if ship_resource == null:
		return ""
	return ship_resource.name
