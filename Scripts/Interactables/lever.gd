class_name lever
extends Area2D
signal pulled
signal pulled_back
@onready var owl_sprite: Sprite2D = $Owl_sprite
@onready var particleleft: GPUParticles2D = $ParticleLeft
@onready var particleright: GPUParticles2D = $ParticleRight
@export var is_pulled = false

func _ready() -> void:
	if is_pulled == true:
		$AnimationPlayer.play("pulled")
		$ParticleRight
		$ParticleLeft
	else:
		$AnimationPlayer.play("default")



func pull_lever():
	if is_pulled == false:
		
		is_pulled = true
		$AnimationPlayer.play("pulled")
		emit_signal("pulled")
		particleleft.emitting = true
		particleright.emitting = true
	else:
		is_pulled = false
		$AnimationPlayer.play("default")
		emit_signal("pulled_back")
		particleleft.emitting = false
		particleright.emitting = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		body.interactable = self
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		body.interactable = null
