class_name InventoryScreen
extends Control

signal active_ship_selected(ship_resource: ShipResource)

var number_format = NumberFormat.new()

@onready var trader_rank = $CenterContainer/VBoxContainer/RankRow/TraderRank
@onready var sailer_rank = $CenterContainer/VBoxContainer/RankRow/SailerRank
@onready var gold = $CenterContainer/VBoxContainer/StatsRow/Gold
@onready var capacity = $CenterContainer/VBoxContainer/StatsRow/Capacity
@onready var ship = $CenterContainer/VBoxContainer/ShipRow/Ship
@onready var ship_buttons = $CenterContainer/VBoxContainer/ShipButtons
@onready var fish = $CenterContainer/VBoxContainer/InventoryTable/HBoxContainer/Fish
@onready var grain = $CenterContainer/VBoxContainer/InventoryTable/HBoxContainer2/Grain
@onready var wood = $CenterContainer/VBoxContainer/InventoryTable/HBoxContainer3/Wood
@onready var treasure_map = $CenterContainer/VBoxContainer/InventoryTable/HBoxContainer4/TreasureMap



func show_inventory(player: Player) -> void:
	trader_rank.text = player.trader_rank.title
	sailer_rank.text = player.sailer_rank.title
	gold.text = number_format.format(player.gold)
	capacity.text = str(player.get_used_capacity()) + " / " + str(player.cargo_capacity)
	ship.text = _get_ship(player)
	_create_ship_buttons(player)
	fish.text = str(player.get_trading_item(1).stock)
	grain.text = str(player.get_trading_item(2).stock)
	wood.text = str(player.get_trading_item(3).stock)
	treasure_map.texture = player.treasure.texture
	treasure_map.size = Vector2(100, 100)
	show()


func _get_ship(player: Player) -> String:
	var ship_resource: ShipResource = player.get_ship()
	if ship_resource == null:
		return "Kein Schiff"
	return ship_resource.name


func _create_ship_buttons(player: Player) -> void:
	for child in ship_buttons.get_children():
		child.queue_free()

	for ship_resource in player.get_ships():
		var button = Button.new()
		button.text = ship_resource.name
		if player.get_ship() == ship_resource:
			button.text += " (aktiv)"
		button.disabled = player.current_state == Player.State.ON_SHIP
		button.pressed.connect(_on_ship_button_pressed.bind(ship_resource))
		ship_buttons.add_child(button)
		button.grab_focus()


func _on_ship_button_pressed(ship_resource: ShipResource) -> void:
	active_ship_selected.emit(ship_resource)
