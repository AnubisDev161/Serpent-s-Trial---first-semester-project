@tool
extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	zoom_changed()
	_on_item_rect_changed()


	
func zoom_changed():
	material.set_shader_parameter("y_zom",get_viewport_transform().get_scale().y)
	material.set("y_zom", get_viewport().global_canvas_transform.y)


func _on_item_rect_changed() -> void:
	material.set("scale", scale)
