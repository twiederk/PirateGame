class_name TownResource
extends Resource


@export var type: Type
@export var name: String
@export var background_color: Color
@export var produces: Array[GoodResource]
@export var consumes: Array[GoodResource]
@export var ships: Array[ShipResource]

enum Type { Habor, Farm, Woodcamp }

static var name_dictionary: Dictionary = {
	Type.Habor: [
		"Hamburg",
		"Bremen",
		"Bremerhaven",
		"Kiel",
		"Lübeck",
		"Rostock",
		"Wilhelmshaven",
		"Cuxhaven",
		"Emden",
		"Flensburg",
		"Stralsund"
	],
	Type.Farm: [
		"Münster",
		"Oldenburg",
		"Osnabrück",
		"Hildesheim",
		"Magdeburg",
		"Erfurt",
		"Bamberg",
		"Würzburg",
		"Regensburg",
		"Passau",
		"Kempten"
	],
	Type.Woodcamp: [
		"Eberswalde",
		"Baiersbronn",
		"Freudenstadt",
		"Triberg",
		"Tharandt",
		"Clausthal-Zellerfeld",
		"Ilmenau",
		"Suhl",
		"Winterberg",
		"Sankt Andreasberg",
		"Schmallenberg"
	],
	
}
