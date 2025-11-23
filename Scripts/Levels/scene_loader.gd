class_name Scene_Loader extends Node

@export var Scenes: Array[PackedScene]
@onready var current_scene
var current_scene_index: int = -1
var reached_last_lvl = false
@onready var level_counter: Label = $CanvasLayer/Level_counter

signal start_new_level_cam_ride

func _ready() -> void:
	pass
	#hide_level_counter(true)

#-----------WIP------------------
func load_scene_with_index(index):
	current_scene_index = index
	restart_current_scene()

func load_new_scene():
	if current_scene_index < Scenes.size() -1:
		current_scene_index += 1
	elif reached_last_lvl:
		Signal_Bus.game_finished.emit()
		remove_old_scene()
		reached_last_lvl = false
		return
	restart_current_scene()

func restart_current_scene():
	var new_scene = Scenes[current_scene_index].instantiate()
	remove_old_scene()
	call_deferred("add_child", new_scene)
	Signal_Bus.connect("cutscene_start_opening", new_scene.start_opening)
	# sonst geht reset nicht wenn für lvl noch kein opening gemacht wurd
	if new_scene.opening == null:
		Signal_Bus.cutscene_finished.emit()
	current_scene = new_scene
	set_level_counter(current_scene_index +1)

func remove_old_scene():
	if current_scene != null:
		current_scene.queue_free()

func set_level_counter(current_level_index: int):
	level_counter.text = "Level " +str(current_level_index)
	#hide_level_counter(false)

func hide_level_counter(hide):
	if hide == true:
		level_counter.visible = false
	else:
		level_counter.visible = true
