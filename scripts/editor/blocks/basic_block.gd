extends TextureRect
class_name BasicBlock

var highlight_material = preload("res://assets/materials/highlight_block.tres")

var placed := false
var upper_connection = Vector2(35, 5)
var initial_connections := [Vector2(35, 55)]

func _get_drag_data(at_position):
	if placed:
		return {

		}
	var preview = Control.new()
	var copy = duplicate()
	preview.add_child(copy)
	copy.position -= at_position
	set_drag_preview(preview)
	return {
		"node": duplicate(),
		"offset": at_position,
		"new": true,
	}

## Get the available connections on a node
func available_connections(offset:Vector2 = Vector2()) -> Array:
	var current_available_connections := []
	for connection in initial_connections:
		if has_node(str(connection.x) + "_" + str(connection.y)):
			var sub_block = get_node(str(connection.x) + "_" + str(connection.y))
			current_available_connections.append_array(sub_block.available_connections(offset + sub_block.position))
		else:
			for child in get_children():
				print(child.name)
			current_available_connections.append([self, connection + offset, connection])
	return current_available_connections

func can_connect(block:BasicBlock) -> bool:
	if not block.upper_connection or block.placed:
		return false
	return true

## Try to connect to a block to a connection point
func connect_at(block:BasicBlock, connection:Vector2) -> bool:
	if not can_connect(block):
		return false
	block.placed = true
	block.name = str(connection.x) + "_" + str(connection.y)
	add_child(block)
	block.position = connection - block.upper_connection
	return true

func highlight():
	material = highlight_material

func unhighlight():
	material = null
