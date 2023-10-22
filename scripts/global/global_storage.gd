extends Node

var path := "" : 
	set(value):
		path = value
		resource_path = value + "/hc-tcg-cc"
var resource_path := ""
var pack_name := ""

func load_asset(id:int):
	for file in DirAccess.get_files_at(resource_path + "/assets"):
		if file.get_basename() == str(id):
			return load(resource_path + "/assets/" + file)

func save_asset(asset:Resource, id:int = -1):
	if id < 0:
		id += 1
		while FileAccess.file_exists(resource_path + "/assets/" + str(id) + ".tres"):
			id += 1
	ResourceSaver.save(asset, resource_path + "/assets/" + str(id) + ".tres")
	return id
