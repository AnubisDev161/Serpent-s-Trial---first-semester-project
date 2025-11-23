extends PlayerState

func enter(previous_state, data := {}):
	if player.interactable.has_method("pull_lever"):
		player.interactable.pull_lever()

func physics_update(_delta):
	
	if player.is_dead == true:
		finished.emit(DEAD)
	
	if is_equal_approx(player.velocity.x, 0.0):
		finished.emit(IDLE)
	else:
		finished.emit(WALK)
