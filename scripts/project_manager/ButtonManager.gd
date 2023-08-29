extends VBoxContainer


signal reload_packs()

var project_button_group = preload("res://assets/button_groups/project_button.tres")
var chosen_button

func _ready():
	project_button_group.pressed.connect(project_selected)

func disable_buttons():
	chosen_button = null
	for child in get_children():
		if child is Button:
			child.disabled = true

func project_selected(button):
	if not chosen_button:
		for child in get_children():
			child.disabled = false
	chosen_button = button
	GlobalStorage.path = "user://packs/" + chosen_button.name.replace("\\", "/")
	GlobalStorage.pack_name = chosen_button.text.lstrip(" ")

func edit():
	get_tree().change_scene_to_file("res://scenes/editor/editor.tscn")

func run():
	ServerRunner.new(GlobalStorage.path).run_server()

func duplicate_project():
	"""Would duplicate a project, no way to so yet so will be done whenever it is provided"""
	return

func rename():
	var meta_file = FileAccess.open(GlobalStorage.path + "/hc-tcg-cc/pack.meta", FileAccess.READ)
	var meta = meta_file.get_var()
	meta_file.close()
	
	var pop = ConfirmationDialog.new()
	pop.title = "Rename project"
	pop.confirmed.connect(name_chosen(pop, meta))
	
	var name_input = LineEdit.new()
	name_input.name = "PackName"
	name_input.text = meta["name"]
	name_input.select_all_on_focus = true
	name_input.text_submitted.connect(func(_t): pop.get_ok_button().pressed.emit())
	pop.add_child(name_input)
	
	add_child(pop)
	pop.popup_centered()

func name_chosen(dialog:ConfirmationDialog, meta:Dictionary):
	var inner = func():
		var new_name:String = dialog.get_node("PackName").text
		meta["name"] = new_name
		var unique_name = new_name
		var version_dir = DirAccess.open(GlobalStorage.path.rsplit("/", true, 1)[0])
		if version_dir.dir_exists(unique_name):
			var suffix = 2
			while version_dir.dir_exists(unique_name + "_" + str(suffix)):
				suffix += 1
			unique_name = unique_name + "_" + str(suffix)
		meta["uid"] = unique_name
		var meta_file = FileAccess.open(GlobalStorage.path + "/hc-tcg-cc/pack.meta", FileAccess.WRITE)
		meta_file.store_var(meta)
		meta_file.close()
		DirAccess.rename_absolute(
			GlobalStorage.path,
			GlobalStorage.path.rsplit("/", true, 1)[0] + "/" + unique_name
		)
		reload_packs.emit()
	return inner

func remove():
	remove_dir(GlobalStorage.path)
	reload_packs.emit()

func remove_dir(path:String):
	for file in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file))
	for dir in DirAccess.get_directories_at(path):
		remove_dir(path.path_join(dir))
	DirAccess.remove_absolute(path)
