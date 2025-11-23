extends PlayerState

func enter(previous_state, data := {}):
	Signal_Bus.emit_signal("music_and_sound_manager_play_player_died_sfx")
	player.anim.play("player_die")
	player.set_collision_layer_value(1, false)
	player.set_collision_mask_value(1, false)
	player.petrify_laser.enable_raycast(false)
	await player.anim.animation_finished
	Signal_Bus.level_reload.emit()
	player.anim.play("player_dead")
	
func physics_update(_delta):
	player.velocity.y += player.gravity * _delta
	player._move(_delta, 0)
