extends EnemyState

# ? 
# needs reference to player
# ~ makes enemy move with player 
# ~ sets collision mask so u dont collide with the 
#   barriers that change the enemy dir

# ?
# movement des enemys passiert im player 
func physics_update(_delta):
	if !enemy.is_grounded():
		enemy.velocity.y += enemy.gravity * _delta
		#enemy.is_attached = false
		#enemy.player.push_object = null
		enemy.velocity.x = 0
	else:
		enemy.velocity.y = 0
		enemy.position.y = enemy.position.y

	if abs(enemy.player.velocity.x) > 0:
		if enemy.rock_push_sound.playing == false:
			enemy.rock_push_sound.play()
	else:
		if enemy.rock_push_sound.playing == true:
			enemy.rock_push_sound.stop()

	if !enemy.is_attached :
		finished.emit(PETRI)

func exit():
	enemy.rock_push_sound.stop()
