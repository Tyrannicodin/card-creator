extends Control


func _tab_changed(tab:int):
	for child in get_children():
		child.hide()
	get_child(tab).show()
