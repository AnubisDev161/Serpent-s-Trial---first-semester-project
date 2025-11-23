class_name Player extends CharacterBody2D

#region Variables

@export_group("Basic Shit")
@export var health: int = 1
@export var petrify_laser: Node2D
@export var shots = 3
@export var ingame_ui: CanvasLayer
@export var cam :Camera2D

@export_group("Movement")
@export var speed = 650
@export var acceleration = 2600
@export var deceleration = 5300
@export var push_speed = 280


@export_group("Jump")
@export var gravity: float = 5100
@export var jump_power: float = -1810
@export var jump_cutoff: float = 0.4
@onready var coyote_timer: Timer = $CoyoteTimer

var can_move = true 
var is_dead = false
var input_direction_x
var last_dir
var curent_direction_x = 1

var interactable


@onready var anim = $AnimationPlayer
@onready var jump_vfx = $Jump_VFX/AnimatedSprite2D
@onready var bored_timer = $BoredTimer



var is_pushing = false
var push_object = null
#endregion

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ?
# just for identification
func is_player():
	pass

func _ready() -> void:
	ingame_ui.set_charges_ui(shots)
	#if petrify_laser != null:
	#	petrify_laser.enable_raycast(false)

func _physics_process(delta):
	# ? 
	# called in :	- _move()
	#				- enemy_attached 
	if !is_pushing:
		if !is_dead:
			_sprite_flip()
	is_grounded()

# ?
# ~ flips sprite and colliders
func _sprite_flip():
	var flip_dir
	flip_dir = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
	if flip_dir == 0:
		flip_dir = petrify_laser.get_direction()
	if flip_dir < 0 && last_dir != -1:
		$AnimatedSprite2D.scale.x = -0.5
		$PushHitbox.rotation_degrees = 180
		last_dir = -1 
		curent_direction_x = last_dir
	elif flip_dir > 0 && last_dir != 1:
		$AnimatedSprite2D.scale.x = 0.5
		$PushHitbox.rotation_degrees = 0
		last_dir = 1
		curent_direction_x = last_dir
	elif flip_dir == 0:
		last_dir = 0

# ? 
# called in : the player states
func _move(delta, max_speed):
	if can_move:
		input_direction_x = Input.get_axis("walk_left", "walk_right") 
		var target_speed = max_speed * input_direction_x
		if input_direction_x != 0:
			if sign(target_speed) == sign(velocity.x):
				velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
			else:
				velocity.x = move_toward(velocity.x, target_speed, deceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		if !is_grounded():
			velocity.y += gravity * delta
			velocity.y = min(velocity.y, 2000)
		if push_object:
			push_object.velocity.x = velocity.x 
			if self.is_on_wall():
				push_object.position.x = move_toward(push_object.position.x + 5 * sign(input_direction_x), acceleration * 2, delta)
			if is_pulling_enemy(self, push_object) && is_on_slope(push_object) && !is_on_slope(self) \
			|| !is_pulling_enemy(self, push_object) && is_on_slope(push_object) && is_on_slope(self) \
			|| is_pulling_enemy(self, push_object) && (is_on_slope(self) || is_on_slope(push_object)):
				velocity.x *= 0.9
			elif !is_pulling_enemy(self, push_object) && !is_on_slope(push_object) && is_on_slope(self) \
			|| !is_pulling_enemy(self, push_object) && is_on_slope(self) && is_on_slope(push_object):
				push_object.velocity.x *= 0.8
			push_object.move_and_slide()
		move_and_slide()

func is_grounded() -> bool:
	if $Ground_Raycast.get_collision_count():
		return true
	else :
		return false

# ? 
# called in : player fall State 
func _start_coyote_time():
	$CoyoteTimer.start()

# ? 
# called in : enemy_patroll 
#			 -> on player contact
func update_health(value):
	health += value
	if health <= 0 && is_dead == false:
		is_dead = true
		#player_died.emit()

# ?
# ~ resets the push object
# ~ also detaches body so it wont get stuck on player
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("set_attach") && push_object != null:
		body.set_attach(false)
		push_object = null

# ? 
# ~ checks if thers an enemy in the area and if so attaches it to the player
# ~ is called in IDLE and WALK when shift is pressed
func update_push_object():
	for body in $PushHitbox.get_overlapping_bodies():
		if body.has_method("set_attach"):
			if push_object != null && !is_pushing:
				push_object.set_attach(false)
			push_object = body

func is_in_cutscene(value):
	if value:
		cam.enabled = false
		process_mode = ProcessMode.PROCESS_MODE_DISABLED
		ingame_ui.visible = false
	else: 
		process_mode = ProcessMode.PROCESS_MODE_PAUSABLE
		cam.enabled = true
		ingame_ui.visible = true

func shoot():
	$Player_laser.shoot(true)
	
func play_jump_vfx():
	jump_vfx.stop()
	jump_vfx.position = Vector2(position.x + -5, position.y + 30)
	jump_vfx.play("player_jump_vfx")

func is_on_slope(object):
	if abs(object.get_floor_normal().x) > 0.1:
		return true
	else: 
		return false
		
func is_pulling_enemy(player, enemy):
	var input_direction = Input.get_axis("walk_left", "walk_right") 
	var player_to_box = sign(enemy.global_position.x - player.global_position.x)
	return input_direction == -player_to_box  
