extends Control

var mdt = MeshDataTool.new()

# Player meshes
@onready var player_wide = $player_full
@onready var player_slim = $player_slim
@onready var items = $HBoxContainer/LeftContainer/items
@onready var skin_image = $HBoxContainer/RightContainer/GridContainer/SkinImage

var steve_texture = preload("res://assets/models/steve.png")
var alex_texture = preload("res://assets/models/alex.png")
var selected_item

#sliders
@onready var bend_slider = $HBoxContainer/LeftContainer/GridContainer/bend
@onready var x_slider = $HBoxContainer/LeftContainer/GridContainer/x
@onready var y_slider = $HBoxContainer/LeftContainer/GridContainer/y
@onready var z_slider = $HBoxContainer/LeftContainer/GridContainer/z
@onready var pickup_changes = false

@onready var pose_name = $HBoxContainer/RightContainer/GridContainer/PoseName

enum SkinType {WIDE, SLIM}
var type_selected = SkinType.WIDE

# Body parts
@onready var player_mesh = {
	SkinType.WIDE : {
		"Head" : {
			"base" : player_wide.get_node("Node/Head/"),
			"underlay": player_wide.get_node("Node/Head/Head_001"),
			"overlay": player_wide.get_node("Node/Head/Hat Layer")
		},
		"Right Arm" : {
			"base" : player_wide.get_node("Node/RightArm/"),
			"underlay": player_wide.get_node("Node/RightArm/Right Arm"),
			"overlay": player_wide.get_node("Node/RightArm/Right Arm Layer")
		},
		"Left Arm" : {
			"base" : player_wide.get_node("Node/LeftArm/"),
			"underlay": player_wide.get_node("Node/LeftArm/Left Arm"),
			"overlay": player_wide.get_node("Node/LeftArm/Left Arm Layer")
		},
		"Body" : {
			"base" : player_wide.get_node("Node"),
			"underlay": player_wide.get_node("Node/Body/Body_001"),
			"overlay": player_wide.get_node("Node/Body/Body Layer")
		},
		"Right Leg" : {
			"base" : player_wide.get_node("Node/RightLeg/"),
			"underlay": player_wide.get_node("Node/RightLeg/Right Leg"),
			"overlay": player_wide.get_node("Node/RightLeg/Right Leg Layer")
		},
		"Left Leg" : {
			"base" : player_wide.get_node("Node/LeftLeg/"),
			"underlay": player_wide.get_node("Node/LeftLeg/Left Leg"),
			"overlay": player_wide.get_node("Node/LeftLeg/Left Leg Layer")
		}
	},
	SkinType.SLIM : {
		"Head" : {
			"base" : player_slim.get_node("Node/Head/"),
			"underlay": player_slim.get_node("Node/Head/Head_001"),
			"overlay": player_slim.get_node("Node/Head/Hat Layer")
		},
		"Right Arm" : {
			"base" : player_slim.get_node("Node/RightArm/"),
			"underlay": player_slim.get_node("Node/RightArm/Right Arm"),
			"overlay": player_slim.get_node("Node/RightArm/Right Arm Layer")
		},
		"Left Arm" : {
			"base" : player_slim.get_node("Node/LeftArm/"),
			"underlay": player_slim.get_node("Node/LeftArm/Left Arm"),
			"overlay": player_slim.get_node("Node/LeftArm/Left Arm Layer")
		},
		"Body" : {
			"base" : player_slim.get_node("Node"),
			"underlay": player_slim.get_node("Node/Body/Body_001"),
			"overlay": player_slim.get_node("Node/Body/Body Layer")
		},
		"Right Leg" : {
			"base" : player_slim.get_node("Node/RightLeg/"),
			"underlay": player_slim.get_node("Node/RightLeg/Right Leg"),
			"overlay": player_slim.get_node("Node/RightLeg/Right Leg Layer")
		},
		"Left Leg" : {
			"base" : player_slim.get_node("Node/LeftLeg/"),
			"underlay": player_slim.get_node("Node/LeftLeg/Left Leg"),
			"overlay": player_slim.get_node("Node/LeftLeg/Left Leg Layer")
		}
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if not DirAccess.dir_exists_absolute("user://poses"):
		DirAccess.make_dir_absolute("user://poses")
	
	type_selected = SkinType.WIDE
	for key in player_mesh[type_selected]:
		items.add_item(key)
	_apply_skin(steve_texture, player_mesh[SkinType.WIDE])
	_apply_skin(alex_texture, player_mesh[SkinType.SLIM])

func save():
	if not pose_name.text.is_valid_filename():
		return
	var saved_player = PackedScene.new()
	for child in player_wide.get_children():
		pack_children(player_wide, child)
	saved_player.pack(player_wide)
	var pose_path = "user://poses/" + pose_name.text + ".tscn"
	ResourceSaver.save(saved_player, pose_path)

func load_pose(path:String):
	var packed_pose_scene:PackedScene = load(path)
	if not packed_pose_scene is PackedScene and packed_pose_scene:
		return
	var loading_pose = packed_pose_scene.instantiate()
	if not loading_pose.name in ["player_full", "player_slim"]:
		return #TODO: More advanced checks on scene we are importing
	_on_skintype_item_selected(0 if loading_pose.name == "player_full" else 1)
	get_node(loading_pose.name as String).queue_free()
	add_child(loading_pose)
	if loading_pose.name == "player_full":
		player_wide = loading_pose
	else:
		player_slim = loading_pose

func pack_children(root:Node, current_node:Node):
	current_node.set_owner(root)
	for child in current_node.get_children():
		pack_children(root, child)

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
	
	selected_item = player_mesh[type_selected][items.get_item_text(index)]
	selected_item.underlay.set_layer_mask_value(2, true)
	selected_item.overlay.set_layer_mask_value(2, true)
	x_slider.value = selected_item.base.rotation_degrees.x
	y_slider.value = selected_item.base.rotation_degrees.y
	z_slider.value = selected_item.base.rotation_degrees.z
	
	if selected_item.underlay is PlayerLimb:
		bend_slider.value = selected_item.underlay.get_current_bend()
	else:
		bend_slider.visible = false
	pickup_changes = true

func _apply_skin(skin_texture, parts_dict):
	skin_image.texture = skin_texture
	for key in parts_dict:
		for segment in parts_dict[key]:
			var m = parts_dict[key][segment]
			if m is MeshInstance3D:
				mdt.create_from_surface(m.mesh, 0)
				var skin_material = mdt.get_material()
				skin_material.albedo_texture = skin_texture
				#skin_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
				mdt.set_material(skin_material)
				m.mesh.clear_surfaces()
				mdt.commit_to_surface(m.mesh)

func _on_file_dialog_file_selected(path):
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	texture.set_image(image)
	_apply_skin(texture, player_mesh[type_selected])

func _carry_info(from_mesh: SkinType, to_mesh: SkinType):
	var parts_dict = player_mesh[from_mesh]
	for key in parts_dict:
		if parts_dict[key] == selected_item:
			selected_item = player_mesh[to_mesh][key]
		for segment in parts_dict[key]:
			var from_segment = player_mesh[from_mesh][key][segment]
			var to_segment = player_mesh[to_mesh][key][segment]
			to_segment.rotation_degrees.x = from_segment.rotation_degrees.x
			to_segment.rotation_degrees.y = from_segment.rotation_degrees.y
			to_segment.rotation_degrees.z = from_segment.rotation_degrees.z
			if to_segment is PlayerLimb: 
				to_segment.bend(from_segment.get_current_bend())

func _on_skintype_item_selected(index):
	if index == 0:
		player_slim.visible = false
		player_wide.visible = true
		type_selected = SkinType.WIDE
		_carry_info(SkinType.SLIM, SkinType.WIDE)
	if index == 1:
		player_wide.visible = false
		player_slim.visible = true
		type_selected = SkinType.SLIM
		_carry_info(SkinType.WIDE, SkinType.SLIM)
