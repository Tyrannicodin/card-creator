extends Control
class_name BasicBlock

var placed = false
var upper_connection = Vector2(35, 5)

var block_template_middle = preload("res://assets/sprites/base_blocks/block_template.tres")

var is_copy = false
var fields = ["Pick", "INPUT_SPACE"] as Array[String]
var color = Color.RED

func _ready():
	if is_copy == false:
		_generate_block(fields)

func _get_drag_data(at_position):
	if placed:
		return
	var preview = Control.new()
	var copy = duplicate()
	copy.is_copy = true
	preview.add_child(copy)
	copy.position -= at_position
	set_drag_preview(preview)
	var duplicate = duplicate()
	duplicate.is_copy = true
	return {
		"node": duplicate,
		"name": name,
		"connections": [Vector2(35, 55)],
		"offset": at_position,
	}
	
func _generate_block(fields: Array[String]):
	var mdt = MeshDataTool.new()
	var m = MeshInstance2D.new()
	m.mesh = block_template_middle.duplicate()
	
	var panel = Panel.new()
	add_child(panel)
	panel.add_child(m)
	mdt.create_from_surface(m.mesh, 0)
		
	m.mesh.clear_surfaces()

	var hbox = HBoxContainer.new()
	panel.add_child(hbox)
	
	hbox.set_position(Vector2(0, 20))

	for field in fields:
		var new_label = Label.new()
		new_label.text = field
		new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(new_label)
	await get_tree().process_frame
	var vertex_count = mdt.get_vertex_count()
	for vertex_number in mdt.get_vertex_count():
		var vertex = mdt.get_vertex(vertex_number)
		mdt.set_vertex(vertex_number, Vector3(vertex.x/10 + 25, vertex.y/10 + 30, vertex.z/10))
	mdt.commit_to_surface(m.mesh)
	#Don't know why I need to commit to surface and iterate through the vertices again.
	#This seems very wasteful but otherwise the geometry becomes weird. Should probably look into this later
	for vertex_number in mdt.get_vertex_count():
		var vertex = mdt.get_vertex(vertex_number)
		if (vertex.x > 40):
			mdt.set_vertex(vertex_number, Vector3(vertex.x + hbox.size.x - 50, vertex.y, vertex.z))
	mdt.commit_to_surface(m.mesh)
	for vertex_number in mdt.get_vertex_count():
		var vertex = mdt.get_vertex(vertex_number)
		if upper_connection == null:
			if vertex.y < 20 && vertex.x > 1 && vertex.x < 30:
				mdt.set_vertex(vertex_number, Vector3(vertex.x, 5, vertex.z))
		mdt.set_vertex_color(vertex_number, color)
	mdt.commit_to_surface(m.mesh)
	
	#Set self size for collisions
	self.custom_minimum_size = Vector2(hbox.size.x,70)

func connect_at(node, connection):
	if not node.upper_connection:
		return false
	node.placed = true
	add_child(node)
	node.position = connection - position - node.upper_connection
	return true
