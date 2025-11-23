extends Control

@export var mouse_tooltips: Array[TooltipData]
@export var controller_tooltips: Array[TooltipData]
var current_tooltip_array = []

var index_of_tooltips_to_show = 0
@onready var anim = $AnimationPlayer
@onready var ui_main = $".."
@export var current_tooltip_type: tooltip_types
@onready var press_tab: Label = $Frame/Press_tab

enum tooltip_types{
	Mouse, Controller
}
var last_tooltip_type = null

var current_tooltip
var currently_displayed_tooltip_index: int = 0 
var tooltip_window_opend = false

func _ready() -> void:
	Signal_Bus.ui_show_tooltip_popup.connect(show_tooltip_popup) 
	Signal_Bus.ui_hide_tooltip_popup.connect(hide_tooltip_popup)
	Signal_Bus.ui_open_tooltip_window.connect(open_tooltip_window)
	

func _input(event: InputEvent) -> void:
	update_current_tooltip_type(event)

func update_tooltips():
	index_of_tooltips_to_show = (Signal_Bus.ui_seen_tooltips)
	if tooltip_window_opend == true:
		currently_displayed_tooltip_index = index_of_tooltips_to_show

func open_tooltip_window():
	update_tooltips()
	current_tooltip = current_tooltip_array[0]
	current_tooltip.visible = true
	anim.play("open")
	tooltip_window_opend = true
	
func tooltip_window_next():
	for i in current_tooltip_array:
		i.visible = false
	if currently_displayed_tooltip_index < index_of_tooltips_to_show -check_for_index_cut() :
		currently_displayed_tooltip_index += 1
	else: 
		currently_displayed_tooltip_index = 0
	current_tooltip = current_tooltip_array[currently_displayed_tooltip_index]
	current_tooltip.visible = true

func show_tooltip_popup(index):
	if tooltip_window_opend:
		return
	for i in controller_tooltips:
		i.visible = false
	for i in mouse_tooltips:
		i.visible = false
	tooltip_window_opend = true
	
	var index_cut = 0
	if index > current_tooltip_array.size() -1:
		index_cut = 1
		if index > Signal_Bus.ui_seen_tooltips:
			Signal_Bus.ui_seen_tooltips = index
			controller_tooltips[index].has_been_seen = true
		
	current_tooltip = current_tooltip_array[index -index_cut]
	if index > index_of_tooltips_to_show:
		index_of_tooltips_to_show = index -index_cut
		
	currently_displayed_tooltip_index = index -index_cut
	current_tooltip.visible = true
	if !current_tooltip.has_been_seen:
		if index > Signal_Bus.ui_seen_tooltips:
			Signal_Bus.ui_seen_tooltips = index
		current_tooltip.has_been_seen = true
	anim.play("open")
 
func hide_tooltip_popup():
	if tooltip_window_opend:
		anim.play("close")
		current_tooltip.visible = false
		tooltip_window_opend = false
		currently_displayed_tooltip_index = 0

func update_current_tooltip_type(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var old_tooltip_array = current_tooltip_array
		current_tooltip_type = tooltip_types.Controller
		current_tooltip_array = controller_tooltips
		press_tab.text = "hold select/back to open                      press select/back switch"
		if tooltip_window_opend == true:
			for i in old_tooltip_array:
				i.visible = false
			
			current_tooltip_array[currently_displayed_tooltip_index].visible = true
	elif (event is InputEventKey):
		var old_tooltip_array = current_tooltip_array
		current_tooltip_type = tooltip_types.Mouse
		current_tooltip_array = mouse_tooltips
		press_tab.text = "hold tab to open                                     press tab to switch"
		
		if tooltip_window_opend == true:
			for i in old_tooltip_array:
				i.visible = false
			if currently_displayed_tooltip_index <= mouse_tooltips.size() -1:
				current_tooltip_array[currently_displayed_tooltip_index].visible = true
			else:
				currently_displayed_tooltip_index -= 1
	print("Seen tooltips:", Signal_Bus.ui_seen_tooltips)
	print("index of tooltips available:", index_of_tooltips_to_show)
	print("currently displayed tooltips:",currently_displayed_tooltip_index)

func init_tooltips():
	hide_tooltip_popup()
	current_tooltip_type = tooltip_types.Mouse
	current_tooltip_array = mouse_tooltips
	index_of_tooltips_to_show = Signal_Bus.ui_seen_tooltips
	currently_displayed_tooltip_index = 0
	for i in controller_tooltips:
		i.has_been_seen = false
	for i in mouse_tooltips:
		i.has_been_seen = false

func check_for_index_cut():
	var index_cut = 0
	
	if current_tooltip_type == tooltip_types.Mouse && (currently_displayed_tooltip_index +1) > mouse_tooltips.size() -1:
		index_cut = 1
	return index_cut
