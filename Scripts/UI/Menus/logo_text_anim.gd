extends AnimationPlayer

func _process(delta: float) -> void:
	if !is_playing() && get_parent().visible:
		play("text_float")
