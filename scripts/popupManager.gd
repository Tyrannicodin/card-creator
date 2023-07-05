extends Node

signal folderPicked(fp:String)

func createDialog():
	var fd = FileDialog.new()
	fd.mode_overrides_title = false
	fd.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.title = "Select the root server folder"
	fd.min_size = Vector2(600, 500)
	fd.canceled.connect(cancel)
	fd.dir_selected.connect(passFolder)
	add_child(fd)
	fd.popup_centered()

func cancel():
	get_tree().quit()

func passFolder(fp:String):
	folderPicked.emit(fp)
