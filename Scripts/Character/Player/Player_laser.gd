extends Node2D

var lasers = []
var spark_emitters = []
var max_cast_to = Vector2.ZERO
var reflectors = []
var active = true
var time = 0.0
var dotted_line_texture = load("res://Assets/Sprites/VFX/texture_vfx_laser_dotted_line_v2.png")
var laser_line_texture = load("res://Assets/Sprites/VFX/texture_vfx_laser_line_v3.png")
@onready var laser: RayCast2D = $Laser
@onready var line: Line2D = $Line2D
@export var current_length: int
@export var max_length = 550
@export var start_length = 50
@onready var end: GPUParticles2D =$End_particles
@onready var spark_particles: GPUParticles2D = $Spark_particles
@onready var casting_particles: GPUParticles2D = $Casting_particles
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var laser_aime_color: Color 
@export var laser_detected_color: Color #color that indicates that an enemy is hit at it's front in the pre aime state
@export var laser_hit_color: Color
var current_direction = 1
var last_mouse_position = Vector2.ZERO
@export var mouse_speed = 1000
#@export var precise_aime_speed = 100
@export var mouse_aime_distance = 300
@export var emitter: Node2D
@export var particles_amount_per_100px = 100
var target = null
var shooting = false
@export var acceleration = 1
signal shot_performed

@export var joystick_precise_rotation_speed = 0.05
var local_joystick_ray_direction

func enable_raycast(enable):
	if enable == true:
		active = true
		visible = true
		laser.enabled = true
		animation_player.play("Idle_laser")
	else:
		active = false
		visible = false
		laser.enabled = false
		end.emitting = false

func _ready() -> void:
	enable_raycast(true)
	if active == false:
		return
	laser.add_exception(emitter)
	lasers.append(laser)
	spark_emitters.append(spark_particles)
	laser.target_position = max_cast_to
	line.top_level = true

func _process(delta: float) -> void:
	if active == false:
		return
	update_first_raycast(delta)
	
	target = null
	
	var index = -1
	for raycast in lasers:
		index += 1
		var raycast_collsion = raycast.get_collision_point()
		raycast.target_position = max_cast_to
		
		if raycast.is_colliding():
			handle_collision(raycast_collsion, raycast, index);
		else: # else if not colliding at all
			no_collision(index, raycast)
		update_spark_particles(index, raycast, raycast.is_colliding())

func handle_collision(raycast_collision, raycast, index):
	line.add_point(raycast_collision)
	var collider = raycast.get_collider()
	end.global_rotation = (raycast.get_collision_normal().angle())
	
	if collider.has_method("_reflector_detected"):
		collision_with_reflector(index, raycast,collider, raycast_collision)
		
	else: # if not colliding with reflector
		collision_with_other_objects(index, raycast, raycast_collision, collider)

func _create_bounced_raycast():
	var raycast = laser.duplicate()
	raycast.enabled = true
	raycast.add_exception(emitter)
	add_child(raycast)
	lasers.append(raycast)
	var new_spark_particles = spark_particles.duplicate() 
	spark_emitters.append(new_spark_particles)
	add_child(new_spark_particles)

func remove_bounced_raycast(laser_array_index):
	for i in range(lasers.size() - 1, laser_array_index, -1):
		lasers[i].queue_free()
		spark_emitters[i].queue_free()
	lasers.resize(laser_array_index +1)
	spark_emitters.resize(laser_array_index +1)
	reflectors.resize(laser_array_index )

func no_collision(index, raycast):
	line.add_point(raycast.global_position + max_cast_to)
	update_color()
	
	if index < lasers.size() -1: # checks whether there are more elements in the lasers array with a higher index than the ray which lost connection to a reflector
		remove_bounced_raycast(index) # removes the rays with a higher index in the lasers array
	if index == 0:
		raycast.target_position = max_cast_to
		end.global_position = global_position + max_cast_to
	else:
		end.global_position = raycast.global_position + max_cast_to # sets the global position of the end particles to the tip of the raycast

