extends MenuButton


signal load_pose(pose:String)
signal reload_poses()

@onready var pose_dialog = get_parent().get_parent().get_node("PoseCreationDialog")

func _ready():
	get_popup().id_pressed.connect(_id_pressed)
	pose_dialog.canceled.connect(_cancel_pose_dialog)

func _id_pressed(id:int):
	match id:
		1:
			pose_dialog.title = "Rename pose"
			pose_dialog.confirmed.connect(_rename_pose)
			pose_dialog.popup_centered()
		2:
			var pose_name = get_parent().text + ".tscn"
			var previous_path = GlobalStorage.path + "/hc-tcg-cc/poses/"
			DirAccess.remove_absolute(previous_path + pose_name)
	reload_poses.emit()

func _cancel_pose_dialog():
	if pose_dialog.confirmed.is_connected(_rename_pose):
		pose_dialog.confirmed.disconnect(_rename_pose)

func _rename_pose():
	pose_dialog.confirmed.disconnect(_rename_pose)
	var new_name:String = pose_dialog.get_node("PoseName").text
	if not new_name.is_valid_filename():
		var deny = ConfirmationDialog.new()
		deny.title = "Couldn't rename pose"
		deny.get_label().text = "Invalid pose name"
		add_child(deny)
		deny.popup_centered()
	var pose_name = get_parent().text + ".tscn"
	var previous_path = GlobalStorage.path + "/hc-tcg-cc/poses/"
	DirAccess.rename_absolute(previous_path + pose_name, previous_path + new_name + ".tscn")
	load_pose.emit(new_name)
