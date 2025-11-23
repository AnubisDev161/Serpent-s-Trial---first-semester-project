extends EnemyState

# ?
# ur average idle state ig? 
func enter(previous_state, data := {}):
	enemy.anim.play("enemy_idle")

func physics_update(_delta):
	if !enemy.is_grounded():
		enemy.velocity.y +=  enemy.gravity * _delta
	enemy.move_and_slide()

	# Transitions
	if enemy.is_petrified:
		finished.emit(PETRI)
	elif enemy.is_grounded():
		finished.emit(PATROL)
