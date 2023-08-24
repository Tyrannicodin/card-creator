extends Control
class_name BasicBlock

var highlight_material = preload("res://assets/materials/highlight_block.tres")

var placed := false
var upper_connection = Vector2(35, 10)
var initial_connections := [Vector2(35, 50)]

var block_template_middle = preload("res://assets/sprites/base_blocks/block_template.tres")

var is_copy := false
var fields:Array[String] = ["Pick", "INPUT_SPACE"]
var color := Color.RED

const BlockColors = {
	"EVENTS": Color(0.13333333333333333, 0.5686274509803921, 0.18823529411764706),
	"CONTROL": Color(0.2784313725490196, 0.3843137254901961, 0.8705882352941177),
	"MATHS": Color(0.8980392156862745, 0.8156862745098039, 0.25098039215686274),
	"CONSTANTS": Color(0.23921568627450981, 0.6901960784313725, 0.9294117647058824),
	"ACTIONS": Color(0.6901960784313725, 0.19215686274509805, 0.12156862745098039),
	"VARIABLES": Color(0.8313725490196079, 0.42745098039215684, 0.11372549019607843)
}

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
	var to_place = duplicate()
	to_place.is_copy = true
	return {
		"node": to_place,
		"offset": at_position,
		"new": true,
	}

func _generate_block(block_fields: Array[String]):
	var mdt = MeshDataTool.new()
	var m = MeshInstance2D.new()
	m.mesh = block_template_middle.duplicate()
	
	var panel = Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(panel)
	panel.add_child(m)
	mdt.create_from_surface(m.mesh, 0)
		
	m.mesh.clear_surfaces()

	var hbox = HBoxContainer.new()
	panel.add_child(hbox)
	
	hbox.set_position(Vector2(0, 20))

	for field in block_fields:
		var new_label = Label.new()
		new_label.text = field
		new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(new_label)
	await get_tree().process_frame
	var vertex_count = mdt.get_vertex_count()
	for vertex_number in vertex_count:
		var vertex = mdt.get_vertex(vertex_number)
		mdt.set_vertex(vertex_number, Vector3(vertex.x/10 + 25, vertex.y/10 + 30, vertex.z/10))
	mdt.commit_to_surface(m.mesh)
	#Don't know why I need to commit to surface and iterate through the vertices again.
	#This seems very wasteful but otherwise the geometry becomes weird. Should probably look into this later
	for vertex_number in vertex_count:
		var vertex = mdt.get_vertex(vertex_number)
		if (vertex.x > 40):
			mdt.set_vertex(vertex_number, Vector3(vertex.x + hbox.size.x - 50, vertex.y, vertex.z))
	mdt.commit_to_surface(m.mesh)
	for vertex_number in vertex_count:
		var vertex = mdt.get_vertex(vertex_number)
		if upper_connection == null:
			if vertex.y < 20 && vertex.x > 1 && vertex.x < 30:
				mdt.set_vertex(vertex_number, Vector3(vertex.x, 5, vertex.z))
		mdt.set_vertex_color(vertex_number, color)
	mdt.commit_to_surface(m.mesh)
	
	#Set self size for collisions
	self.custom_minimum_size = Vector2(hbox.size.x,70)

## Get the available connections on a node
func available_connections(offset:Vector2 = Vector2()) -> Array:
	var current_available_connections := []
	for connection in initial_connections:
		if has_node(str(connection.x) + "_" + str(connection.y)):
			var sub_block = get_node(str(connection.x) + "_" + str(connection.y))
			current_available_connections.append_array(sub_block.available_connections(offset + sub_block.position))
		else:
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
