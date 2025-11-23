
extends StaticBody2D
@export var angle_change = 0.0
var old_rotation = 0.0
@export var switches: Array[Node2D]
@export var levers: Array[Node2D]
@export var is_turned = false
@onready var particledust: GPUParticles2D = $Node/ParticleDust
var particledust_original_transform
func _reflector_detected():
	pass

func _ready() -> void:
	connect_switches_and_levers()
	old_rotation = rotation


func connect_switches_and_levers():
	for i in switches.size():
		switches[i].connect("pressed", on_switch_pressed)
		switches[i].connect("left", on_switch_left)
	
	for i in levers.size():
		levers[i].connect("pulled", lever_pulled)
		levers[i].connect("pulled_back", lever_pulled_back)

func turn_reflector():
	if is_turned == false:
		rotation = deg_to_rad(angle_change)
		is_turned = true
	else:
		is_turned = false
		rotation = old_rotation
	$AudioStreamPlayer2D.play()
	particledust.global_position = global_position + Vector2(0, -40)
	# *for particle instant respawn use this*
	#particledust.restart()
	particledust.emitting = true
	# *when not using oneshot use this instead*
	#await get_tree().create_timer(1.5).timeout
	#particledust.emitting = false


func on_switch_pressed():
	var all_switches_pressed = true
	# checks whether all switches which are attached to the door are pressed and opens the door in that case
	for i in switches: 
		if i.is_pressed != true:
			all_switches_pressed = false
	if all_switches_pressed == true:
		turn_reflector()

func on_switch_left():
	var unpressed_switches_count = 0
	for i in switches: 
		if i.is_pressed == false:
			unpressed_switches_count += 1
	# makes sure that the first unpressed switch changes the state of the door
	if unpressed_switches_count == 1: 
		turn_reflector()

func lever_pulled():
	var all_levers_pulled = true
	# checks whether all levers which are attached to the door are pulled and opens the door in that case
	for i in levers: 
		if i.is_pulled != true:
			all_levers_pulled = false
	if all_levers_pulled == true:
		turn_reflector()

func lever_pulled_back():
	var unpulled_levers_count = 0
	for i in levers: 
		if i.is_pulled== false:
			unpulled_levers_count += 1
	# makes sure that the first unpulled lever changes the state of the door
	if unpulled_levers_count == 1: 
		turn_reflector()
