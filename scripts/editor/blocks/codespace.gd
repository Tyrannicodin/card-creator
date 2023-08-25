extends Control


signal clear_highlight()

var snap_distance = 50
var available_connections:Array[BasicBlock] = []


func _can_drop_data(at_position, data):
	var closest:Array[Array] = []
	for node in available_connections:
		for connection in node.available_connections(node.position):
			closest.append([connection[0], connection[1], connection[2]])
	closest.sort_custom(func(item1:Array, item2:Array): return item1[1].distance_to(at_position - data["offset"]) < item2[1].distance_to(at_position - data["offset"]))
	available_connections.append(data["node"])
	var snap_to
	for connection in closest:
		if connection[1].distance_to(at_position - data["offset"]) < snap_distance and connection[0].can_connect(data["node"]):
			snap_to = connection
			break
	if snap_to:
		snap_to[0].highlight()
	else:
		clear_highlight.emit()
	return true

func _drop_data(at_position, data):
	data["node"].show()
	clear_highlight.emit()
	var closest:Array[Array] = []
	for node in available_connections:
		for connection in node.available_connections(node.position):
			closest.append(connection)
	closest.sort_custom(
		func(item1:Array, item2:Array):
			return item1[1].distance_to(at_position - data["offset"]) < item2[1].distance_to(at_position - data["offset"])
	)
	if data["new"]:
		available_connections.append(data["node"])
		clear_highlight.connect(data["node"].unhighlight)
	var snap_to
	for connection in closest:
		if connection[1].distance_to(at_position - data["offset"]) < snap_distance and connection[0].connect_at(data["node"], connection[2]):
			snap_to = connection
			break
	if snap_to:
		return
	data["node"].position = at_position - data["offset"]
	data["node"].placed = true
	if data["new"]:
		add_child(data["node"])
