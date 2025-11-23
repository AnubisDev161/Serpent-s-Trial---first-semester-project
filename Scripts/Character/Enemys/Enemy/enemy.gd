class_name Enemy extends CharacterBody2D

#region Variables
#----Movement----
@export var gravity : float
@export var speed = 300
@export var direction: Vector2 = Vector2.RIGHT

#-----General-----
@onready var anim = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
var player: Player
@onready var rock_push_sound: AudioStreamPlayer2D = $Rock_push_sound
@onready var rock_falling_sound: AudioStreamPlayer2D = $Rock_falling_sound
@onready var enemy_petrified_sound: AudioStreamPlayer2D = $Enemy_petrified_sound




#-----Petrify------
var is_petrified = false 
var can_be_petrified = true  # wird für den Petri Raycast Enemy Ding genutzt
var is_attached = false

#-----Shoot-------
@export var projectile: PackedScene
@export var shoot_range = 300.0
@onready var attack_timer = $Attack_Timer
var can_shoot = true
@onready var shoot_icon = $Shoot_Icon
@onready var line_of_sight: RayCast2D = $Line_of_sight

#endregion

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ?
func _ready():
	if anim.material:
		anim.material = anim.material.duplicate()
# bis jetzt nur zum überprüfen mit has_method
func is_pushable() -> bool:
	return is_petrified

#region Petri Stuff
# ? 
# set true ->  PlayerController [Area2D enter]
# set false -> PushState [exit] & Player [Area2D exit]
func set_attach(value) :
	is_attached = value

# ? 
# called by :	- Player Raycast State
# 				- iwo beim Laser idk?
func petrify(collision_position):
	if is_looking_at_player(collision_position):
		if is_petrified == true:
			return
		if can_be_petrified == false:
			return
		var tween = get_tree().create_tween()
		tween.tween_method(shader_blink, 1.0, 0.0, 0.5)
		is_petrified = true
		can_be_petrified = false
		enemy_petrified_sound.play()
	else :
		return

func is_grounded() -> bool:
	if $Ground_Raycast.get_collision_count():
		return true
	else :
		return false

func is_looking_at_player(target_position):
	var target_direction = (target_position - global_position).normalized() 
	var facing_direction = Vector2.RIGHT * direction
	return facing_direction.dot(target_direction) > 0
	
#endregion

func is_player_in_range():
	var player_direction = ( player.global_position - global_position).normalized()
	line_of_sight.target_position = player_direction * shoot_range
	if line_of_sight.is_colliding() && line_of_sight.get_collider().has_method("is_player"):
		return true
	else:
		return false

func _on_attack_timer_timeout() -> void:
	can_shoot = true
	
func sprite_flip():
	if sign(direction.x) > 0:
		anim.flip_h = true
	else:
		anim.flip_h = false

# Shader shit

func shader_blink(newValue : float):
	anim.material.set_shader_parameter("blink_intensity", newValue)
