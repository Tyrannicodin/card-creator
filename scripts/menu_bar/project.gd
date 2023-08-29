extends PopupMenu


signal save()
signal save_complete()

var saved := 0

func _ready():
	save.connect(_on_save)
	get_tree().call_group("save", "connect", "save_complete", set_saved)
	id_pressed.connect(_id_pressed)

func _id_pressed(id:int):
	save.emit()
	await save_complete
	match id:
		2:
			if OS.get_name() == "Windows":
				var save_path = OS.get_user_data_dir() + "/exports/" + GlobalStorage.pack_name + ".tar.gz"
				var os_path = GlobalStorage.path.replace("user:/", OS.get_user_data_dir())
				OS.execute(
					"CMD.exe",
					["/C", "cd \"" + os_path + "\" && tar -cf \"" + save_path + "\" hc-tcg-cc"]
				)
			else:
				return
			OS.shell_open(OS.get_user_data_dir() + "/exports/")
		3:
			get_tree().quit()
		4:
			GlobalStorage.path = ""
			GlobalStorage.pack_name = ""
			get_tree().change_scene_to_file("res://scenes/project_manager.tscn")

func _on_save():
	saved = 0
	get_tree().call_group("save", "save")

func set_saved():
	saved += 1
	if saved == len(get_tree().get_nodes_in_group("save")):
		await get_tree().process_frame
		save_complete.emit()
