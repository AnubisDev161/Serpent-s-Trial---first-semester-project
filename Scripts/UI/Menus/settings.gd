extends Control
@onready var SFX_bus_id = AudioServer.get_bus_index("SFX")
@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var volume_bus_id = AudioServer.get_bus_index("Master")
@onready var sfx_example_sound: AudioStreamPlayer = $SFX_example_sound
var buttons = []
var ui_main

func _ready() -> void:
	ui_main = get_parent()
	set_slider_default_values()
	Signal_Bus.connect("ui_play_sfx_example_sound", play_sfx_example_sound)
	
	buttons.append($HBoxContainer/Volume_Slider)
	buttons.append($HBoxContainer/Sound_Slider)
	buttons.append($HBoxContainer/Music_Slider)
	buttons.append($HBoxContainer/Fullscreen_toggle)

func _on_back_button_pressed() -> void:
	ui_main.pop()
	sfx_example_sound.stop()

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(volume_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(volume_bus_id, value < 0.05)

func _on_sound_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_bus_id, value < 0.05)

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(music_bus_id, value < 0.05)

func set_slider_default_values():
	var volume_default_value = $HBoxContainer/Volume_Slider.value
	AudioServer.set_bus_volume_db(volume_bus_id, linear_to_db(volume_default_value))
	var SFX_default_value = $HBoxContainer/Sound_Slider.value
	AudioServer.set_bus_volume_db(SFX_bus_id, linear_to_db(SFX_default_value))
	var music_default_value = $HBoxContainer/Music_Slider.value
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(music_default_value))

func play_sfx_example_sound(is_playing):
	if is_playing == true:
		sfx_example_sound.play()
	else:
		sfx_example_sound.stop()


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
				if focused_button.has_signal("toggled"):
					focused_button.emit_signal("toggled", !focused_button.button_pressed)
					focused_button.button_pressed = !focused_button.button_pressed
		
func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	
