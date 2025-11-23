extends PlayerState

func enter(previous_state, data := {}):
	player.can_move = false
	player.anim.play("player_attack")

func physics_update(_delta):
	player._move(_delta, player.speed * 0.7)
	if Input.is_action_just_pressed("jump") and player.is_grounded():
		finished.emit(JUMP)
	if player.is_dead == true:
		finished.emit(DEAD)

func exit():
	player.can_move = true

func _on_player_petrify_raycast_shot_performed() -> void:
	finished.emit(IDLE)

func _on_player_laser_shot_performed() -> void:
	if player.petrify_laser.target != null:
		player.shots -=1
		if player.shots <5:
			player.ingame_ui.update_charges_ui()
	finished.emit(IDLE)
