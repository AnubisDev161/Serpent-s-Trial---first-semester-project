class_name SignalBus extends Node

var levels_done = -1
var is_using_mouse = true
var ui_seen_tooltips = 0

signal cutscene_finished
signal cutscene_start_opening
signal level_reload
signal level_restart
signal level_finished(goal_pos)
signal level_load_next
signal level_load_with_index(index)
signal level_load_current
signal game_start
signal game_resume
signal game_finished
signal ui_load_main
signal ui_show_resume_button
signal ui_play_sfx_example_sound(value)
signal ui_open_tooltip_window
signal ui_show_tooltip_popup(index)
signal ui_hide_tooltip_popup
signal music_and_sound_manager_play_player_died_sfx
signal game_play_credits
signal player_ui_disable(value)
