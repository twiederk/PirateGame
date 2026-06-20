extends GutTest

var promotion_system: PromotionSystem = null
var player: Player = null


func before_each():
	player = Player.new()
	promotion_system = PromotionSystem.new()


func after_each():
	player.free()
	promotion_system.free()


func test_promote_to_haendler_at_500_gold():
	# arrange
	player.current_title = "Krämer"
	player.gold = 500

	# act
	promotion_system.evaluate(player)

	# assert
	assert_eq(player.current_title, "Händler", "Player title should be promoted to Händler at 500 gold")
