extends RightClickButton


signal reload_buttons()
signal load_pose(pose:String)

@onready var pose_button_poup = preload("res://scripts/pose_editor/pose_button_popup.gd")

var popupMenu:MenuButton

func _ready():
	popupMenu = MenuButton.new()
	popupMenu.set_script(pose_button_poup)
	popupMenu.load_pose.connect(func(pose):
		load_pose.emit(GlobalStorage.path + "/hc-tcg-cc/poses/" + pose + ".tscn"))
	popupMenu.reload_poses.connect(func(): reload_buttons.emit())
	popupMenu.get_popup().add_item("rename", 1)
	popupMenu.get_popup().add_item("delete", 2)
	add_child(popupMenu)

func _right_click():
	popupMenu.show_popup()
