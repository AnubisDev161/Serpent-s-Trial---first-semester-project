class_name Level_Transition extends CanvasLayer

@onready var anim = $AnimationPlayer
@onready var zoom = $Circle_Zoom_Rect

func _ready() -> void:
	zoom.visible = false

func fade_to_black():
	anim.play("fade_to_black")
	await anim.animation_finished

func fade_from_black():
	anim.play("fade_from_black")
	await anim.animation_finished

func circle_zoom(goal_pos):
	zoom.visible = true
	zoom.position = goal_pos - zoom.size/2
	anim.play("circle_zoom")
	await anim.animation_finished

func hide_circle():
	anim.play("RESET")
	zoom.visible = false

func stop_restart_fade_animation():
	if anim.current_animation == "fade_to_black_restart":
		anim.stop()

func fade_to_black_restart():
	if anim.is_playing() == false:
		anim.play("fade_to_black_restart")
		await anim.animation_finished
		anim.play("RESET")

func game_finished():
	$Game_Finished.activate(true)

func text_finished_fade():
	anim.play("thx_text")
	await anim.animation_finished
