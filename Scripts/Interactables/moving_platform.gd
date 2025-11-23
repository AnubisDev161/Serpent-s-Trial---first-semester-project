
extends AnimatableBody2D

@export var path_follow: PathFollow2D
@export var active = false
@export var switches: Array[Node2D]
@export var levers: Array[Node2D]
@export var travel_time = 3.0
@export var always_to_end = false
var travelling_backwards = false
var current_tween = null

func _ready() -> void:
	connect_switches_and_levers()

func moving_platform_enabled():
	if active == false:
		active = true
	else:
		active = false
		if always_to_end == true:
			return
		current_tween.kill()
		current_tween = null

func on_switch_pressed():
	var all_switches_pressed = true
	for i in switches: # checks whether all switches which are attached to the raycast are pressed and opens the raycast in that case
		if i.is_pressed != true:
			all_switches_pressed = false
	
	if all_switches_pressed == true:
		moving_platform_enabled()

func on_switch_left():
	var unpressed_switches_count = 0
	for i in switches: 
		if i.is_pressed == false:
			unpressed_switches_count += 1
	if unpressed_switches_count == 1: # makes sure that the first unpressed switch changes the state of the moving platform
		moving_platform_enabled()
	
func lever_pulled():
	var all_levers_pulled = true
	for i in levers: # checks whether all levers which are attached to the moving platform are pulled and activate's it in that case
		if i.is_pulled != true:
			all_levers_pulled = false
	
	if all_levers_pulled == true:
		moving_platform_enabled()

func lever_pulled_back():
	var unpulled_levers_count = 0
	for i in levers: 
		if i.is_pulled== false:
			unpulled_levers_count += 1
	if unpulled_levers_count == 1: # makes sure that the first unpulled lever changes the state of the moving platform
		moving_platform_enabled()

func connect_switches_and_levers():
	
	for i in switches.size():
		switches[i].connect("pressed", on_switch_pressed)
		switches[i].connect("left", on_switch_left)
	
	for i in levers.size():
		levers[i].connect("pulled", lever_pulled)
		levers[i].connect("pulled_back", lever_pulled_back)

func update_travel_direction(_delta):
	# ?
	# if the platform has travelled the whole progress ratio of the follow path2D,
	# the platfrorm will turn around either if it reaches 1 or 0 progress ratio
	if path_follow.progress_ratio >= 1 && travelling_backwards == false:
		travelling_backwards = true
		current_tween = create_tween()
		current_tween.tween_property(path_follow, "progress_ratio", 0, travel_time)
		return
		
	elif path_follow.progress_ratio <= 0:
		travelling_backwards = false
		current_tween = create_tween()
		current_tween.tween_property(path_follow, "progress_ratio", 1, travel_time)
		return
	
	#?
	# if the platform is stopped before it reaches a progress ratio of either 1 or 2,
	# the platform will create a new tween which subtracts its current progress ratio
	# from the defined travel time
	# This code will only be processed if always_to_end == false
	if current_tween == null && travelling_backwards == true:
		current_tween = create_tween()
		current_tween.tween_property(path_follow, "progress_ratio", 0, travel_time *path_follow.progress_ratio)
		
	elif current_tween == null && travelling_backwards == false:
		current_tween = create_tween()
		current_tween.tween_property(path_follow, "progress_ratio", 1, travel_time - travel_time*path_follow.progress_ratio)

func _process(delta: float) -> void:
	if active == false || path_follow == null:
		return
	update_travel_direction(delta)
