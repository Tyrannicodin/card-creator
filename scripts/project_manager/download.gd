extends Button


signal reload_projects()

var repository = "https://github.com/martinkadlec0/hc-tcg/archive/"

var sizes = {
	"v0_6_0": 39709080.0
}

var versions = {
	"v0_6_0": "f6517bba8a9e00a0188ba23ac572c7e00c13a72b"
}

class colors:
	"""Colors for status messages"""
	static var success = Color(0, 255, 0)
	static var error = Color(255, 0, 0)
	static var warn = Color(128, 128, 0)

var version_request = HTTPRequest.new()
var timer = Timer.new()
var downloading_version = null
var percentage

@onready var VersionSelector = $"../VersionSelector"
@onready var DownloadProgess = $"../DownloadProgress"
@onready var ProjectName = $"../ProjectName"
@onready var StatusLabel = $"../../StatusLabel"

func _ready():
	add_child(version_request)
	version_request.request_completed.connect(_request_finished)
	
	add_child(timer)
	timer.timeout.connect(reset_label)
	
	VersionSelector.item_selected.connect(_version_selected)
	
	if not DirAccess.dir_exists_absolute("user://versions/"):
		DirAccess.make_dir_absolute("user://versions/")
	
	load_versions()

func load_versions():
	"""Loop through the dictionary provided and add it to the version selector"""
	
	# Remove old items
	VersionSelector.clear()
	var first = true
	for version in versions.keys():
		# Add the latest tag for the first version in our list
		if first:
			version += " (latest)"
			first = false
		VersionSelector.add_item(version.replace("_", "."))
	
	# Set to the latest version
	VersionSelector.select(0)
	_version_selected(0)

func set_label_colour(color:Color):
	"""Remove old color and set a new one"""
	
	StatusLabel.remove_theme_color_override("font_color")
	StatusLabel.add_theme_color_override("font_color", color)

func reset_label():
	"""Reset the status label"""
	
	StatusLabel.text = ""
	StatusLabel.remove_theme_color_override("font_color")

func set_status(info, color=colors.error):
	"""Set the status and clear after 2 seconds"""
	
	set_label_colour(color)
	StatusLabel.text = info
	timer.start(2)

func _pressed():
	"""Based on the button's text, trigger creation, importing or downloading"""
	
	if text == "Create":
		create_new()
	else:
		try_download()
	
	reload_projects.emit()

func create_new():
	"""Create a new project by extracting the version file"""
	
	# Get version and path to the version folder
	var chosen_version = versions.keys()[VersionSelector.get_selected_id()]
	var version_dir_path = OS.get_user_data_dir() + "/versions/" + chosen_version
	
	# Check if we can name a folder the given name
	if not ProjectName.text.is_valid_filename():
		set_status("Error: Invalid project name")
		return
	var version_dir = DirAccess.open(version_dir_path)
	
	# Don't overwite other projects
	var unique_name = ProjectName.text
	if version_dir.dir_exists(unique_name):
		var i = 2
		while version_dir.dir_exists(unique_name + "_" + str(i)):
			i+=1
		unique_name = unique_name + "_" + str(i)
	
	# Extract based on operating system
	if OS.get_name() == "Windows":
		OS.execute(
			"CMD.exe",
			["/C", "cd " + version_dir_path + " && tar -xf " + chosen_version + ".zip"]
		)
	else:
		set_status("Error: Couldn't unzip file on your operating system")
		return
	
	# Rename the extracted file to the project name and check for success
	version_dir.rename("hc-tcg-" + versions[chosen_version], unique_name)
	if version_dir.dir_exists(unique_name):
		version_dir.change_dir(unique_name)
		
		# Create custom dir and meta for card data
		version_dir.make_dir("hc-tcg-cc")
		var meta_file = FileAccess.open(
			"user://versions/" + chosen_version + "/" + unique_name + "/hc-tcg-cc/meta.json",
			FileAccess.WRITE
		)
		meta_file.store_string(JSON.stringify({
			"name": ProjectName.text,
			"uid": unique_name,
			"game_version": chosen_version,
			"editor_version": ProjectSettings.get_setting("application/config/version"),
			"cards": 0,
			"packs": 0
		}))
		meta_file.close()
		reload_projects.emit()
		set_status("Project created", colors.success)
	else:
		set_status("Error: Couldn't unzip file")

func try_download():
	"""Attempt to download the version zip file"""
	
	# Find the selected version
	var chosen_version = versions.keys()[VersionSelector.get_selected_id()]
	
	# Check if a valid version is chosen and that we are ready to download
	if not (chosen_version and versions.has(chosen_version)):
		set_status("Error: Invalid version")
	if downloading_version:
		set_status("Error: Please wait until the current download is finished")
		return
	
	# Dont need to tell user the file exists, just ensure it switches to create 
	if FileAccess.file_exists("user://versions/" + chosen_version + "/" + chosen_version + ".zip"):
		_version_selected(VersionSelector.get_selected_id())
		return
	
	# Make required directories
	if not DirAccess.dir_exists_absolute("user://versions/" + chosen_version):
		DirAccess.make_dir_absolute("user://versions/" + chosen_version)
	
	# Set download location and make request
	version_request.download_file = "user://versions/" + chosen_version + "/" + chosen_version + ".zip"
	var error = version_request.request(repository + versions[chosen_version] + ".zip")
	
	# Check for any errors
	match error:
		Error.OK:
			set_status("Downloading " + chosen_version.replace("_", "."), colors.success)
		_:
			set_status("Error: Unknown error " + str(error))
			print(error)
	
	# Set currently downloading version
	downloading_version = chosen_version

func _version_selected(idx:int):
	"""Set button text and show name input depending on what version selected"""
	
	var chosen_version = versions.keys()[idx]
	if FileAccess.file_exists("user://versions/" + chosen_version + "/" + chosen_version + ".zip"):
		text = "Create"
		ProjectName.show()
	else:
		text = "Download"
		ProjectName.hide()

func _process(_d):
	"""Get downloaded percentage each frame and set the values accordingly"""
	
	if downloading_version:
		percentage = float(version_request.get_downloaded_bytes())/sizes[downloading_version]*100
		DownloadProgess.show()
	else:
		percentage = 0
		DownloadProgess.hide()
	DownloadProgess.value = percentage

func _request_finished(_r: int, _c: int, _h: PackedStringArray, _b: PackedByteArray):
	"""Reset stuff and notify user when the download is complete"""
	
	version_request.download_file = ""
	downloading_version = null
	set_status("Download success", colors.success)
	_version_selected(VersionSelector.get_selected_id())
