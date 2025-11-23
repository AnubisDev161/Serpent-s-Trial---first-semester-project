extends Camera2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("zoom_in"):
		zoom -= Vector2(0.05, 0.05)
	
	if Input.is_action_just_pressed("zoom_out"):
		zoom +=Vector2(0.05, 0.05)
