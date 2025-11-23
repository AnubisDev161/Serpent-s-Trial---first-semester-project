extends CanvasLayer

@onready var animated_sprite_2d: AnimatedSprite2D = $Control/AnimatedSprite2D

func _ready() -> void:
	$Restart/Timer.start()
	
	#Signal_Bus.connect("game_start",disable )
	Signal_Bus.connect("game_finished", disable)
	Signal_Bus.connect("cutscene_finished",enable)
	Signal_Bus.connect("level_finished", disable)


func update_charges_ui():
	animated_sprite_2d.frame +=1

func set_charges_ui(value):
	animated_sprite_2d.frame = 5 -value
	animated_sprite_2d.frame

func _on_timer_timeout() -> void:
	$Restart.visible = true
	$Restart/AnimationPlayer.play("restart_text_float")

func disable():
	visible = false
	

func enable():
	visible = true
	
