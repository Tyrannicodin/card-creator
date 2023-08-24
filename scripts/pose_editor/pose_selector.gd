extends Button

@onready var file_dialog = $"../../LoadPoseFileDialog"


func _pressed():
	file_dialog.popup()
