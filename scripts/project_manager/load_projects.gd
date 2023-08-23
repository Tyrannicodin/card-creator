extends VBoxContainer


signal reset_buttons()

var project_button_group = preload("res://assets/button_groups/project_button.tres")
var project_button_theme = preload("res://assets/themes/project_selector.tres")

func _ready():
	reload_projects()

func reload_projects():
	"""Load all projects and put them in a list"""
	
	GlobalStorage.path = ""
	reset_buttons.emit()
	
	# Remove all old children
	for child in get_children():
		child.queue_free()
	
	# No versions made yet
	if not DirAccess.dir_exists_absolute("user://versions"):
		return
	
	# Iterate through each version and create a section for their projects
	var base_dir = DirAccess.open("user://versions")
	var dir_container
	var version_label
	for dir in base_dir.get_directories():
		dir_container = VBoxContainer.new()
		dir_container.name = dir
		
		version_label = Label.new()
		version_label.name = "VersionLabel"
		version_label.text = dir.replace("_", ".")
		version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		version_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		dir_container.add_child(version_label)
		
		base_dir.change_dir(dir)
		for project in base_dir.get_directories():
			dir_container.add_child(generate_project_button("user://versions/" + dir + "/" + project))
		base_dir.change_dir("..")
		
		dir_container.add_child(HSeparator.new())
		add_child(dir_container)

func generate_project_button(path:String):
	"""Generate a button for a project"""
	
	var button = Button.new()
	button.name = path.rsplit("/", true, 2)[1] + "\\" + path.rsplit("/", true, 1)[1]
	button.text = " " + path.rsplit("/", true, 1)[1]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.toggle_mode = true
	button.button_group = project_button_group
	button.custom_minimum_size = Vector2(0, 40)
	button.theme = project_button_theme
	
	if not FileAccess.file_exists(path + "/hc-tcg-cc/meta.json"):
		override_button_font_color(button, Color(1, 0, 0))
		button.tooltip_text = "Couldn't find custom files"
		return button
	var meta_file = FileAccess.open(path + "/hc-tcg-cc/meta.json", FileAccess.READ)
	var meta = JSON.parse_string(meta_file.get_as_text())
	meta_file.close()
	if meta["editor_version"] != ProjectSettings.get_setting("application/config/version"):
		override_button_font_color(button, Color(.5, .5, 0))
		button.tooltip_text = "Incorrect version, project might not open correctly"
		return button
	
	button.text = " " + meta["name"]
	
	var sub_label = Label.new()
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sub_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	sub_label.text = str(meta["cards"]) + " card(s) | " + str(meta["packs"]) + " pack(s) "
	sub_label.add_theme_color_override("font_color", Color("808080"))
	sub_label.add_theme_font_size_override("font_size", 10)
	
	sub_label.anchor_bottom = 0
	sub_label.anchor_left = 0
	sub_label.anchor_right = 1
	sub_label.anchor_bottom = 1
	
	button.add_child(sub_label)
	
	return button

func override_button_font_color(button, color):
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_pressed_color", color)
	button.add_theme_color_override("font_hover_color", color)
	button.add_theme_color_override("font_focus_color", color)
	button.add_theme_color_override("font_hover_pressed_color", color)
	button.add_theme_color_override("font_disabled_color", color)
