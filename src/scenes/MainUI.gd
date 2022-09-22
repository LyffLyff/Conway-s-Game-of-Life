extends MarginContainer

#NODES
onready var gens_per_sec : SpinBox = $HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/GensPerSec
onready var play : TextureButton = $HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/Play
onready var next_gen : TextureButton  =$HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/NextGen


func _ready():
	var _err = gens_per_sec.get_line_edit().connect("text_entered",gens_per_sec,"release_focus")
	_err = play.connect("pressed",play,"release_focus")
	_err = next_gen.connect("pressed",next_gen,"release_focus")
	gens_per_sec.set_value(float(Engine.iterations_per_second))


func _on_GensPerSec_value_changed(var value : int):
	Engine.iterations_per_second = int(value)
