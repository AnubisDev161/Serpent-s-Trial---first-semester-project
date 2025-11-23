extends Node2D
@export var max_target_pos = 15000
@export var scroll_speed: float = 200.0
var is_playing = false

func _ready() -> void:
	activate(false)

func _process(delta: float) -> void:
	if is_playing:
		$Finish_Cam.position.x += scroll_speed * delta
	if $Finish_Cam.position.x >= max_target_pos && is_playing:
		is_playing = false
		await $"..".fade_to_black()
		Signal_Bus.ui_load_main.emit()
		activate(false)

func activate(value):
	if value == true:
		is_playing = true
		$"Parallax/Background Relief".visible = true
		$"Parallax/Foreground Vines Back".visible = true
		$Finish_Cam.enabled = true
		$Control.visible = true
	else: 
		is_playing = false
		$Finish_Cam.position.x = 0
		$"Parallax/Background Relief".visible = false
		$"Parallax/Foreground Vines Back".visible = false
		$Finish_Cam.enabled = false
		$Control.visible = false
