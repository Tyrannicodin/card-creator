extends VBoxContainer

# Player meshes
@onready var r_arm = $"Node/RightArm/Right Arm Layer"

# Called when the node enters the scene tree for the first time.
func _ready():
	r_arm.bend(30)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_x_value_changed(value):
	r_arm.rotation_degrees.x = value

func _on_y_value_changed(value):
	r_arm.rotation_degrees.y = value
	
func _on_z_value_changed(value):
	r_arm.rotation_degrees.z = value

func _on_bend_value_changed(value):
	r_arm.bend(value)
