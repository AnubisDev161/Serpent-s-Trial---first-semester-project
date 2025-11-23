extends PlayerState

func enter(previous_state: String, data := {}) -> void:
	player.anim.play("player_fall")
	if (previous_state == "Walk" or previous_state == "Idle"):
		player._start_coyote_time()

func physics_update(_delta: float) -> void:
	if !player.coyote_timer.is_stopped():
		if Input.is_action_just_pressed("jump"):
			finished.emit(JUMP)
	
	player._move(_delta, player.speed)
	
	if player.is_dead == true:
		finished.emit(DEAD)
	elif  player.is_grounded():
		player.play_jump_vfx()
		if is_equal_approx(player.velocity.x, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(WALK)
	elif Input.is_action_just_pressed("attack") && player.shots >=1:
		finished.emit(ATTACK)

func exit():
	player.anim.stop()
