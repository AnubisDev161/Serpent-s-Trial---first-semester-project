class_name UI_Main extends CanvasLayer

@onready var MAIN = $Menu
@onready var PAUSE = $Pause
@onready var SETTINGS = $Settings 
@onready var CREDITS = $Credits
@onready var TOOLTIPS = $Tooltips
@onready var SELECTION = $Level_Selection

@export var default_menu: Node
@export var default_start_time: float = 0.0

var menus: Array[String] = []
var menu_stack: Array[Node] = []
var is_paused = false

func _ready() -> void:
	for child in get_children():
		if child.is_in_group("UI"):
			menus.append(child)
	
	if default_menu:
		await get_tree().create_timer(default_start_time).timeout
		push(default_menu)

func push(menu_name):
	if menu_stack.size() > 0:
		menu_stack.back().visible = false
	menu_stack.append(menu_name)
	menu_stack.back().visible = true

func pop():
	if menu_stack.back() == null:
		return
	menu_stack.back().visible = false
	var prev_menu_size = menu_stack.size()
	var menu_name = menu_stack.pop_back()
	if prev_menu_size > 1:
		menu_stack.back().visible = true

func pause_game():
	push(PAUSE)
	get_tree().paused = true

func unpause_game():
	get_tree().paused = false
	pop()
	Signal_Bus.game_resume.emit()
