extends PlayerState

var que_bored_anim = false

func enter(previous_state, data := {}):
	player.anim.queue("player_idle")
	if player.shots <1:
		player.petrify_laser.enable_raycast(false)
		
	else:
		player.petrify_laser.enable_raycast(true)

func physics_update(_delta: float) -> void:
	player.velocity.y += player.gravity * _delta
	player._move(_delta, player.speed)
	if player.is_dead == true:
		finished.emit(DEAD)
	if Input.is_action_just_pressed("jump") and player.is_grounded():
		finished.emit(JUMP)
	elif (Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")) != 0:
		finished.emit(WALK)
	elif Input.is_action_just_pressed("interact") && player.interactable != null:
		finished.emit(INTERACT)
	elif Input.is_action_just_pressed("attack") && player.shots >=1:
		finished.emit(ATTACK)
	elif Input.is_action_just_pressed("push"):
		player.update_push_object()
		if player.push_object != null:
			finished.emit(PUSH)

func exit():
	player.anim.clear_queue()
	player.anim.stop()

func randomize_idle_anim():
	if player.bored_timer.is_stopped():
		var random_wait_time = randf_range(10.0, 15.0)
		player.bored_timer.wait_time = random_wait_time
		player.bored_timer.start()
	if que_bored_anim == true:
		player.anim.play("player_idle_bored")
		que_bored_anim = false
		player.anim.queue("player_idle")
	else:
		player.anim.queue("player_idle")

func _on_bored_timer_timeout() -> void:
	que_bored_anim = true
