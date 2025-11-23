extends Node

@export var ui_main : UI_Main
@export var scene_loader : Scene_Loader
@export var level_transition : Level_Transition
@onready var music_and_sfx_manager: Node =$Music_and_sound_manager
@onready var input_manager: Node = $Input_manager
@export var developer_mode = false
enum game_states {MENU, PAUSED, INGAME, CUTSCENE}
var curr_game_state
var curr_scene
# Tooltips:
@export var tooltip_open_time = 0.5

@onready var tooltip_open_timer: Timer = $Tooltip_open_timer


var goal_pos
const SAVE_PATH = "save.cfg"  # Speicherort

func _ready() -> void:
	game_load_save_file()
	assert(ui_main != null)
	assert(scene_loader != null)
	assert(level_transition != null)
	curr_game_state = game_states.MENU
	Signal_Bus.connect("level_reload", level_reload) 
	Signal_Bus.connect("level_restart", level_restart)
	Signal_Bus.connect("level_finished", level_finished) 
	Signal_Bus.connect("level_load_current", level_load_current) 
	Signal_Bus.connect("level_load_with_index", level_load_with_index)
	Signal_Bus.connect("game_start", game_start)
	Signal_Bus.connect("game_resume", game_resume)
	Signal_Bus.connect("game_finished", game_finished)
	Signal_Bus.connect("cutscene_finished", game_resume) 
	Signal_Bus.connect("ui_load_main", ui_load_main)
	Signal_Bus.connect("game_play_credits", game_play_credits)
	#Signal_Bus.connect("player_ui_hide", player_ui_hide)
	#if developer_mode == false:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

#func _process(delta: float) -> void:
	#if curr_game_state == 0:
		#print("Curr State -> MENU")
	#elif curr_game_state == 1:
		#print("Curr State -> PAUSE")
	#elif curr_game_state == 2:
		#print("Curr State -> INGAME")
	#elif curr_game_state == 3 :
		#print("Curr State -> Cutscene")

func _input(event: InputEvent) -> void:
	if curr_game_state != game_states.CUTSCENE:
		if Input.is_action_just_pressed("pause") || (Input.is_action_just_pressed("menu_back_button_controller") && (curr_game_state == game_states.MENU || curr_game_state == game_states.PAUSED)):
			Signal_Bus.emit_signal("ui_play_sfx_example_sound", false)
			if curr_game_state == game_states.INGAME:
				curr_game_state = game_states.PAUSED
				ui_main.TOOLTIPS.hide_tooltip_popup()
				ui_main.TOOLTIPS.visible = false
				if developer_mode == false:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				ui_main.pause_game()
			elif curr_game_state == game_states.PAUSED && ui_main.menu_stack.size() == 1:
				ui_main.unpause_game()
				curr_game_state = game_states.INGAME
				ui_main.TOOLTIPS.visible = true
				print_debug()
			else:
				if ui_main.menu_stack.size() > 1:
					ui_main.pop()
		elif curr_game_state == game_states.INGAME:
			if Input.is_action_just_pressed("restart"):
				if level_transition.anim.is_playing() == false:
					level_restart()
					ui_main.TOOLTIPS.hide_tooltip_popup()
			elif Input.is_action_just_released("restart") :
				level_transition.stop_restart_fade_animation()
				
			elif Input.is_action_just_pressed("help"):
				tooltip_open_timer.start()
				if tooltip_open_timer.time_left > tooltip_open_time && ui_main.TOOLTIPS.tooltip_window_opend == true:
					ui_main.TOOLTIPS.tooltip_window_next()
				
			elif Input.is_action_just_released("help"):
				tooltip_open_timer.stop()
				
		elif curr_game_state == game_states.MENU || curr_game_state == game_states.PAUSED:
			input_manager.update_mouse_visibility(event)

func game_save():
	var config = ConfigFile.new()
	config.set_value("progress", "curr_scene", scene_loader.current_scene_index )
	config.set_value("progress", "levels_done", Signal_Bus.levels_done)
	config.set_value("progress", "tooltips_seen", Signal_Bus.ui_seen_tooltips)
	config.save(SAVE_PATH)
	
