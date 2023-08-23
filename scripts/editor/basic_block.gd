extends TextureRect
class_name BasicBlock

var placed = false
var upper_connection = Vector2(35, 5)

func _get_drag_data(at_position):
	if placed:
		return
	var preview = Control.new()
	var copy = duplicate()
	preview.add_child(copy)
	copy.position -= at_position
	set_drag_preview(preview)
	return {
		"node": duplicate(),
		"name": name,
		"connections": [Vector2(35, 55)],
		"offset": at_position,
	}

func connect_at(node, connection):
	if not node.upper_connection:
		return false
	node.placed = true
	add_child(node)
	node.position = connection - position - node.upper_connection
	return true
