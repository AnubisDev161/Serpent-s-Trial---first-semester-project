extends Node2D

var lasers = []
var max_cast_to = Vector2.ZERO
var reflectors = []
var active = true
@onready var laser: RayCast2D = $Laser
@onready var line: Line2D = $Line2D
@export var current_length = 0
@export var max_length = 550
@export var start_length = 50
@onready var end: CPUParticles2D = $End
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var laser_default_color: Color
@export var laser_hit_color: Color
@export var emitter: Node2D
var target = null
var shooting = false
@export var acceleration = 1
signal shot_performed

func enable_raycast(enable):
	if enable == true:
		active = true
		visible = true
		laser.enabled = true
		animation_player.play("Laser_build_up")
	else:
		active = false
		visible = false
		laser.enabled = false

func _ready() -> void:
	if active == false:
		return
	laser.add_exception(emitter)
	lasers.append(laser)
	
	laser.target_position = max_cast_to
	line.top_level = true
	

func _process(delta: float) -> void:
	if active == false:
		return
	update_first_raycast(delta)
	var index = -1
	for raycast in lasers:
		index += 1
		var raycast_collsion = raycast.get_collision_point()
		raycast.target_position = max_cast_to
		
		if raycast.is_colliding():
			line.add_point(raycast_collsion)
			var collider = raycast.get_collider()
			
			if collider.has_method("_reflector_detected"):
				collision_with_reflector(index, raycast,collider, raycast_collsion)
			else: # if not colliding with reflector
				collision_with_other_objects(index, raycast_collsion, collider)
		else: # else if not colliding at all
			no_collision(index, raycast)

func _create_raycast():
	var raycast = laser.duplicate()
	raycast.enabled = true
	raycast.add_exception(emitter)
	add_child(raycast)
	lasers.append(raycast)

func remove_raycast(laser_array_index):
	for i in range(lasers.size() - 1, laser_array_index, -1):
		lasers[i].queue_free()
	lasers.resize(laser_array_index +1)
	reflectors.resize(laser_array_index )

func no_collision(index, raycast):
	line.default_color = laser_default_color
	line.add_point(raycast.global_position + max_cast_to)
	if index < lasers.size() -1: # checks whether there are more elements in the lasers array with a higher index than the ray which lost connection to a reflector
		remove_raycast(index) # removes the rays with a higher index in the lasers array
	if index == 0:
		raycast.target_position = max_cast_to
		end.global_position = global_position + max_cast_to
	else:
		end.global_position = raycast.global_position + max_cast_to # sets the global position of the end particles to the tip of the raycast

func collision_with_other_objects(index, raycast_collsion, collider):
	#?
	# checks whether there are more elements in the lasers array with a higher index than the ray which lost connection to a reflector
	if index < lasers.size() -1: 
		remove_raycast(index) # removes the rays with a higher index in the lasers array
	
	if index == lasers.size() -1: # sets the end particles to the collsiion position of the last racast
		end.global_position = raycast_collsion
		
	#This is where you should check for a collision with player/enemy
	line.default_color = laser_default_color
	if collider.has_method("is_looking_at_player"):
		target = collider
		if collider.is_looking_at_player(raycast_collsion) == true && collider.is_petrified == false:
			line.default_color = laser_hit_color
			if shooting == true:
				
				collider.petrify(raycast_collsion)
	else:
		target = null
func collision_with_reflector(index, raycast, collider, raycast_collsion):
	if reflectors == []:# if the the raycast first intersects with a reflector, it will create the first bounced raycast
		reflectors.append(collider)
		_create_raycast()
	else:
		for i in reflectors.size() :# checks whether the ray has intersected with a reflector that hasn't been hit bofore
			if reflectors[i] == collider:
				break
			elif i == reflectors.size() -1:
				reflectors.append(collider)
				_create_raycast()
	max_cast_to = max_cast_to.bounce(raycast.get_collision_normal())
	if max_cast_to.length() > max_length: # this checks whether the distance between the origin kof the raycast and the marker2D is greater than the max_length of the laser
		var length_above_max_length = max_cast_to.length() - max_length # if this is the case, the raycast will be shorten to it's maximum length
		max_cast_to = max_cast_to - max_cast_to.normalized() * length_above_max_length
	if index < lasers.size() -1:
		lasers[index +1].enabled = true
		lasers[index +1].global_position = raycast_collsion + max_cast_to.normalized()
#?
# Is called in the _process func
func update_first_raycast(_delta):
	line.clear_points()
	line.add_point(global_position)
	if current_length > max_length:
		current_length = max_length
		
	max_cast_to = (get_global_mouse_position() - global_position).normalized() * current_length
	
func shoot(value):
	if value == true:
		shooting = true
		animation_player.play("Laser_shoot")
	else:
		shooting = false
		animation_player.stop()

func start_charge_timer():
	enable_raycast(true)

func shoot_time_over():
	shoot(false)
	#enable_raycast(false)
	emit_signal("shot_performed")

func _on_player_shoot() -> void:
	shoot(true)
