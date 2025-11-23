extends Area2D

@export var speed: float = 300
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	$Timer.start()
	 

func _process(delta):
	position += direction * speed * delta
	transform.x = direction

func _on_body_entered(body):
	if body.has_method("is_player"):
		body.update_health(-1)
		queue_free()
	elif body != self.get_parent():
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
