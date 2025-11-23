extends StaticBody2D
var is_active = false
signal activated
signal deactivated

func change_receiver_state():
	if is_active == false:
		is_active = true
		emit_signal("activated")
		$AnimationPlayer.play("Enabled")
	else:
		is_active = false
		emit_signal("deactivated")
		$AnimationPlayer.play("Disabled")
