extends TextureButton

@export var label: Label
@export var hoverd_color: Color = Color(255, 128, 245, 255)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	change_label_color_to_hovered(true)


func _on_mouse_exited() -> void:
	change_label_color_to_hovered(false)


func _on_focus_entered() -> void:
	change_label_color_to_hovered(true)


func _on_focus_exited() -> void:
	change_label_color_to_hovered(false)

func change_label_color_to_hovered(to_hovered):
	if to_hovered == true:
		label.modulate = Color(hoverd_color)
	else:
		label.modulate = Color(255, 255, 255, 255)
