extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play("door_closed")

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		$AudioStreamPlayer2D.play()
		var screen_pos = get_global_transform_with_canvas().origin
		get_tree().paused = true
		Signal_Bus.level_finished.emit(screen_pos)
		$AnimatedSprite2D.play("door_open")
		await $AnimatedSprite2D.animation_finished
