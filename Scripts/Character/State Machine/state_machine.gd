class_name StateMachine extends Node

signal state_changed()

@export var initial_state: State = null

#~~~immediatley invoveked funcion expression (IIFE)~~~
# -> wird sofort gecalled wenn die var definiert wird 

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()

# ?
# In der ready func werden alle States mit 
# der StateMachine veerknüpft
func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)

	# ? 
	# warten auf darauf das rooot node (Player) rdy ist
	# damit alle child nodes und states sicher geladen sind 
	await owner.ready
	state.enter("")

# ?
# func um den State zu wechseln. Beendet den alten State
# damit dieser in der exit func cleanup laufen kann. 
# Ruft dann die enter func des neuen States auf
func _transition_to_next_state(target_state: String, data: Dictionary = {}) -> void:
	# Debug
	if not has_node(target_state):
		printerr(owner.name + ": Trying to transition to state " + target_state + " but it does not exist.")
		return

	var previous_state := state.name
	state.exit()
	state = get_node(target_state)
	state.enter(previous_state, data)
#	print(get_parent().name , " -> entered new State : ", state.name)
	state_changed.emit()

#region State Updates
func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)
#endregion
