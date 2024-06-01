extends GraphNode


func _get_drag_data(at_position):
	if get_parent() is GraphEdit:
		return

	print("Drag requested   ", at_position)
	var preview: Control = Control.new()
	var copy: GraphNode = duplicate()
	preview.add_child(copy)
	copy.position = -at_position
	set_drag_preview(preview)
	return {"node": copy, "held_offset": at_position}
