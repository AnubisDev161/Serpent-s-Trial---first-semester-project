extends Control
var buttons = []
var ui_main

#signal go_to_menu

func _ready() -> void:
	ui_main = get_parent()
	
	buttons.append($VBoxContainer/Resume_Button)
	buttons.append($VBoxContainer/Restart_Button)
	buttons.append($VBoxContainer/Settings_Button)
	buttons.append($VBoxContainer/Main_Menu_Button)
func _on_resume_button_pressed() -> void:
	ui_main.unpause_game()

func _on_settings_button_pressed() -> void:
	ui_main.push(ui_main.SETTINGS)
	Signal_Bus.emit_signal("ui_play_sfx_example_sound", true)

func _on_main_menu_button_pressed() -> void:
	ui_main.pop()
	ui_main.push(ui_main.MAIN)
	Signal_Bus.ui_load_main.emit()

func _on_restart_button_pressed() -> void:
	Signal_Bus.level_restart.emit()

func _input(event: InputEvent) -> void:
	if visible != true:
		return
	if Signal_Bus.is_using_mouse == false:
		var focused_button = get_viewport().gui_get_focus_owner()
		if  focused_button == null:
			buttons[0].grab_focus()
		if Input.is_action_just_pressed("accept"):
			if focused_button != null:
				focused_button.emit_signal("pressed")
