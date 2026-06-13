class_name TradingRow
extends HBoxContainer


signal buy_requested(good_id: int, amount: int)
signal sell_requested(good_id: int, amount: int)

var good_id: int
var _trading_system: TradingSystem
var _player: Player
var _town: Town

@onready var good_name: Label = $GoodName
@onready var good_price: Label = $GoodPrice
@onready var player_amount: Label = $PlayerAmount
@onready var town_amount: Label = $TownAmount
@onready var buy_button: Button = $BuyButton
@onready var sell_button: Button = $SellButton


func _ready() -> void:
	update_display()


func init(id: int, trading_system: TradingSystem, player: Player, town: Town) -> void:
	good_id = id
	_trading_system = trading_system
	_player = player
	_town = town


func update_display() -> void:
	var good = _trading_system.goods[good_id]
	var player_item = _player.get_trading_item(good_id)
	var town_item = _town.get_trading_item(good_id)
	
	good_name.text = good.name
	good_price.text = str(_trading_system.get_price(town_item))
	player_amount.text = str(player_item.stock)
	town_amount.text = str(town_item.stock)


func _on_buy_button_pressed() -> void:
	buy_requested.emit(good_id, 1)


func _on_sell_button_pressed() -> void:
	sell_requested.emit(good_id, 1)
