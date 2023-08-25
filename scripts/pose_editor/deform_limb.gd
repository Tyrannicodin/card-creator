# important note - Z is UP because of blender's exporting
extends MeshInstance3D
class_name PlayerLimb

@export var update = false
@export var flip_bend = true
var mdt = MeshDataTool.new()

var current_rotation = Vector3(0,0,0)
var _current_bend = 0 as float
var _bend_nodes = []
var _joint_nodes = []

func _ready():
	_gen_mesh()

func _process(_d):
	if update:
		_gen_mesh()
		update = false

func _gen_mesh():
	#var surface_tool := SurfaceTool.new()
	#surface_tool.create_from(mesh,0)
	#var array_mesh := surface_tool.commit()
	#mesh = array_mesh

	mdt.create_from_surface(mesh, 0)
	mdt.commit_to_surface(mesh)
	
	var vertex_count = mdt.get_vertex_count()
	for vertex_number in vertex_count:
		var vertex = mdt.get_vertex(vertex_number)
		if vertex.z > 0:
			_bend_nodes.append(vertex_number)
		if vertex.z < 0.05 and vertex.z > 0:
			if flip_bend && vertex.y > 0:
				_joint_nodes.append(vertex_number)
			elif not flip_bend && vertex.y < 0:
				_joint_nodes.append(vertex_number)
		mdt.set_vertex(vertex_number, Vector3(vertex.x * (1 + vertex.z * 0.01), vertex.y, vertex.z))
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	
func _rotateVertex(vertex: Vector3, new_rotation: Vector3, origin: Vector3) -> Vector3:
	var r = {
		"x": Vector3(
			cos(new_rotation.y) * cos(new_rotation.z), 
			sin(new_rotation.z), 
			sin(new_rotation.y)
			),
		"y": Vector3(
			-1 * sin(new_rotation.z), 
			cos(new_rotation.x) * cos(new_rotation.z), 
			sin(new_rotation.x)
			),
		"z": Vector3(
			-1 * sin(new_rotation.y), 
			-1 * sin(new_rotation.x), 
			cos(new_rotation.x) * cos(new_rotation.y)
			)
		}
		
	var output = Vector3(0,0,0)
	
	vertex -= origin
	
	output.x = vertex.x * r.x.x + vertex.y * r.y.x + vertex.z * r.z.x + origin.x
	output.y = vertex.x * r.x.y + vertex.y * r.y.y + vertex.z * r.z.y + origin.y
	output.z = vertex.x * r.x.z + vertex.y * r.y.z + vertex.z * r.z.z + origin.z
	return output
	
func bend(amount: int) -> void:
	var origin = Vector3(0,0,0)
	var vertex_rotation = Vector3(0,0,0)
	var z_offset = amount * (0.0035 * sin(PI * _current_bend/50)) if amount <= 25 else 0.095
	var flip_multiplier = 1 if flip_bend else -1
	var y_offset = (0.125 * flip_multiplier) if amount <= 25 else (0.125 * flip_multiplier) + (amount-25) * -0.005 * flip_multiplier
	vertex_rotation.x = _current_bend * PI / 50 - amount * PI / 50
	_current_bend = amount
	
	if flip_bend:
		vertex_rotation.x = PI * 2 - vertex_rotation.x
	
	var vertex_count = mdt.get_vertex_count()
	for vertex_number in vertex_count:
		var vertex = mdt.get_vertex(vertex_number)
		if _bend_nodes.has(vertex_number):
			mdt.set_vertex(vertex_number, _rotateVertex(vertex, vertex_rotation, origin))
		if _joint_nodes.has(vertex_number):
			mdt.set_vertex(vertex_number, Vector3(vertex.x,y_offset,0.03 + z_offset))
			
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)

func rotateVertices(axis: String, degrees: int):
	var vertex_rotation = Vector3(0,0,0)
	var origin = mdt.get_vertex(0)
	# convert degrees to radians
	if axis == "x":
		vertex_rotation.x = current_rotation.x - degrees * PI / 180
		current_rotation.x = degrees * PI / 180
	if axis == "y":
		vertex_rotation.y = current_rotation.y - degrees * PI / 180
		current_rotation.y = degrees * PI / 180
	if axis == "z":
		vertex_rotation.z = current_rotation.z - degrees * PI / 180
		current_rotation.z = degrees * PI / 180
	
	# rotate mesh
	var vertex_count = mdt.get_vertex_count()
	for vertex_number in vertex_count:
		var vertex = mdt.get_vertex(vertex_number)
		if vertex:
			mdt.set_vertex(vertex_number, _rotateVertex(vertex, vertex_rotation, origin))
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)

func get_current_bend():
	return _current_bend
