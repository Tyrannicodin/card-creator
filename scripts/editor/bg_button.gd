extends Button

@onready var file_dialog = $"../FileDialog"

func _pressed():
	file_dialog.popup()
