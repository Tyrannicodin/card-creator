extends Node

var current_pack: Pack = Pack.new()
var current_path: String

func load_pack(path: String):
	current_pack = ResourceLoader.load(path, "Pack")
	current_path = path

func save_pack(path: String = ""):
	var save_path = current_path
	if path != "":
		save_path = path
	ResourceSaver.save(current_pack, save_path)
