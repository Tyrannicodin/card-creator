extends GraphEdit


func _ready():
	add_valid_connection_type(0, 1)
	add_valid_connection_type(1, 0)
	add_valid_connection_type(2, 3)
	add_valid_connection_type(3, 2)
	connect("connection_request", _on_connection_request)

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	#TODO: Recursion checker
	#TODO: Connection number checker
	connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	disconnect_node(from_node, from_port, to_node, to_port)

func _on_popup_request(request_location: Vector2):
	$PopupMenu.position = request_location + position
	$PopupMenu.popup()

func _can_drop_data(_at_position, data):
	return data.has("node") and zoom == 1

func _drop_data(at_position, data):
	data["node"].reparent(self)
	data["node"].position_offset = scroll_offset + at_position - data["held_offset"]
