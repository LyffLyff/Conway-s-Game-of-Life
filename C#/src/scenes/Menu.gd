extends CenterContainer

#NODES
onready var options_place : VBoxContainer = $PanelContainer/VBoxContainer/Option
onready var option_buttons : HBoxContainer = $PanelContainer/VBoxContainer/Header

#PRELOADS
var options : Array = [
	preload("res://src/scenes/MenuOptions/Patterns.tscn"),
	preload("res://src/scenes/MenuOptions/Shortcuts.tscn"),
	preload("res://src/scenes/MenuOptions/Credits.tscn")
]


func _ready():
	for i in option_buttons.get_child_count():
		option_buttons.get_child(i).connect("pressed",self,"load_option",[i])
	load_option(0)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_parent().queue_free()


func load_option(var idx : int) -> void:
	#deleting Prior Options
	for i in options_place.get_children():
		i.queue_free()
	
	options_place.add_child(
		options[idx].instance()
	)
