extends Node2D

@export var player: Player
@export var level_goal: Area2D
@export var opening: Path2D

func _ready() -> void:
	#region ERRORS
	if player == null:
		push_error("PLAYER NOT ASSIGNED TO LEVEL")
	if level_goal == null:
		push_error("LEVEL-GOAL NOT ASSIGNED TO LEVEL")
	if opening == null:
		push_error("OPENING NOT ASSIGNED TO LEVEL")
	#endregion
	
	set_enemy_player_reference()

func set_enemy_player_reference():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies.size():
		if enemies[enemy].has_method("set_attach"):
			enemies[enemy].player = player

func start_opening():
	if opening != null:
		opening.start_opening(player)
	else:
		Signal_Bus.cutscene_finished.emit()
