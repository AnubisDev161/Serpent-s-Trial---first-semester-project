extends PlayerState

# ?
# ~ sets is_pushing so collider wont flip when changing dir in sprite_flip()
func enter(previous_state: String, data := {}) -> void:
	player.anim.play("player_push_start")
	player.is_pushing = true
	player.petrify_laser.enable_raycast(false)
	player.push_object.set_attach(true)
	pass

func physics_update(_delta: float) -> void:
	# Movespeed * .5 to make Obj feel heavy, mby new var?
	player._move(_delta, player.push_speed) 
	
	if is_zero_approx(Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")) && player.anim.current_animation!= "player_push_start":
		player.anim.pause()
	else:
		player.anim.play()
	
	if player.is_dead == true:
		finished.emit(DEAD)
	if !player.is_grounded():
		finished.emit(FALL)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMP)
	elif Input.is_action_just_released("push"):
		if is_zero_approx(Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")):
			finished.emit(IDLE)
		else:
			finished.emit(WALK)
	elif player.push_object == null:
		finished.emit(IDLE)

func exit() -> void:
	player.anim.stop()
#	player.anim.queue("player_push_end")
	if player.push_object:
		player.push_object.set_attach(false)
		player.push_object = null
	player.is_pushing = false
	if player.shots <1:
		player.petrify_laser.enable_raycast(false)
		
	else:
		player.petrify_laser.enable_raycast(true)
