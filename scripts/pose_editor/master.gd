extends Control


signal save_complete()

var mdt = MeshDataTool.new()

# Player meshes
@onready var player_wide = $player_full
@onready var player_slim = $player_slim
@onready var items

var steve_texture = preload("res://assets/models/steve.png")
var selected_wide
var selected_slim

# Saving stuff
var skin:Image
var current_pose_path:String
@onready var viewport:Viewport = $SubViewportContainer/SubViewport

#sliders
@onready var bend_slider:Slider
@onready var x_slider:Slider
@onready var y_slider:Slider
@onready var z_slider:Slider
@onready var pickup_changes := false

enum SkinType {WIDE, SLIM}

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
	add_items()
	
	_apply_skin(steve_texture)

func add_items():
	if player_mesh == null || items == null:
		return
	for key in player_mesh[SkinType.WIDE]:
		items.add_item(key)

func load_pose_from_path(path:String):
	save_current_pose()
	current_pose_path = path
	var save_file = FileAccess.open(path, FileAccess.READ)
	var save_data:Dictionary = save_file.get_var()
	save_file.close()
	load_pose(save_data)

func load_pose(save_data:Dictionary):
	pickup_changes = false
	for skin_mesh in player_mesh.values():
		for part in skin_mesh:
			if not save_data.has(part): continue
			for segment in skin_mesh[part]:
				if not save_data[part].has(segment): continue
				var current_segment:Node3D = skin_mesh[part][segment]
				var current_segment_values:Dictionary = save_data[part][segment]
				if current_segment is PlayerLimb:
					current_segment.bend(current_segment_values["bend"])
				current_segment.rotation_degrees.x = current_segment_values["x"]
				current_segment.rotation_degrees.y = current_segment_values["y"]
				current_segment.rotation_degrees.z = current_segment_values["z"]

func save():
	save_current_pose()
	save_complete.emit()

func save_current_pose():
	if not current_pose_path: return
	var save_dict = parse_dict(player_mesh[SkinType.WIDE])
	save_dict["skin"] = skin
	var save_file = FileAccess.open(current_pose_path, FileAccess.WRITE)
	save_file.store_var(save_dict)
	save_file.close()

func screenshot():
	if not DirAccess.dir_exists_absolute("user://screenshots"):
		DirAccess.make_dir_absolute("user://screenshots")
	viewport.get_texture().get_image().save_png("user://screenshots/" + Time.get_datetime_string_from_system().replace(":", "_") + ".png")

func parse_dict(dict:Dictionary):
	var output = {}
	for key in dict:
		if dict[key] is Dictionary:
			output[key] = parse_dict(dict[key])
		elif dict[key] is Node3D:
			var limb:Node3D = dict[key]
			output[key] = {
				"x": limb.rotation_degrees.x,
				"y": limb.rotation_degrees.y,
				"z": limb.rotation_degrees.z,
			}
		if dict[key] is PlayerLimb:
			output[key]["bend"] = dict[key].get_current_bend()
	return output

func _on_x_value_changed(value):
	if not pickup_changes:
		return
	selected_wide.base.rotation_degrees.x = value
	selected_slim.base.rotation_degrees.x = value

func _on_y_value_changed(value):
	if not pickup_changes:
		return
	selected_wide.base.rotation_degrees.y = value
	selected_slim.base.rotation_degrees.y = value
	
func _on_z_value_changed(value):
	if not pickup_changes:
		return
	selected_wide.base.rotation_degrees.z = value
	selected_slim.base.rotation_degrees.z = value

func _on_bend_value_changed(value):
	if not pickup_changes:
		return
	selected_wide.underlay.bend(value)
	selected_wide.overlay.bend(value)
	selected_slim.underlay.bend(value)
	selected_slim.overlay.bend(value)

func _on_items_item_selected(index):
	pickup_changes = false
	bend_slider.visible = true
	
	selected_wide = player_mesh[SkinType.WIDE][items.get_item_text(index)]
	selected_wide.underlay.set_layer_mask_value(2, true)
	selected_wide.overlay.set_layer_mask_value(2, true)
	
	selected_slim = player_mesh[SkinType.SLIM][items.get_item_text(index)]
	selected_slim.underlay.set_layer_mask_value(2, true)
	selected_slim.overlay.set_layer_mask_value(2, true)
	
	x_slider.value = selected_wide.base.rotation_degrees.x
	y_slider.value = selected_wide.base.rotation_degrees.y
	z_slider.value = selected_wide.base.rotation_degrees.z
	
	if selected_wide.underlay is PlayerLimb:
		bend_slider.value = selected_wide.underlay.get_current_bend()
	else:
		bend_slider.visible = false
	pickup_changes = true

func _apply_skin(skin_texture):
	for skin_mesh in player_mesh.values():
		for part in skin_mesh.values():
			for segment in part.values():
				if segment is MeshInstance3D:
					mdt.create_from_surface(segment.mesh, 0)
					var skin_material = mdt.get_material()
					skin_material.albedo_texture = skin_texture
					#skin_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
					mdt.set_material(skin_material)
					segment.mesh.clear_surfaces()
					mdt.commit_to_surface(segment.mesh)

func _on_file_dialog_file_selected(path):
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	texture.set_image(image)
	skin = image
	_apply_skin(texture)

func _on_skintype_item_selected(index):
	if index == 0:
		player_slim.visible = false
		player_wide.visible = true
	if index == 1:
		player_wide.visible = false
		player_slim.visible = true
