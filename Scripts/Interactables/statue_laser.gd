extends Node2D

var max_cast_to = Vector2(0.0, 0.0)
var active = true
@onready var laser: RayCast2D = $Laser
@onready var line: Line2D = $Line2D
@export var max_length: int = 550
@onready var end: CPUParticles2D = $End
@export var emitter: Node2D
var lasers = []
var reflectors = []

var laser_receiver = null

func enable_raycast(enable):
	if enable == true:
		active = true
		laser.enabled = true
	else:
		
		active = false
		laser.enabled = false

func _ready() -> void:
	
	if active == false:
		return
	if emitter != null:
		max_length = emitter.ray_length
	$AnimationPlayer.play("Laser_shooting")
	laser.add_exception(emitter)
	line.top_level = true
	lasers.append(laser)

func _process(delta: float) -> void:
	if active == false:
		return
	
	update_first_raycast()
	var index = -1
	for raycast in lasers:
		index += 1
		raycast.target_position =  max_cast_to
		if raycast.is_colliding(): 
			var collider = raycast.get_collider()
			var raycast_collsion = raycast.get_collision_point()
			
			collision(index, raycast, raycast_collsion, collider)
		else: # else if not colliding at all
			no_collision(index, raycast)
	

func no_collision(index, raycast):
	if index < lasers.size() -1: # checks whether there are more elements in the lasers array with a higher index than the ray which lost connection to a reflector
		remove_bounced_raycast(index) # removes the rays with a higher index in the lasers array
	
	if index == 0:
		raycast.target_position = max_cast_to
	line.add_point(to_global(raycast.target_position))
	
	# sets the end particles to the collsiion position of the last racast
	set_end_particles_position(index, to_global(raycast.target_position), raycast)

func collision(index, raycast, raycast_collsion, collider):
	line.add_point(raycast_collsion)
	if index < lasers.size() -1: 
		remove_bounced_raycast(index) # removes the rays with a higher index in the lasers array
	
	if collider.has_method("is_player"):
		collider.update_health(-1)
	
	# sets the end particles to the collsiion position of the last racast
	set_end_particles_position(index, raycast_collsion, raycast)

func collision_with_reflector(index, raycast, raycast_collsion, collider):
	if reflectors == []:# if the the raycast first intersects with a reflector, it will create the first bounced raycast
		reflectors.append(collider)
		_create_bounced_raycast()
	else:
		for i in reflectors.size() :# checks whether the ray has intersected with a reflector that hasn't been hit bofore
			if reflectors[i] == collider:
				break
			elif i == reflectors.size() -1:
				reflectors.append(collider)
				_create_bounced_raycast()
	if index < lasers.size() -1:
		lasers[index +1].global_position = raycast_collsion #+ max_cast_to.normalized()
	max_cast_to = max_cast_to.bounce(raycast.get_collision_normal())

func update_first_raycast():
	if emitter != null:
		max_cast_to = Vector2(max_length, 0.0)
		
	#max_cast_to = transform.x
	line.clear_points()
	line.add_point(global_position)

func _create_bounced_raycast():
	var raycast = laser.duplicate()
	raycast.enabled = true
	raycast.add_exception(emitter)
	add_child(raycast)
	lasers.append(raycast)

func remove_bounced_raycast(laser_array_index):
	for i in range(lasers.size() - 1, laser_array_index, -1):
		lasers[i].queue_free()
	lasers.resize(laser_array_index +1)
	reflectors.resize(laser_array_index )

func set_end_particles_position(index, new_position, raycast):
	if index == lasers.size() -1: # sets the end particles to the collsiion position of the last racast
		end.global_position = new_position

#func update_laser_receiver():
	#if laser_receiver != null:
		#laser_receiver.change_receiver_state()
		#laser_receiver = null
