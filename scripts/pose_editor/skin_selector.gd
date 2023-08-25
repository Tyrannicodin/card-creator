extends Button

@onready var file_dialog = $"../../SkinFileDialog"


func _pressed():
	file_dialog.popup()
