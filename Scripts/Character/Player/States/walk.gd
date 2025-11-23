extends PlayerState

func enter(previous_state, data := {}):
	player.anim.queue("player_walk")
	
func physics_update(_delta: float) -> void:
	player._move(_delta, player.speed)
	#if player.audio_stream_player_2d.playing == false:
		#player.audio_stream_player_2d.play()
	
	if player.is_dead == true:
		finished.emit(DEAD)
	if !player.is_grounded():
		finished.emit(FALL)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMP)
	elif is_equal_approx(Input.get_axis("walk_left", "walk_right"), 0.0):
		finished.emit(IDLE)
	elif Input.is_action_just_pressed("attack") && player.shots >=1:
		finished.emit(ATTACK)
	elif Input.is_action_just_pressed("interact") && player.interactable != null:
		finished.emit(INTERACT)
	elif Input.is_action_just_pressed("push"):
		player.update_push_object()
		if player.push_object != null:
			finished.emit(PUSH)

func exit():
	player.anim.stop()
