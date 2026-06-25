extends GutTest

const GOOD_FISH = preload("res://trading_system/good_fish.tres")

var proc_gen_world: ProcGenWorld = null


func before_each():
	proc_gen_world = ProcGenWorld.new()


func after_each():
	proc_gen_world.free()
