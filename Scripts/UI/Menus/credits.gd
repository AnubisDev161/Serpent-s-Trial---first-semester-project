extends Control

var ui_main

func _ready() -> void:
	ui_main = get_parent()
	


func _on_back_button_pressed() -> void:
	ui_main.pop()

func _input(event: InputEvent) -> void:
	if visible == false:
		return
	if Signal_Bus.is_using_mouse == false:
		var focused_button = get_viewport().gui_get_focus_owner()
		if focused_button == null:
			
			$HBoxContainer/Back_Button.grab_focus()
		if Input.is_action_just_pressed("accept"):
			if focused_button != null:
				focused_button.emit_signal("pressed")
				focused_button.button_pressed = false
