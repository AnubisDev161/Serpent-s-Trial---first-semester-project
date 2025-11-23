extends Node
#Music
var main_theme = load("res://Assets/Sounds/Music/Medusa Soundtrack Main Theme Action.mp3")
var credits_music = load("res://Assets/Sounds/Music/Medusa Soundtrack Full.mp3")
var ingame_music = load("res://Assets/Sounds/Music/Medusa Soundtrack Gameplay Track.mp3")
@onready var music_stream_player: AudioStreamPlayer = $Music_stream_player

@onready var Music_and_SFX_animation_player: AnimationPlayer = $Music_and_SFX_animation_player
#SFX
@onready var sfx_stream_player: AudioStreamPlayer = $SFX_stream_player
var player_died_sfx = load("res://Assets/Sounds/SFX/Death Sound.wav")


enum tracks{
	main_theme,
	credits_music,
	ingame_music
}

@export var current_track: tracks

func _ready() -> void:
	set_current_track(current_track)
	Signal_Bus.connect("music_and_sound_manager_play_player_died_sfx", play_player_died_sfx)

func set_current_track(new_track):
	if new_track == current_track && music_stream_player.playing == true:
		return
	if music_stream_player.playing == true:
		Music_and_SFX_animation_player.play("Fade_out")
		
		await Music_and_SFX_animation_player.animation_finished
		current_track = new_track
		Music_and_SFX_animation_player.play("RESET")
		update_current_track()
	else:
		Music_and_SFX_animation_player.play("RESET")
		current_track = new_track
		update_current_track()

func update_current_track():
	if current_track == tracks.main_theme:
		music_stream_player.stream = main_theme
		
	elif current_track == tracks.credits_music:
		music_stream_player.stream  = credits_music
		
	else:
		music_stream_player.stream  = ingame_music
	if sfx_stream_player.playing == true:
		sfx_stream_player.stop()
	music_stream_player.play()

func play_player_died_sfx():
	sfx_stream_player.stream = player_died_sfx
	sfx_stream_player.play()
