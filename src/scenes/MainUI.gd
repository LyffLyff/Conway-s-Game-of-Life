extends MarginContainer

#NODES
onready var gens_per_sec : SpinBox = $HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/GensPerSec


func _ready():
	gens_per_sec.set_value(float(Engine.iterations_per_second))


func _on_GensPerSec_value_changed(var value : int):
	Engine.iterations_per_second = int(value)
