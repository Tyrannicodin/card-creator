extends VBoxContainer


@onready var new_pose_dialog := $PoseCreationDialog
@onready var pose_editor := $"../../../../Tabs/pose_editor"

func _ready():
	_reload_poses()
	new_pose_dialog.canceled.connect(_cancel_pose_dialog)

func _new_pose_pressed():
	new_pose_dialog.title = "Create new pose"
	new_pose_dialog.confirmed.connect(_new_pose)
	new_pose_dialog.popup_centered()

func _cancel_pose_dialog():
	if new_pose_dialog.confirmed.is_connected(_new_pose):
		new_pose_dialog.confirmed.disconnect(_new_pose)

func _new_pose():
	new_pose_dialog.confirmed.disconnect(_new_pose)
	var new_pose_name:String = new_pose_dialog.get_node("PoseName").text
	var fp := GlobalStorage.path + "/hc-tcg-cc/poses/" + new_pose_name.validate_filename() + ".tscn"
	pose_editor.save(fp)
	_reload_poses()

func _reload_poses():
	for child in get_children():
		if child.name.begins_with("file_"):
			child.queue_free()
	await get_tree().process_frame
	var pose_path := GlobalStorage.path + "/hc-tcg-cc/poses/"
	var files = DirAccess.open(pose_path)
	if !files:
		return
	for file in files.get_files():
		var poseButton := preload("res://scripts/pose_editor/pose_button.gd").new()
		poseButton.name = "file_" + file.get_basename()
		poseButton.text = file.get_basename()
		poseButton.left_click.connect(func(): pose_editor.load_pose(pose_path.path_join(file)))
		poseButton.load_pose.connect(func(pose): pose_editor.load_pose(pose_path.path_join(pose)))
		poseButton.reload_buttons.connect(_reload_poses)
		add_child(poseButton)
		
