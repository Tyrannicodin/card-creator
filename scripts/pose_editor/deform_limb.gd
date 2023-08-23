# important note - Z is UP because of blender's exporting
extends MeshInstance3D

@export var update = false
@export var flip_bend = true
var mdt = MeshDataTool.new()

var current_rotation = Vector3(0,0,0)
var current_bend = 0 as float
var bend_nodes = []
var joint_nodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_gen_mesh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update:
		_gen_mesh()
		update = false

func _gen_mesh():
	var surface_tool := SurfaceTool.new()
	surface_tool.create_from(mesh,0)
	var array_mesh := surface_tool.commit()
	mesh = array_mesh

	mdt.create_from_surface(mesh, 0)
	mdt.commit_to_surface(mesh)
	
	var vertex_count = mdt.get_vertex_count()
	for vertex_number in vertex_count:
		var vertex = mdt.get_vertex(vertex_number)
		if vertex.z > 0:
			bend_nodes.append(vertex_number)
		if vertex.z < 0.1 and vertex.z > -0.1:
			if flip_bend && vertex.y > 0:
				joint_nodes.append(vertex_number)
			elif not flip_bend && vertex.y < 0:
				joint_nodes.append(vertex_number)
	
func _rotateVertex(vertex: Vector3, rotation: Vector3, origin: Vector3) -> Vector3:
	var r = {
		"x": Vector3(
			cos(rotation.y) * cos(rotation.z), 
			sin(rotation.z), 
			sin(rotation.y)
			),
		"y": Vector3(
			-1 * sin(rotation.z), 
			cos(rotation.x) * cos(rotation.z), 
			sin(rotation.x)
			),
		"z": Vector3(
			-1 * sin(rotation.y), 
			-1 * sin(rotation.x), 
			cos(rotation.x) * cos(rotation.y)
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
	var y_offset = amount * (0.005 * sin(PI * current_bend/50)) if amount <= 25 else 0.125
	vertex_rotation.x = current_bend * PI / 50 - amount * PI / 50
	current_bend = amount
	
	if flip_bend:
		vertex_rotation.x = PI * 2 - vertex_rotation.x
	
	var vertex_count = mdt.get_vertex_count()
	for vertex_number in vertex_count:
		var vertex = mdt.get_vertex(vertex_number)
		if bend_nodes.has(vertex_number):
			mdt.set_vertex(vertex_number, _rotateVertex(vertex, vertex_rotation, origin))
		if joint_nodes.has(vertex_number):
			mdt.set_vertex(vertex_number, Vector3(vertex.x,vertex.y,y_offset))
			
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
