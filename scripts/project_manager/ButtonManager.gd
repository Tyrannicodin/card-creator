extends VBoxContainer


signal reload_projects()

var project_button_group = preload("res://assets/button_groups/project_button.tres")
var chosen_button

@onready var EditButton = $EditButton
@onready var RunButton = $RunButton
@onready var DuplicateButton = $DuplicateButton
@onready var RenameButton = $RenameButton
@onready var RemoveButton = $RemoveButton

func _ready():
	project_button_group.pressed.connect(project_selected)
	EditButton.pressed.connect(edit)
	RunButton.pressed.connect(run)
	DuplicateButton.pressed.connect(duplicate_project)
	RenameButton.pressed.connect(rename)
	RemoveButton.pressed.connect(remove)

func disable_buttons():
	chosen_button = null
	for child in get_children():
		child.disabled = true

func project_selected(button):
	if not chosen_button:
		for child in get_children():
			child.disabled = false
	chosen_button = button
	GlobalStorage.path = "user://projects/" + chosen_button.name.replace("\\", "/")
	GlobalStorage.project_name = chosen_button.text.lstrip(" ")

func edit():
	get_tree().change_scene_to_file("res://scenes/editor/editor.tscn")

func run():
	ServerRunner.new(GlobalStorage.path).run_server()

func duplicate_project():
	"""Would duplicate a project, no way to so yet so will be done whenever it is provided"""
	
	return
	var meta_file = FileAccess.open(GlobalStorage.path + "/hc-tcg-cc/meta.json", FileAccess.READ)
	var meta = JSON.parse_string(meta_file.get_as_text())
	meta_file.close()
	
	var i = 1
	while meta["uid"][len(meta["uid"])-i].is_valid_int():
		i += 1
	var current_iter
	if i == 1:
		current_iter = 2
	else:
		current_iter = int(meta["uid"].substr(len(meta["uid"])-i))
	var unique_name = meta["uid"].substr(0, len(meta["uid"])-i)
	var version_dir = DirAccess.open(GlobalStorage.path.rsplit("/", true, 1)[0])
	if version_dir.dir_exists(unique_name):
		var suffix = current_iter
		while version_dir.dir_exists(unique_name + "_" + str(suffix)):
			suffix += 1
		unique_name = unique_name + "_" + str(suffix)
	meta["uid"] = unique_name
	
	var new_loc = GlobalStorage.path.rsplit("/", true, 1)[0]
	version_dir.copy(GlobalStorage.path, unique_name)
	var new_meta = FileAccess.open(
		new_loc + "/" + unique_name + "/hc-tcg-cc/meta.json",
		FileAccess.WRITE
	)
	new_meta.store_string(JSON.stringify(meta))
	new_meta.close()
	reload_projects.emit()

func rename():
	var meta_file = FileAccess.open(GlobalStorage.path + "/hc-tcg-cc/meta.json", FileAccess.READ)
	var meta = JSON.parse_string(meta_file.get_as_text())
	meta_file.close()
	
	var pop = ConfirmationDialog.new()
	pop.title = "Rename project"
	pop.unresizable = false
	pop.borderless = false
	pop.confirmed.connect(name_chosen(pop, meta, meta["name"]))
	
	var name_input = LineEdit.new()
	name_input.text = meta["name"]
	name_input.select_all_on_focus = true
	name_input.text_submitted.connect(func(_t): pop.get_ok_button().pressed.emit())
	pop.add_child(name_input)
	
	$"/root".add_child(pop)
	pop.popup_centered()

func name_chosen(pop, meta, old_name):
	var inner = func():
		var new_name = pop.get_child(0).text
		if new_name == old_name:
			return
		if not new_name.is_valid_filename():
			var dia = AcceptDialog.new()
			dia.dialog_text = "Invalid project name"
			$"/root".add_child(dia)
			dia.popup_centered()
			return
		meta["name"] = new_name
		var unique_name = new_name
		var version_dir = DirAccess.open(GlobalStorage.path.rsplit("/", true, 1)[0])
		if version_dir.dir_exists(unique_name):
			var suffix = 2
			while version_dir.dir_exists(unique_name + "_" + str(suffix)):
				suffix += 1
			unique_name = unique_name + "_" + str(suffix)
		meta["uid"] = unique_name
		var meta_file = FileAccess.open(GlobalStorage.path + "/hc-tcg-cc/meta.json", FileAccess.WRITE)
		meta_file.store_string(JSON.stringify(meta))
		meta_file.close()
		DirAccess.rename_absolute(
			GlobalStorage.path,
			GlobalStorage.path.rsplit("/", true, 1)[0] + "/" + unique_name
		)
		reload_projects.emit()
	return inner

func remove():
	var err = DirAccess.remove_absolute(GlobalStorage.path)
	print(DirAccess.get_open_error())
	print(err)
	reload_projects.emit()
