extends VBoxContainer

# Player meshes
@onready var player = $"../player_full"
@onready var items = $items
@onready var selected_item

#sliders
@onready var bend_slider = $bend
@onready var x_slider = $x
@onready var y_slider = $y
@onready var z_slider = $z
@onready var pickup_changes = false

# Body parts
@onready var skin = {
	"Head" : {
		"base" : player.get_node("Node/Head/"),
		"underlay": player.get_node("Node/Head/Head_001"),
		"overlay": player.get_node("Node/Head/Hat Layer")
	},
	"Right Arm" : {
		"base" : player.get_node("Node/RightArm/"),
		"underlay": player.get_node("Node/RightArm/Right Arm"),
		"overlay": player.get_node("Node/RightArm/Right Arm Layer")
	},
	"Left Arm" : {
		"base" : player.get_node("Node/LeftArm/"),
		"underlay": player.get_node("Node/LeftArm/Left Arm"),
		"overlay": player.get_node("Node/LeftArm/Left Arm Layer")
	},
	"Body" : {
		"base" : player.get_node("Node"),
		"underlay": player.get_node("Node/Body/Body_001"),
		"overlay": player.get_node("Node/Body/Body Layer")
	},
	"Right Leg" : {
		"base" : player.get_node("Node/RightLeg/"),
		"underlay": player.get_node("Node/RightLeg/Right Leg"),
		"overlay": player.get_node("Node/RightLeg/Right Leg Layer")
	},
	"Left Leg" : {
		"base" : player.get_node("Node/LeftLeg/"),
		"underlay": player.get_node("Node/LeftLeg/Left Leg"),
		"overlay": player.get_node("Node/LeftLeg/Left Leg Layer")
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for key in skin:
		items.add_item(key)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_x_value_changed(value):
	if not pickup_changes:
		return
	selected_item.base.rotation_degrees.x = value

func _on_y_value_changed(value):
	if not pickup_changes:
		return
	selected_item.base.rotation_degrees.y = value
	
func _on_z_value_changed(value):
	if not pickup_changes:
		return
	selected_item.base.rotation_degrees.z = value

func _on_bend_value_changed(value):
	if not pickup_changes:
		return
	selected_item.underlay.bend(value)
	selected_item.overlay.bend(value)

func _on_items_item_selected(index):
	pickup_changes = false
	bend_slider.visible = true
	
	selected_item = skin[items.get_item_text(index)]
	x_slider.value = selected_item.base.rotation_degrees.x
	y_slider.value = selected_item.base.rotation_degrees.y
	z_slider.value = selected_item.base.rotation_degrees.z
	
	if ["Head", "Node"].has(selected_item.base.name):
		bend_slider.visible = false
	else:
		bend_slider.value = selected_item.underlay.current_bend
	pickup_changes = true
