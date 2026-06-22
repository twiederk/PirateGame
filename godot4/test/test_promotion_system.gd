extends GutTest


const TRADER_RANK_01 = preload("res://promotion_system/trader_rank_01.tres")
const TRADER_RANK_02 = preload("res://promotion_system/trader_rank_02.tres")
const SAILER_RANK_01 = preload("res://promotion_system/sailer_rank_01.tres")
const SAILER_RANK_02 = preload("res://promotion_system/sailer_rank_02.tres")

var promotion_system: PromotionSystem = null
var player: Player = null


func before_each():
	promotion_system = PromotionSystem.new()
	player = Player.new()


func after_each():
	promotion_system.free()
	player.free()


func test_get_trader_rank():
	# act
	var trader_rank = promotion_system.get_trader_rank(100)
	
	# assert
	assert_eq(trader_rank, TRADER_RANK_01)


func test_get_sailer_rank():
	# arrange
	var ship: ShipResource = ShipResource.new()
	ship.id = 1

	# act
	var sailer_rank = promotion_system.get_sailer_rank(ship)
	
	# assert
	assert_eq(sailer_rank, SAILER_RANK_02)


func test_get_sailer_rank_with_ship_is_null():
	# act
	var sailer_rank = promotion_system.get_sailer_rank(null)
	
	# assert
	assert_eq(sailer_rank, SAILER_RANK_01)


func test_evaluate_promote_to_trader_rank_02():
	# arrange
	player.trader_rank = TRADER_RANK_01
	player.gold = 500

	# act
	promotion_system.evaluate(player)

	# assert
	assert_eq(player.trader_rank, TRADER_RANK_02, "Player trader rank should be promoted to trader rank 02")


func test_evaluate_promote_to_sailer_rank_02():
	# arrange
	player.sailer_rank = SAILER_RANK_01
	var ship: ShipResource = ShipResource.new()
	ship.id = 1
	player._ship_resource = ship

	# act
	promotion_system.evaluate(player)

	# assert
	assert_eq(player.sailer_rank, SAILER_RANK_02, "Player sailer rank should be promoted to sailer rank 02")
