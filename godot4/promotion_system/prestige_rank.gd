class_name PrestigeRank
extends Resource


@export var title: String
@export var prio: int


func is_greater_than(other: PrestigeRank) -> bool:
	return prio > other.prio
