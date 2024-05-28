extends GraphEdit


func _ready():
	add_valid_connection_type(0, 1)
	add_valid_connection_type(1, 0)
	connect("connection_request", _on_connection_request)

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	connect_node(from_node, from_port, to_node, to_port)
