
extends StaticBody2D

@export var ray_length = 300
@export var raycast_active = false
@export var switches: Array[Node2D]
@export var levers: Array[Node2D]
@export var flip_left: bool
@onready var statue_laser: Node2D = $Statue_laser


func _ready() -> void:
	init_raycast()
	if flip_left:
		scale.x = -1
	

func init_raycast():
	
	statue_laser.max_length = ray_length
	connect_switches_and_levers()
	
	if raycast_active == false:
		statue_laser.enable_raycast(false)
		statue_laser.visible = false
		$AnimatedSprite2D.play("asset_statue_unlit")
	else:
		$AnimatedSprite2D.play("asset_statue_lit")

func raycast_enabled():
	
	if raycast_active == false:
		statue_laser.enable_raycast(true)
		statue_laser.visible = true
		raycast_active = true
		$AnimatedSprite2D.play("asset_statue_lit")
	else:
		statue_laser.enable_raycast(false)
		statue_laser.visible = false
		raycast_active = false
		$AnimatedSprite2D.play("asset_statue_unlit")

func on_switch_pressed():
	var all_switches_pressed = true
	# checks whether all switches which are attached 
	#to the raycast are pressed and activates the raycast in that case
	for i in switches:
		if i.is_pressed != true:
			all_switches_pressed = false
	
	if all_switches_pressed == true:
		raycast_enabled()

func on_switch_left():
	var unpressed_switches_count = 0
	for i in switches: 
		if i.is_pressed == false:
			unpressed_switches_count += 1
	# makes sure that the first unpressed switch 
	#changes the state of the raycast
	if unpressed_switches_count == 1:
		raycast_enabled()

func lever_pulled():
	var all_levers_pulled = true
	# checks whether all levers which are attached to
	#the raycast are pulled and activates the raycast in that case
	for i in levers: 
		if i.is_pulled != true:
			all_levers_pulled = false
	
	if all_levers_pulled == true:
		raycast_enabled()

func lever_pulled_back():
	var unpulled_levers_count = 0
	for i in levers: 
		if i.is_pulled== false:
			unpulled_levers_count += 1
	# makes sure that the first unpulled lever 
	#changes the state of the raycast
	if unpulled_levers_count == 1: 
		raycast_enabled()

func connect_switches_and_levers():
	
	for i in switches.size():
		switches[i].connect("pressed", on_switch_pressed)
		switches[i].connect("left", on_switch_left)
	
	for i in levers.size():
		levers[i].connect("pulled", lever_pulled)
		levers[i].connect("pulled_back", lever_pulled_back)
