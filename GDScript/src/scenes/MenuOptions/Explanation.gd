extends HBoxContainer


func _on_Explanation_meta_clicked(meta):
	var _err = OS.shell_open(meta)
