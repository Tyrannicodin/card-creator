extends VBoxContainer


func _card_type_changed(type:String):
	for child in get_children():
		child.visible = child.name.begins_with(type) or child.name == "all"