func game_load_save_file():
	var config = ConfigFile.new()  
	if config.load(SAVE_PATH) == OK:
		curr_scene = config.get_value("progress", "curr_scene",0)
		scene_loader.current_scene_index = config.get_value("progress", "curr_scene",0)
		Signal_Bus.levels_done = config.get_value("progress", "levels_done",0)
		Signal_Bus.ui_seen_tooltips = config.get_value("progress", "tooltips_seen",0)
		Signal_Bus.ui_show_resume_button.emit()
		print("LOADED SAFE FILE : 
			Curr Scene -> ", curr_scene,"
			Levels Donve -> ", Signal_Bus.levels_done, "
			Tooltips Seen -> ", Signal_Bus.ui_seen_tooltips)

func game_start():
	level_transition.anim.play("RESET")
	scene_loader.current_scene_index = -1
	ui_main.TOOLTIPS.init_tooltips()
	Signal_Bus.levels_done = 0
	Signal_Bus.ui_seen_tooltips = 0
	game_save()
	scene_loader.load_new_scene()
	ui_main.pop()
	ui_main.unpause_game()
	curr_game_state = game_states.CUTSCENE
	Signal_Bus.cutscene_start_opening.emit()
	music_and_sfx_manager.set_current_track(music_and_sfx_manager.tracks.ingame_music)
	ui_main.TOOLTIPS.visible = false
	scene_loader.hide_level_counter(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
func game_resume():
	level_transition.anim.play("RESET")
	curr_game_state = game_states.INGAME
	ui_main.TOOLTIPS.init_tooltips()
	ui_main.TOOLTIPS.visible = true
	scene_loader.hide_level_counter(false)
	music_and_sfx_manager.set_current_track(music_and_sfx_manager.tracks.ingame_music)
	
func game_finished():
	ui_main.TOOLTIPS.visible = false
	scene_loader.hide_level_counter(true)
	level_transition.game_finished()
	curr_game_state = game_states.CUTSCENE
	music_and_sfx_manager.set_current_track(music_and_sfx_manager.tracks.credits_music)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func level_restart():
	if curr_game_state == game_states.PAUSED && ui_main.menu_stack.size() == 1:
		curr_game_state = game_states.INGAME
		print_debug()
	await level_transition.fade_to_black_restart()
	ui_main.unpause_game()
	level_transition.stop_restart_fade_animation()
	scene_loader.restart_current_scene()

func level_reload():
	level_transition.anim.play("RESET")
	get_tree().paused = true
	ui_main.TOOLTIPS.visible = false
	await level_transition.fade_to_black()
	scene_loader.restart_current_scene()
	level_transition.fade_from_black()
	get_tree().paused = false
	ui_main.TOOLTIPS.visible = true

func level_finished(_goal_pos):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ui_main.TOOLTIPS.hide_tooltip_popup()
	ui_main.TOOLTIPS.visible = false
	scene_loader.hide_level_counter(true)
	goal_pos = _goal_pos
	get_tree().paused = true
	curr_game_state = game_states.CUTSCENE
	await level_transition.circle_zoom(goal_pos)
	if scene_loader.current_scene_index > Signal_Bus.levels_done:
		Signal_Bus.levels_done = scene_loader.current_scene_index
		game_save()
	if scene_loader.current_scene_index == scene_loader.Scenes.size() -1:
		scene_loader.reached_last_lvl = true
	if !scene_loader.reached_last_lvl:
		scene_loader.load_new_scene()
		await  get_tree().create_timer(0.1).timeout
		ui_main.SELECTION.update_buttons()
		get_tree().paused = false
		level_transition.hide_circle()
		Signal_Bus.cutscene_start_opening.emit()
		await level_transition.fade_from_black()
	else:
		scene_loader.load_new_scene()
		level_transition.anim.play("RESET")
		game_finished()

func level_load_current():
	level_transition.anim.play("RESET")
	if scene_loader.current_scene_index == -1:
		scene_loader.current_scene_index = 0
	scene_loader.load_scene_with_index(scene_loader.current_scene_index)
	curr_game_state = game_states.INGAME
	print_debug()
	ui_main.pop()
	ui_main.unpause_game()
	level_transition.fade_from_black()

func level_load_with_index(index):
	level_transition.anim.play("RESET")
	scene_loader.load_scene_with_index(index)
	curr_game_state = game_states.INGAME
	print_debug()
	ui_main.pop()
	ui_main.unpause_game()
	level_transition.fade_from_black()

func ui_load_main():
	ui_main.visible = true
	level_transition.anim.play("RESET")
	music_and_sfx_manager.set_current_track(music_and_sfx_manager.tracks.main_theme)
	curr_scene = scene_loader.current_scene_index
	Signal_Bus.ui_show_resume_button.emit()
	ui_main.TOOLTIPS.visible = false
	ui_main.pop()
	ui_main.push(ui_main.MAIN)
	scene_loader.remove_old_scene()
	scene_loader.hide_level_counter(true)
	curr_game_state = game_states.MENU
	

func game_play_credits():
	game_finished()


func _on_tooltip_open_timer_timeout() -> void:
	if ui_main.TOOLTIPS.tooltip_window_opend:
		Signal_Bus.ui_hide_tooltip_popup.emit()
		ui_main.TOOLTIPS.tooltip_window_opend = false
	else:
		ui_main.TOOLTIPS.open_tooltip_window()
