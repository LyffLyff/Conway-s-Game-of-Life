extends HBoxContainer


func _on_Credits_meta_clicked(meta):
	var _err = OS.shell_open(meta)
