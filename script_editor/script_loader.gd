@tool extends TabContainer


const folder_target: String = "res://script_editor/node_spawners"

@onready var node_folder: PackedScene = preload("res://script_editor/node_spawners/node_folder.tscn")

func _ready():
	var folders = DirAccess.open(folder_target)
	for folder in folders.get_directories():
		var new_category = node_folder.instantiate()
		new_category.name = folder
		var node_container = new_category.get_node("Margin/NodeList")
		for file in DirAccess.get_files_at(folder_target + "/" + folder):
			node_container.add_child(load(folder_target + "/" + folder + "/" + file).instantiate())
		add_child(new_category)


