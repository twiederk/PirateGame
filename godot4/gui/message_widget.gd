class_name MessageWidget
extends Control

@onready var message_label: Label = $MessageLabel
@onready var timer = $Timer


func _show_message(message: String) -> void:
	message_label.text = message
	timer.start()
	show()


func _on_timer_timeout() -> void:
	hide()


func _on_good_collected(good: GoodResource, amount: int) -> void:
	var message = str("Du hast " + str(amount) + " " + good.name + " erhalten.", amount)
	_show_message(message)