func collision_with_other_objects(index, raycast, raycast_collsion, collider):
	#?
	# checks whether there are more elements in the lasers array with a higher index than the ray which lost connection to a reflector
	if index < lasers.size() -1: 
		remove_bounced_raycast(index) # removes the rays with a higher index in the lasers array
		
	if index == lasers.size() -1: # sets the end particles to the collsiion position of the last racast
		
		end.global_position = raycast_collsion
	#This is where you should check for a collision with player/enemy
	update_color()
	if collider.has_method("is_looking_at_player"):
		target = collider
		if shooting == true:
			var x = 45
		if collider.is_looking_at_player(raycast_collsion) == true && collider.is_petrified == false:
			
			line.default_color = laser_detected_color
			if shooting == true:
				collider.petrify(raycast_collsion)

func collision_with_reflector(index, raycast, collider, raycast_collsion):
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
	var target_direction = Vector2.ZERO
	if get_controller_input(_delta):
		target_direction = get_controller_input(_delta)
		
	last_mouse_position = get_viewport().get_mouse_position()
	target_direction =  (get_global_mouse_position() - global_position).normalized() 
	var player_position = emitter.global_position
	update_current_direction(player_position, target_direction)
	
	max_cast_to = target_direction * current_length
	
func shoot(value):
	if value == true:
		shooting = true
		if animation_player.current_animation != "Laser_shoot":
			end.emitting = true
			animation_player.play("Laser_shoot")
	else:
		shooting = false
		animation_player.play("Idle_laser")

func shoot_time_over():
	shoot(false)
	emit_signal("shot_performed")

func _on_player_shoot() -> void:
	shoot(true)
	
func update_color():
	if shooting == true:
		line.texture = laser_line_texture
		line.default_color = laser_hit_color
		
	else:
		line.default_color = laser_aime_color
		line.texture = dotted_line_texture

func get_controller_input (_delta):
	var joy_direction = Input.get_vector("aim_x_left","aim_x_right","aim_y_up","aim_y_down").normalized()
	
	if joy_direction != Vector2.ZERO:
		update_viewport_mouse_position(_delta, joy_direction)
	else:
		copy_joystick_direction_from_mouse_pos()
	
func get_mouse_input () -> Vector2:
	var mouse_direction = (get_global_mouse_position() - global_position).normalized() 
	return mouse_direction

func get_joystick_rotation_speed():
	if Input.is_action_pressed("precise_aiming"):
		return joystick_precise_rotation_speed
	return 1000.0

func copy_joystick_direction_from_mouse_pos():
	var local_mouse_pos = emitter.get_local_mouse_position()
	local_joystick_ray_direction = local_mouse_pos.normalized()

func get_new_ray_direction(delta, joy_direction):
	if local_joystick_ray_direction == null:
		return Vector2.ZERO
	var angle_to_target = local_joystick_ray_direction.angle_to(joy_direction)
	var max_angle = get_joystick_rotation_speed() * delta
	
	if abs(angle_to_target) >= max_angle:
		return local_joystick_ray_direction.rotated(max_angle * sign(angle_to_target))
	return joy_direction

func update_viewport_mouse_position(delta, joy_direction):
	local_joystick_ray_direction = get_new_ray_direction(delta, joy_direction)
	
	var local_target_pos = local_joystick_ray_direction * mouse_aime_distance
	var screen_pos = emitter.get_global_transform_with_canvas() * local_target_pos
	get_viewport().warp_mouse(screen_pos)

func get_direction():
	return current_direction

func update_spark_particles(index,raycast, is_colliding ):
	var start_point =to_local( line.get_point_position(  index ))
	var end_point = to_local(  line.get_point_position( index +1 ))
	spark_emitters[index].global_rotation =  raycast.target_position.angle()
	if (start_point.distance_to(end_point) * 0.5/100) * particles_amount_per_100px != spark_emitters[index].amount:
		if (start_point.distance_to(end_point) * 0.5/100) * particles_amount_per_100px < 1:
			spark_emitters[index].amount = 1
		else:
			spark_emitters[index].amount =  (start_point.distance_to(end_point) * 0.5/100) * particles_amount_per_100px
		
	spark_emitters[index].position = (start_point + end_point) * 0.5
	spark_emitters[index].process_material = spark_emitters[index].process_material.duplicate()
	spark_emitters[index].process_material.emission_box_extents.x = start_point.distance_to(end_point) * 0.5

func update_current_direction(player_position, target_direction):
	if  player_position.x +target_direction.x >= player_position.x:
		current_direction = 1
	else:
		current_direction = -1

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		if last_mouse_position != get_viewport().get_mouse_position() || event is InputEventKey:
			
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
