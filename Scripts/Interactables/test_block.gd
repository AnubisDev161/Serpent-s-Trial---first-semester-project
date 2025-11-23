extends RigidBody2D


func is_pushable():
	return true
	
func on_pushed_by_player(player):
	if abs(linear_velocity.x) >= player.push_velo_max:
		return
	else:
		linear_velocity.x = player.push_force *  player.input_direction_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
