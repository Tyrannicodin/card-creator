extends PopupMenu


signal load_pose(pose:String)
signal reload_poses()

var pose_dialog:ConfirmationDialog

func _ready():
	add_item("Rename", 1)
	add_item("Delete", 2)
	pose_dialog = ConfirmationDialog.new()
	pose_dialog.title = "Rename pose"
	pose_dialog.name = "RenamePoseDialog"
	pose_dialog.confirmed.connect(_rename_pose)
	
	var pose_name := LineEdit.new()
	pose_name.placeholder_text = "Pose name"
	pose_name.name = "PoseName"
	pose_dialog.add_child(pose_name)
	
	get_parent().add_child.call_deferred(pose_dialog)
	id_pressed.connect(_id_pressed)

func _id_pressed(id:int):
	match id:
		1:
			pose_dialog.popup_centered()
		2:
			var pose_name = get_parent().text + ".pose"
			var pose_path = GlobalStorage.path + "/hc-tcg-cc/poses/"
			DirAccess.remove_absolute(pose_path + pose_name)
			reload_poses.emit()

func _rename_pose():
	var new_name:String = pose_dialog.get_node("PoseName").text
	var pose_name = get_parent().text + ".pose"
	var previous_path = GlobalStorage.path + "/hc-tcg-cc/poses/"
	var new_pose_path = previous_path + new_name.validate_filename() + ".pose"
	DirAccess.rename_absolute(
		previous_path + pose_name,
		new_pose_path
	)
	load_pose.emit(new_pose_path)
	reload_poses.emit()
