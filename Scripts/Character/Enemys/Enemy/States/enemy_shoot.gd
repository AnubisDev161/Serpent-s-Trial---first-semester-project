extends EnemyState

@export var freeze_time: float = .5
var timer: float = 0.0
var shoot_dir
# ?
# shoot state for the enemy
#	- plays a animation and shoots projectile after short cooldwon (freeze_time)
#	- start a timer in the enemy, so the attack wont get spammed 
#	- leaves the state when the attack is finished 
func enter(previous_state, data := {}):
	enemy.velocity = Vector2.ZERO
	enemy.shoot_icon.visible = true
	enemy.anim_player.play("enemy_shoot")
	enemy.attack_timer.start()
	shoot_dir = (enemy.player.position - enemy.position).normalized()
	enemy.direction = shoot_dir
	timer = freeze_time
	pass

func physics_update(_delta):
	if !enemy.is_grounded():
		enemy.velocity.y += enemy.get_gravity().y * enemy.gravity * _delta
	enemy.move_and_slide()

	# Transitions
	if enemy.is_petrified:
		finished.emit(PETRI)
	elif !enemy.can_shoot:
		if enemy.is_player_in_range():
			finished.emit(CHASE)
		else:
			finished.emit(PATROL)

func exit():
	enemy.shoot_icon.visible = false
	enemy.anim_player.stop()

func shoot():
	if enemy.can_shoot:
		var new_projectile = enemy.projectile.instantiate()
		enemy.add_child(new_projectile)
		new_projectile.global_position = enemy.global_position
		new_projectile.direction = shoot_dir
		enemy.can_shoot = false
