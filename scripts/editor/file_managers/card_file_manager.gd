extends VBoxContainer


const PARTS = ["Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Body"]
const SEGMENTS = ["base", "underlay", "overlay"]

@onready var editor = $"../../Tabs/CardEditor/pose_editor"

var open_tab := 0
var default_pose:Dictionary = {}
var pose_creator:ConfirmationDialog

func _ready():
	for part in PARTS:
		default_pose[part] = {}
		for segment in SEGMENTS:
			default_pose[part][segment] = {
				"x": 0,
				"y": 0,
				"z": 0,
				"bend": 0,
		}
	default_pose["Body"]["base"]["x"] = 90
	_load_cards()
	
	$"../../Tabs/CardEditor/TabContainer".tab_changed.connect(_card_editor_tab_changed)

func _card_editor_tab_changed(tab:int):
	if open_tab == tab: return
	open_tab = tab
	_load_poses() if tab else _load_cards()

func _clear_children():
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame

func _load_cards():
	_clear_children()
	pass #TODO: implement cards

func _load_poses():
	_clear_children()
	var pose_dir := DirAccess.open(GlobalStorage.path + "/hc-tcg-cc/poses")
	for file in pose_dir.get_files():
		if not file.ends_with(".pose"): continue
		var pose_button := Button.new()
		pose_button.text = file.get_basename()
		pose_button.pressed.connect(func():
			editor.load_pose_from_path(GlobalStorage.path + "/hc-tcg-cc/poses/" + file))
		add_child(pose_button)
	
	pose_creator = ConfirmationDialog.new()
	pose_creator.title = "Create new pose"
	pose_creator.confirmed.connect(_create_pose)
	
	var pose_name := LineEdit.new()
	pose_name.name = "PoseName"
	pose_creator.add_child(pose_name)
	
	add_child(pose_creator)
	
	var new_pose_button := Button.new()
	new_pose_button.text = "Create new"
	new_pose_button.pressed.connect(pose_creator.popup_centered)
	add_child(new_pose_button)

func _create_pose():
	var pose_name:String = pose_creator.get_node("PoseName").text.validate_filename()
	editor.load_pose(default_pose)
	editor.current_pose_path = GlobalStorage.path + "/hc-tcg-cc/poses/" + pose_name + ".pose"
	editor.save_current_pose()
	_load_poses()
