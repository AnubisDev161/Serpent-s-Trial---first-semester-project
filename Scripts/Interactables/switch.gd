extends Area2D

var old_color
signal pressed
signal left
var detected_objects = []
var is_pressed = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _on_body_entered(body: Node2D) -> void:
	if (body.has_method("petrify") && body.is_petrified )|| body.has_method("_move"):
		if detected_objects == []:
			is_pressed = true
			emit_signal("pressed")
			animation_player.play("Pressed")
		add_or_remove_detected_object(body, true)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("petrify") || body.has_method("_move"):
		add_or_remove_detected_object(body, false)
		if detected_objects == []:
			is_pressed = false
			animation_player.play("Released")
			emit_signal("left")

func add_or_remove_detected_object(body, add_object:bool):
	if add_object == true:
		detected_objects.append(body)
	else:
		detected_objects.resize(detected_objects.size() -1)
		var x = detected_objects.size()
