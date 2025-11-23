extends EnemyState
var in_air = false
# ?
# ~ shows the frozen icon (or change sprite mby?)
# ~ applys gravity   
func enter(previous_state, data := {}):
	#enemy.floor_max_angle = deg_to_rad(45)
	enemy.anim_player.play("enemy_petrify")
	enemy.set_collision_layer_value(4, true)
	enemy.set_collision_mask_value(3, false)
	enemy.velocity = Vector2.ZERO

func physics_update(_delta):
	if !enemy.is_grounded():
		in_air = true
		enemy.velocity.x = 0
		enemy.velocity.y += enemy.gravity * _delta
		if enemy.velocity.y >= 2000:
			enemy.velocity.y = 2000
		if enemy.velocity.y < 0:
			enemy.velocity.y = 0
		enemy.move_and_slide()
	else:
		if in_air == true:
			enemy.rock_falling_sound.play()
			in_air = false
	
	if enemy.is_attached:
		finished.emit(ATTACHED)

func exit():
	enemy.floor_max_angle = deg_to_rad(45)
