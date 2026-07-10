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
		"Lübeck",
		"Danzig",
		"Kiel",
		"Stralsund",
		"Rostock",
		"Emden",
		"Wismar",
		"Greifswald",
		"Stettin",
		"Cuxhaven"
	],
	Type.Farm: [
		"Leipzig",
		"Magdeburg",
		"Dresden",
		"Erfurt",
		"Bamberg",
		"Würzburg",
		"Regensburg",
		"Augsburg",
		"Nürnberg",
		"Frankfurt",
		"Braunschweig"
	],
	Type.Woodcamp: [
		"Königsberg",
		"Breslau",
		"Konstanz",
		"Lindau",
		"Ravensburg",
		"Weingarten",
		"Tettnang",
		"Ulm",
		"Esslingen",
		"Tübingen",
		"Reutlingen",
		"Heilbronn",
		"Cannstatt",
		"Waiblingen",
		"Gmünd",
	],
	
}
