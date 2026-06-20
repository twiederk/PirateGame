extends GutTest

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
	assert_eq(trader_rank.title, "Krämer")


#func test_promote_to_haendler_at_500_gold():
	## arrange
	#player.current_title = "Krämer"
	#player.gold = 500
#
	## act
	#promotion_system.evaluate(player)
#
	## assert
	#assert_eq(player.current_title, "Händler", "Player title should be promoted to Händler at 500 gold")
