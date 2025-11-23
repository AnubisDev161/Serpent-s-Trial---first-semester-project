extends Control

var ui_main
var buttons = []
@onready var selector: Sprite2D =$Buttons/Selector


func _ready() -> void:
	ui_main = get_parent()
	Signal_Bus.connect("ui_show_resume_button", show_resume_button)
	
	buttons.append($Buttons/Resume_Button)
	buttons.append($Buttons/New_Game_Button)
	buttons.append($Buttons/Credits_Button)
	buttons.append($Buttons/Settings_Button)
	buttons.append($Buttons/Quit_Button)

func _input(event: InputEvent) -> void:
	if visible != true:
		return
	
	if Signal_Bus.is_using_mouse == false:
		var focused_button = null
		focused_button = get_viewport().gui_get_focus_owner()
		if  focused_button == null:
			if buttons[0].visible == true:
				buttons[0].grab_focus()
			else:
				buttons[1].grab_focus()
				focused_button = buttons[1]
		
		if Input.is_action_just_pressed("accept"):
			if focused_button != null:
				focused_button.emit_signal("pressed")

func show_resume_button():
	$Buttons/Resume_Button.visible = true

func _on_resume_button_pressed() -> void:
	Signal_Bus.level_load_current.emit()

func _on_play_button_pressed() -> void:
	Signal_Bus.game_start.emit()

func _on_settings_button_pressed() -> void:
	ui_main.push(ui_main.SETTINGS)
	Signal_Bus.emit_signal("ui_play_sfx_example_sound", true)

func _on_levels_button_pressed() -> void:
	ui_main.SELECTION.update_buttons()
	ui_main.push(ui_main.SELECTION)

func _on_credits_button_pressed() -> void:
	ui_main.push(ui_main.CREDITS)
	ui_main.visible = false
	Signal_Bus.emit_signal("game_play_credits")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
