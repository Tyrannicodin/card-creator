extends VBoxContainer

@onready var pose_editor = $"../../pose_editor"

# Called when the node enters the scene tree for the first time.
func _ready():
	var node = pose_editor.get_node("LeftContainer").duplicate()
	add_child(node)
	
	node.visible = true
	pose_editor.items = node.get_node("items")
	pose_editor.add_items()
	pose_editor.bend_slider = node.get_node("GridContainer/bend")
	pose_editor.x_slider = node.get_node("GridContainer/x")
	pose_editor.y_slider = node.get_node("GridContainer/y")
	pose_editor.z_slider = node.get_node("GridContainer/z")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
