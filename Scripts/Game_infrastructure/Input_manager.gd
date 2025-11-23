extends Node

func update_mouse_visibility(event: InputEvent) -> void:
	var current_focus_owner = get_viewport().gui_get_focus_owner()
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if current_focus_owner != null:
			current_focus_owner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if current_focus_owner != null:
			current_focus_owner.mouse_filter = Control.MOUSE_FILTER_STOP
		Signal_Bus.is_using_mouse = false
	elif event is InputEventMouseButton or event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Signal_Bus.is_using_mouse = true
	else:
		if Signal_Bus.is_using_mouse == true:
			
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if current_focus_owner != null:
				current_focus_owner.release_focus()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
