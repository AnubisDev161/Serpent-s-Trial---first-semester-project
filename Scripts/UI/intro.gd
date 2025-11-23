extends Node


func _ready() -> void:
	intro()

func intro():
	$AnimationPlayer.play("fade_in")
	await get_tree().create_timer(3).timeout
	get_tree().create_tween().set_trans(Tween.TRANS_SPRING).tween_property($Sprite2D, "position", Vector2(2560 / 2, 1440 / 2), 1)
	await get_tree().create_timer(4).timeout
	get_tree().create_tween().set_trans(Tween.TRANS_SPRING).tween_property($Sprite2D, "position", Vector2(2560 / 2, 1440 + 346.5), 1)
	$AnimationPlayer.play("fade_out")
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://Scenes/Levels/Game.tscn")
