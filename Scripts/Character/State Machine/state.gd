class_name State extends Node

# ~~~~~~~~~~~~~~~~~Base Class für alle States~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#  Gibt allen States ein Set an Funktionen, die diese benutzen können.
#
# States nutzten nicht die _physics_process func da sonst alle states 
# immer aufgerufen werden. Deshalb erstellen wir neue Update Funktionen
# die im _physic_update der StateMachine aufgerufen werden, wenn der 
# State aktiv ist. 
#
# Sendet an die StateMachine eine Signal wenn der State wechseln möchte
# damit diese den entspechenden nächten State setzen kann. 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

signal finished(next_state, data)

func enter(previous_state, data := {}):
	pass

func handle_input(_event):
	pass

func update(_delta):
	pass

func physics_update(_delta):
	pass

func exit():
	pass
