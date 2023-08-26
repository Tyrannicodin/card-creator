extends VBoxContainer


@onready var new_pose_dialog := $PoseCreationDialog
@onready var pose_editor := $"../../../../Tabs/pose_editor"

func _ready():
	new_pose_dialog.connect("confirmed", _new_pose)

func _new_pose_pressed():
	new_pose_dialog.popup_centered()

func _new_pose():
	var new_pose_name:String = new_pose_dialog.get_node("PoseName").text
	var fp := GlobalStorage.path + "/hc-tcg-cc/poses/" + new_pose_name.validate_filename() + ".tscn"
	pose_editor.save(fp)
	_reload_poses()

func _reload_poses():
	for child in get_children():
		if child.name.begins_with("file_"):
			child.queue_free()
	var pose_path := GlobalStorage.path + "/hc-tcg-cc/poses/"
	for file in DirAccess.open(pose_path).get_directories():
		var poseButton := Button.new()
		poseButton.name = "file_" + file.get_basename()
		poseButton.pressed.connect(func(): pose_editor.load_pose(pose_path.path_join(file)))
		add_child(poseButton)
		
