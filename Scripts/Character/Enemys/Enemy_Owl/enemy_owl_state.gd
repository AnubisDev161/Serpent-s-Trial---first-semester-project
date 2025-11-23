class_name EnemyOwlState extends State

const IDLE = "Idle"
const CHARGE = "Charge"
 
var enemy: EnemyOwl

func _ready() -> void:
	await owner.ready
	enemy = owner as EnemyOwl
	
	#~~~~~assert~~~~~~
	# Stellt sicher dass die condition true ist. 
	# Sendet eine Error Meldung, wenn die Bedingung false ist
	assert(enemy != null)
