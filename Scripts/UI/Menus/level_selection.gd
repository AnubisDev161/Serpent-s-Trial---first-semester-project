extends Control

var ui_main
@export var buttons: Array[TextureButton]


func _ready() -> void:
	ui_main = get_parent()
#	update_buttons()
	for i in range(buttons.size()):
		buttons[i].pressed.connect(on_level_button_pressed.bind(i))

func update_buttons():
	for i in range(buttons.size()):
		if i <= Signal_Bus.levels_done:
			buttons[i].disabled = false
			buttons[i].label.visible = true
		else:
			buttons[i].disabled = true
			buttons[i].label.visible = false

func on_level_button_pressed(index: int):
	Signal_Bus.level_load_with_index.emit(index)
	ui_main.pop()

func _on_back_button_pressed() -> void:
	ui_main.pop()

func _input(event: InputEvent) -> void:
	if visible == false:
		return
	if Signal_Bus.is_using_mouse == false:
		var focused_button = get_viewport().gui_get_focus_owner()
		if focused_button == null:
			
			$Back_Button.grab_focus()
		if Input.is_action_just_pressed("accept"):
			if focused_button != null && focused_button.disabled == false:
				focused_button.emit_signal("pressed")
				focused_button.button_pressed = false
