extends Sprite2D
@export var lit_color: Color = Color(1.5, 3, 1.5, 1)
@export var unlit_color: Color = Color.WHITE

func _on_switch_left() -> void:
	self_modulate = unlit_color


func _on_switch_pressed() -> void:
	self_modulate = lit_color
