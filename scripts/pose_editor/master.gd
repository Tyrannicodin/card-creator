extends Control

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

#func save(path:String):
#	var saved_player = PackedScene.new()
#	for child in player_wide.get_children():
#		pack_children(player_wide, child)
#	saved_player.pack(player_wide)
#	ResourceSaver.save(saved_player, path)
#
#func load_pose(path:String):
#	var packed_pose_scene:PackedScene = load(path)
#	if not (packed_pose_scene and packed_pose_scene is PackedScene):
#		return
#	var loading_pose = packed_pose_scene.instantiate()
#	if not loading_pose.name in ["player_full", "player_slim"]:
#		return #TODO: More advanced checks on scene we are importing
#	loading_pose.set_meta("filename", path.get_file())
#	_on_skintype_item_selected(0 if loading_pose.name == "player_full" else 1)
#	get_node(loading_pose.name as String).queue_free()
#	await get_tree().process_frame
#	add_child(loading_pose)
#	if loading_pose.name == "player_full":
#		player_wide = loading_pose
#	else:
#		player_slim = loading_pose
#
#func pack_children(root:Node, current_node:Node):
#	current_node.set_owner(root)
#	for child in current_node.get_children():
#		pack_children(root, child)

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
	for skin in player_mesh.values():
		for part in skin.values():
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
	_apply_skin(texture)

func _on_skintype_item_selected(index):
	if index == 0:
		player_slim.visible = false
		player_wide.visible = true
	if index == 1:
		player_wide.visible = false
		player_slim.visible = true
