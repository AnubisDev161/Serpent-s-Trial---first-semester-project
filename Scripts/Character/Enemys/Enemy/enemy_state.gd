class_name EnemyState extends State

const IDLE = "Idle"
const PETRI = "Petrified"
const PATROL = "Patrol"
const ATTACHED = "Attached"
const SHOOT = "Shoot"
const CHASE = "Chase"
 
var enemy: Enemy

func _ready() -> void:
	await owner.ready
	enemy = owner as Enemy
	
	#~~~~~assert~~~~~~
	# Stellt sicher dass die condition true ist. 
	# Sendet eine Error Meldung, wenn die Bedingung false ist
	assert(enemy != null)
