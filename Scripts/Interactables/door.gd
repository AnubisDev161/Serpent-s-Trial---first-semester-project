extends StaticBody2D

@export var is_open = false
@export var switches: Array[Node2D]
@export var levers: Array[Node2D]
@export var Laser_receivers: Array[Node2D]

func _ready() -> void:
	if is_open == true:
		$AnimationPlayer.play("Opened")
	connect_switches_and_levers()

func connect_switches_and_levers():
	for i in switches.size():
		switches[i].connect("pressed", on_switch_pressed)
		switches[i].connect("left", on_switch_left)

	for i in levers.size():
		levers[i].connect("pulled", lever_pulled)
		levers[i].connect("pulled_back", lever_pulled_back)

	for i in Laser_receivers.size():
		Laser_receivers[i].connect("activated", laser_receiver_activated)
		Laser_receivers[i].connect("deactivated", laser_receiver_deactivated)


func change_door_state():
	if is_open == false:
		$AnimationPlayer.play("Open")
		is_open = true
	else:
		$AnimationPlayer.play("Close")
		is_open = false

func on_switch_pressed():
	var all_switches_pressed = true
	# checks whether all switches which are attached to the door are pressed and opens the door in that case
	for i in switches:
		if i.is_pressed != true:
			all_switches_pressed = false
	if all_switches_pressed == true:
		change_door_state()

func on_switch_left():
	var unpressed_switches_count = 0
	for i in switches:
		if i.is_pressed == false:
			unpressed_switches_count += 1
	# makes sure that the first unpressed switch changes the state of the door
	if unpressed_switches_count == 1:
		change_door_state()

func lever_pulled():
	var all_levers_pulled = true
	# checks whether all levers which are attached 
	#to the door are pulled and opens the door in that case
	for i in levers:
		if i.is_pulled != true:
			all_levers_pulled = false
	if all_levers_pulled == true:
		change_door_state()

func lever_pulled_back():
	var unpulled_levers_count = 0
	for i in levers:
		if i.is_pulled== false:
			unpulled_levers_count += 1
	# makes sure that the first unpulled 
	#lever changes the state of the door
	if unpulled_levers_count == 1:
		change_door_state()

func laser_receiver_activated():
	var all_laser_receivers_activated = true
	# checks whether all levers which are attached to the door are pulled and opens the door in that case
	for i in Laser_receivers:
		if i.is_active != true:
			all_laser_receivers_activated = false
	if all_laser_receivers_activated == true:
		change_door_state()

func laser_receiver_deactivated():
	var unactivated_laser_receivers_count = 0
	for i in Laser_receivers:
		if i.is_active == false:
			unactivated_laser_receivers_count += 1
	# makes sure that the first unpulled lever changes the state of the door
	if unactivated_laser_receivers_count == 1:
		change_door_state()

func disable_collider(disable: bool):
	if disable == true:
		$CollisionShape2D.disabled = true
	else:
		$CollisionShape2D.disabled = false
