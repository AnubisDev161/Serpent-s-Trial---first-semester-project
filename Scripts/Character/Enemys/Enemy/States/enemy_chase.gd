extends EnemyState

var old_dir

func enter(previous_state, data := {}):
	enemy.shoot_icon.visible = true
	old_dir = enemy.direction
	
func physics_update(_delta):
	if !enemy.is_grounded():
		enemy.velocity.y += enemy.gravity * _delta
	enemy.direction = (enemy.player.global_position - enemy.global_position).normalized()
	enemy.velocity.x = enemy.direction.x * enemy.speed * _delta
	enemy.move_and_slide()
	enemy.sprite_flip()

	if enemy.is_on_wall():
		enemy.anim.stop()
		enemy.anim.play("enemy_idle")
	else:
		enemy.anim.play("enemy_walk")

	if enemy.is_petrified:
		finished.emit(PETRI)
	elif !enemy.is_player_in_range():
		finished.emit(IDLE)
	elif enemy.is_player_in_range() && enemy.can_shoot && enemy.is_looking_at_player(enemy.player.global_position):
		finished.emit(SHOOT)

func exit():
	enemy.direction = old_dir
	enemy.shoot_icon.visible = false
	enemy.anim.stop()
