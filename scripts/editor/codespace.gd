extends Control

var snap_distance = 50
var available_connections = {}


func _can_drop_data(at_position, _d):
	var closest = [null, Vector2(INF, INF)]
	for node in available_connections:
		for connection in available_connections[node]:
			if connection.distance_to(at_position) < closest[1].distance_to(at_position):
				closest = [node, connection]
	if not closest[0] or closest[1].distance_to(at_position) > snap_distance:
		return true
	return true

func _drop_data(at_position, data):
	var closest = [null, Vector2(INF, INF)]
	for node in available_connections:
		for connection in available_connections[node]:
			if connection.distance_to(at_position) < closest[1].distance_to(at_position):
				closest = [node, connection]
	if not closest[0] or closest[1].distance_to(at_position) > snap_distance:
		print("NOSNAP")
		data["node"].position = at_position - data["offset"]
		data["node"].placed = true
		add_child(data["node"])
		available_connections[data["node"]] = []
		for connection in data["connections"]:
			available_connections[data["node"]].append(connection + data["node"].position)
		return
	available_connections[closest[0]].erase(closest[1])
	closest[0].connect_at(data["node"], closest[1])
