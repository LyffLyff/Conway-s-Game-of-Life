extends MarginContainer


#NODES
onready var gens_per_sec : SpinBox = $HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/GensPerSec
onready var play : TextureButton = $HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/Play
onready var next_gen : TextureButton  =$HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/NextGen
onready var clr : ColorPickerButton = $HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/HBoxContainer/CellClr


func _ready():
	var _err = gens_per_sec.get_line_edit().connect("text_entered",self,"loose_focus",[gens_per_sec.get_line_edit()])
	_err = play.connect("pressed",play,"release_focus")
	_err = next_gen.connect("pressed",next_gen,"release_focus")
	_err = clr.connect("popup_closed",clr,"release_focus")
	gens_per_sec.set_value(float(Engine.iterations_per_second))


func _on_GensPerSec_value_changed(var value : int):
	Engine.iterations_per_second = int(value)


func loose_focus(var _arg, var node : Control) -> void:
	node.release_focus()
