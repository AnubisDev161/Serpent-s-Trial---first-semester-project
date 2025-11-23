extends Area2D

@export var tooltip_index: int

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		Signal_Bus.ui_show_tooltip_popup.emit(tooltip_index)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		Signal_Bus.ui_hide_tooltip_popup.emit()
