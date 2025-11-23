class_name PlayerState extends State

const IDLE = "Idle"
const WALK = "Walk"
const JUMP = "Jump"
const FALL = "Fall"
const PUSH = "Push"
const ATTACK = "Attack"
const INTERACT = "Interact"
const DEAD = "Dead"
var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as Player
	
	#~~~~~assert~~~~~~
	# Stellt sicher dass die condition true ist. 
	# Sendet eine Error Meldung, wenn die Bedingung false ist
	assert(player != null)
