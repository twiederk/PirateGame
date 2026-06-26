class_name ShipRow
extends HBoxContainer

signal ship_bought(ship_resource: ShipResource)

var number_format = NumberFormat.new()

var _ship_resource: ShipResource

@onready var ship_name = $ShipName
@onready var ship_speed = $ShipSpeed
@onready var ship_price = $ShipPrice
@onready var buy_button: Button = $BuyButton


func _ready():
	ship_name.text = _ship_resource.name
	ship_speed.text = str(int(_ship_resource.speed * 0.1))
	ship_price.text = number_format.format(_ship_resource.price)
	

func init(ship_resource: ShipResource):
	_ship_resource = ship_resource



func _on_buy_button_pressed() -> void:
	ship_bought.emit(_ship_resource)
