extends EnemyOwlState

func enter(previous_state, data := {}):
	enemy.anim.play("enemy_idle")
