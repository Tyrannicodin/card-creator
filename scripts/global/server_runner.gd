extends Node

var os_path
var ci_pid

func run(path):
	"""Run a server on localhost at path"""
	os_path = path.replace("user://", OS.get_user_data_dir() + "/")
	
	if OS.get_name() == "Windows":
		ci_pid = OS.create_process("CMD.exe", ["/C", "cd " + os_path + " && npm ci"], true)
	else:
		return

func _process(_d):
	if os_path and ci_pid:
		if ci_pid > 0 and OS.is_process_running(ci_pid):
			return
		ci_pid = null
		if OS.get_name() == "Windows":
			OS.create_process("CMD.exe", ["/C", "cd " + os_path + " && npm run docker-start"], true)
		else:
			return
