extends Button


@onready var master_editor := $"../../../../../pose_editor"

func _ready():
	print(master_editor)

func _pressed():
	master_editor.save_current_pose()
