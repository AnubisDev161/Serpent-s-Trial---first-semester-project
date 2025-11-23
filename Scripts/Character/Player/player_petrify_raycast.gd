
extends Node2D

var lasers = []
var max_cast_to = Vector2.ZERO
var reflectors = []
var active = true
var shooting = false
@onready var laser: RayCast2D = $Laser
@onready var line: Line2D = $Line2D
var target_direction = 0.0
@export var max_length = 550
signal shot_performed

@onready var end: CPUParticles2D = $End
@export var emitter: Node2D
@export var raycast_target: Marker2D
@export var target_type: targets
@export var max_laser_charge_time: float = 3.0
var current_charge_time = 0.0
@onready var shoot_time: Timer = $Shoot_time


enum targets{
	mouse, marker2D
}

func enable_raycast(enable):
	if enable == true:
		active = true
		visible = true
	else:
		active = false
		visible = false
		current_charge_time = 0.0
		shoot(false)

func _ready() -> void:
	if active == false:
		return
	laser.add_exception(emitter)
	lasers.append(laser)
	
	
	#max_cast_to = Vector2(max_length, 0.0).rotated(target_direction)
	max_cast_to = Vector2(max_length/max_laser_charge_time * (current_charge_time), 0.0).rotated(target_direction)
	laser.target_position = max_cast_to
	
	line.top_level = true
	
func _process(delta: float) -> void:
	if active == false:
		return
	current_charge_time += delta
	if current_charge_time > max_laser_charge_time:
		current_charge_time = max_laser_charge_time
	if target_type == targets.mouse:
		target_direction = get_local_mouse_position().angle()
	else:
		target_direction = raycast_target.position.angle()
		
	if shooting == false:
		line.default_color.a = 0.4
	else:
		line.default_color.a = 1.0
	line.clear_points()
	
	line.add_point(global_position)
	#max_cast_to = Vector2(max_length , 0.0).rotated(target_direction)
	max_cast_to = Vector2(max_length/max_laser_charge_time * (current_charge_time), 0.0).rotated(target_direction)
	
	var index = -1
	for raycast in lasers:
		
		index += 1
		var raycast_collsion = raycast.get_collision_point()
		
		raycast.target_position = max_cast_to
		
		if raycast.is_colliding():
			
			line.add_point(raycast_collsion)
			
			var collider = raycast.get_collider()
			
			if collider.has_method("_reflector_detected"):
				handle_collision_with_reflectors(index, raycast, raycast_collsion, collider)
				
			else: # if not colliding with reflector
				handle_collision_with_other_objects(index, raycast_collsion, collider)
			
		else: # else if not colliding at all
			handle_no_collision(index, raycast)

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

func handle_collision_with_reflectors(index, raycast, raycast_collsion, collider):
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

	if collider.reflect_to_marker2D == true: # if the raycast has no target assigned to, the raycast will bounce on the collsion normal.
		max_cast_to = collider.reflection_direction
	else:
		max_cast_to = max_cast_to.bounce(raycast.get_collision_normal())

	if max_cast_to.length() > max_length: # this checks whether the distance between the origin of the raycast and the marker2D is greater than the max_length of the laser
		var length_above_max_length = max_cast_to.length() - max_length # if this is the case, the raycast will be shorten to it's maximum length
		max_cast_to = max_cast_to - max_cast_to.normalized() * length_above_max_length

	if index < lasers.size() -1:
		lasers[index +1].enabled = true
		lasers[index +1].global_position = raycast_collsion + max_cast_to.normalized()
	

func handle_collision_with_other_objects(index, raycast_collsion, collider):
	if index < lasers.size() -1: # checks whether there are more elements in the lasers array with a higher index than the ray which lost connection to a reflector
		remove_raycast(index) # removes the rays with a higher index in the lasers array
		
	if index == lasers.size() -1: # sets the end particles to the collsiion position of the last racast
		end.global_position = raycast_collsion

	# this is where you should check for a collsision with an enemy
	if collider.has_method("petrify") && shooting == true:
		collider.petrify()
	

func handle_no_collision(index, raycast):
	line.add_point(raycast.global_position + max_cast_to)
	
	if index < lasers.size() -1: # checks whether there are more elements in the lasers array with a higher index than the ray which lost connection to a reflector
		remove_raycast(index) # removes the rays with a higher index in the lasers array
	
	if index == 0:
		raycast.target_position = max_cast_to
		end.global_position = global_position + max_cast_to
	else:
		end.global_position = raycast.global_position + max_cast_to # sets the global position of the end particles to the tip of the raycast

func shoot(value):
	if value == true:
		shooting = true
		#charge_timer.stop()
		shoot_time.start()
	else:
		shooting = false

func start_charge_timer():
	#charge_timer.start(laser_charge_time)
	enable_raycast(true)

func _on_player_v_2_laser_shoot() -> void:
	shoot(true)

func _on_shoot_time_timeout() -> void:
	shoot(false)
	enable_raycast(false)
	emit_signal("shot_performed")
