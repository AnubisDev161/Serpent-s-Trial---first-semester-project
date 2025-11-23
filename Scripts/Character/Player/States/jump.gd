extends PlayerState

var curr_velo = 0

func enter(previous_state: String, data := {}) -> void:
	player.anim.play("player_jump")
	#player.petrify_laser.enable_raycast(false)
	player.velocity.y = player.jump_power
	player.play_jump_vfx()

func physics_update(_delta: float) -> void:
	player._move(_delta, player.speed)
	if player.velocity.y == curr_velo:
		finished.emit(IDLE)
		player.velocity.y = 0
	if player.is_dead == true:
		finished.emit(DEAD)
	elif Input.is_action_just_pressed("attack") && player.shots >=1:
		finished.emit(ATTACK)
	elif player.velocity.y >= 0:
		finished.emit(FALL)
	curr_velo = player.velocity.y

func handle_input(event) -> void:
	if event.is_action_released("jump"):
		if player.velocity.y < 0.0:
			player.velocity.y *= 0.4

func exit() -> void:
	#player.petrify_laser.enable_raycast(true)
	pass
