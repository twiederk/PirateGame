class_name TownResource
extends Resource


enum Type { Habor, Farm, Woodcamp }


@export var type: Type
@export var name: String
@export var background_color: Color
@export var produces: Array[GoodResource]
@export var consumes: Array[GoodResource]
@export var ships: Array[ShipResource]
