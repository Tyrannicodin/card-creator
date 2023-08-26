extends Object
class_name ServerRunner

signal packages()
signal build()
signal run()

var os_path
var ci_pid
var build_pid

func _init(path):
	"""Run a server on localhost at path"""
	os_path = path.replace("user://", OS.get_user_data_dir() + "/")

func run_server():
	if not DirAccess.dir_exists_absolute(os_path + "/node_modules"):
		npm_ci()
	else:
		npm_build()

func npm_ci():
	if OS.get_name() == "Windows":
		ci_pid = OS.create_process("CMD.exe", ["/C", "cd " + os_path + " && npm ci"], true)
	else:
		return
	packages.emit()

func npm_build():
	if OS.get_name() == "Windows":
		build_pid = OS.create_process("CMD.exe", ["/C", "cd " + os_path + " && npm run build"], true)
	else:
		return
	build.emit()

func npm_run():
	if OS.get_name() == "Windows":
		OS.create_process("CMD.exe", ["/C", "cd " + os_path + " && npm run start"], true)
	else:
		return
	run.emit()

func _process(_d):
	if not os_path:
		return
	if ci_pid:
		if ci_pid > 0 and OS.is_process_running(ci_pid):
			return
		ci_pid = null
		print("Building")
		npm_build()
	elif build_pid:
		if build_pid > 0 and OS.is_process_running(build_pid):
			return
		build_pid = null
		print("Running")
		npm_run()
