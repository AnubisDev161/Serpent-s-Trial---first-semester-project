extends EnemyState

# ? 
# ~ makes enemy move around and change direction
#	when he hits a wall or player
# ~ hurts player on contact
func enter(previous_state, data := {}):
	enemy.anim.play("enemy_walk")

func physics_update(_delta):
	if !enemy.is_grounded():
		enemy.velocity.y += enemy.gravity * _delta
	enemy.velocity.x = enemy.direction.x * enemy.speed * _delta
	enemy.move_and_slide()

	if enemy.is_on_wall(): 
		enemy.direction = enemy.direction * -1

	enemy.sprite_flip()
	
	# Transitions
	if enemy.is_petrified:
		finished.emit(PETRI)
	#elif enemy.is_player_in_range() && enemy.can_shoot && enemy.is_looking_at_player(enemy.player.global_position):
		#finished.emit(SHOOT)
	elif enemy.is_player_in_range():
		finished.emit(CHASE)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("update_health") && !enemy.is_petrified:
		body.update_health(-1)
