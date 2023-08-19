extends VBoxContainer

signal filePicked(fileText)
signal getFd()

var path

class fileClass:
	var jsString
	var name
	var constructor
	
	var satisfiesRegex = RegEx.new()
	var bracketsRegex = RegEx.new()
	
	var matchingBrackets = {
		"'": "'",
		'"': '"',
		"`": "`",
		"{": "}",
		"[": "]"
	}
	
	var replaceChars = {
		"\\\\": "\\",
		"\\\"": "\"",
		"\\n": "\n",
		"\\r": "\\r",
		"\\b": "\b",
		"\\f": "\f",
		"\\t": "\t"
	}
	
	var whiteSpace = [
		"\n",
		"\t",
		"\r",
		" "
	]
	
	func _init(folder:folderClass, fileName:String = ""):
		if fileName:
			var file = FileAccess.open(folder.path + "/" + folder.name + "/" + fileName, FileAccess.READ)
			jsString = file.get_as_text()
			file.close()
			constructor = get_constructor()
			name = constructor["id"]
		else:
			constructor = {}
	
	func render(pressEvent):
		var button = Button.new()
		button.name = name
		button.text = name
		button.pressed.connect(pressEvent)
		return button
	
	func get_constructor():
		satisfiesRegex.compile("\\/\\*\\*[^\\*]*\\*\\/")
		bracketsRegex.compile("\\(\\)")
		
		var isolatedConstructor = jsString.replace("\t", "").replace("\r\n", "").split("super(", true, 1)[-1].split("})}", true, 1)[0].rstrip(",") + "}"
		isolatedConstructor = satisfiesRegex.sub(isolatedConstructor, "", true)
		isolatedConstructor = bracketsRegex.sub(isolatedConstructor, "", true)
		return parseJSON(isolatedConstructor)
	
	func parseJSON(json:String):
		if json.begins_with("{"): # Object type
			json[0] = ""
			var result = {}
			var openBrackets = ["{"]
			var currentKey = ""
			var currentValue = ""
			var inValue = false
			var awaitingColon = false
			for character in json:
				if inValue: #Parse until we end a value
					if currentValue == "": #Value not started yet
						if character in whiteSpace:
							pass
						else:
							currentValue = character
							if matchingBrackets.has(character):
								openBrackets.append(character)
					else: #In value
						if character == "," and len(openBrackets) == 1: #Value ended
							result[currentKey] = parseJSON(currentValue)
							currentKey = ""
							currentValue = ""
							inValue = false
						elif currentValue.ends_with("\\"):
							currentValue += character
						elif matchingBrackets[openBrackets.back()] == character: #Brackets closing
							openBrackets.pop_back()
							if len(openBrackets) == 0: #End of object
								result[currentKey] = parseJSON(currentValue)
								break #Ignore rest of file
							currentValue += character
						elif matchingBrackets.has(character): #Brackets opening
							if not openBrackets.back() in ["'", '"', "`"]: #Ignore brackets in string
								openBrackets.append(character)
							currentValue += character
						else:
							currentValue += character
				else: #Parse until we get a colon
					if character in whiteSpace:
						if currentKey == "": #Nothing yet
							pass
						else:
							awaitingColon = true
					elif awaitingColon:
						if character in whiteSpace:
							pass
						elif character == ":":
							awaitingColon = false
							inValue = true
							match currentKey.left(1):
								"'":
									currentKey = currentKey.lstrip("'").rstrip("'")
								'"':
									currentKey = currentKey.lstrip('"').rstrip('"')
								"`":
									currentKey = currentKey.lstrip("`").rstrip("`")
						elif character == "}":
							openBrackets.pop_back()
							break
						else:
							push_error("Unexpected token: {character}".format({"character": character}))
					else:
						if character == ":":
							awaitingColon = false
							inValue = true
							match currentKey.left(1):
								"'":
									currentKey = currentKey.lstrip("'").rstrip("'")
								'"':
									currentKey = currentKey.lstrip('"').rstrip('"')
								"`":
									currentKey = currentKey.lstrip("`").rstrip("`")
						elif character == "}":
							openBrackets.pop_back()
							break
						else:
							currentKey += character
			if not len(openBrackets) == 0:
				push_error("Unbalanced {bracket} in json: {json}".format({"bracket": openBrackets[-1], "json": "{" + json}))
			return result
		elif json.begins_with("["): # Array type
			json[0] = ""
			#json[json.length()-1] = ""
			var result = []
			var openBrackets = ["["]
			var currentToken = ""
			var inToken = false
			var nextToken = true
			for character in json:
				if inToken:
					if currentToken.ends_with("\\"):
						if replaceChars.has("\\" + character):
							currentToken[currentToken.length()-1] = replaceChars["\\" + character]
						else:
							push_error("Invalid escape: {escape}".format({"escape": "\\" + character}))
							return
					elif len(openBrackets) == 1 and (character == "," or character == matchingBrackets[openBrackets.back()]):
						result.append(parseJSON(currentToken))
						currentToken = ""
						inToken = false
						nextToken = true
						if character == matchingBrackets[openBrackets.back()]:
							openBrackets.pop_back()
					elif character == matchingBrackets[openBrackets.back()]:
						openBrackets.pop_back()
						currentToken += character
						if len(openBrackets) == 1:
							result.append(parseJSON(currentToken))
							currentToken = ""
							inToken = false
					elif not openBrackets.back() in ["'", '"', "`"] and matchingBrackets.has(character):
						openBrackets.append(character)
						currentToken += character
					else:
						currentToken += character
				else:
					if matchingBrackets.has(character) and nextToken:
						currentToken = character
						inToken = true
						nextToken = false
						openBrackets.append(character)
					elif len(openBrackets) > 0 and character == matchingBrackets[openBrackets.back()]:
						openBrackets.pop_back()
					elif character in whiteSpace: # Whitespace
						pass
					elif character == "," and not nextToken:
						nextToken = true
					elif nextToken: #Assume to be literal values
						currentToken = character
						inToken = true
						nextToken = false
					else:
						push_error("Invalid token in json: {character}".format({"character": character}))
						return
			if not len(openBrackets) == 0:
				push_error("Unbalanced {bracket} in json: {json}".format({"bracket": openBrackets[-1], "json": "[" + json}))
			return result
		elif json.begins_with('"') or json.begins_with("'") or json.begins_with("`"): # String type
			match json.left(1):
				"'":
					json = json.lstrip("'").rstrip("'")
				'"':
					json = json.lstrip('"').rstrip('"')
				"`":
					json = json.lstrip("`").rstrip("`")
			for toReplace in replaceChars:
				json = json.replace(toReplace, replaceChars[toReplace])
			return json
		elif json.to_lower() == "null" or json.to_lower() == "none": # Null type
			return null
		elif json.to_lower() == "true" or json.to_lower() == "false": # Bool type
			return json.to_lower() == "true"
		elif json.is_valid_float(): # Number type
			if json.is_valid_int():
				return json.to_int()
			return json.to_float()
		else:
			push_error("Invalid JSON type: {json}".format({"json": json}))


class folderClass:
	signal filePicked(folder, file)
	
	var files = []
	var name
	var path
	
	func _init(folderName, basePath):
		name = folderName
		path = basePath
		var dir = DirAccess.open(basePath + "/" + folderName)
		for file in dir.get_files():
			if not (file.begins_with("_") or file == "index.js"):
				addFile(file)
	
	func addFile(fileName):
		files.append(fileClass.new(self, fileName))
	
	func render():
		var base = VBoxContainer.new()
		base.name = "folder_%s" % name
		var header = HBoxContainer.new()
		
		var nameLabel = Label.new()
		nameLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nameLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		nameLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nameLabel.text = name
		header.add_child(nameLabel)
		
		var createButton = Button.new()
		createButton.text = "New"
		createButton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		createButton.pressed.connect(func():
			addFile("")
			filePicked.emit())
		header.add_child(createButton)
		
		base.add_child(header)
		for file in files:
			var buttonPressEvent = func():
				filePicked.emit(name, file)
			base.add_child(file.render(buttonPressEvent))
		return base

var folders = {}

func addFolder(folderName):
	var newFolder = folderClass.new(folderName, path)
	newFolder.connect("filePicked", on_file_pick)
	if len(newFolder.files) > 0:
		folders[folderName] = newFolder
		return newFolder

func on_file_pick(folder, file):
	var properties = get_tree().get_nodes_in_group("properties")
	var constructor = file.constructor
	for property in properties:
		property.call("setType", folder)
		property.call("fileLoaded", constructor)

func _ready():
	get_tree().call_group("properties", "setType", "")
	getFd.emit()

func openServer(fp:String):
	path = fp + "/common/cards/card-plugins"
	if not DirAccess.dir_exists_absolute(path):
		getFd.emit()
		return
	var dir = DirAccess.open(path)
	for subDir in dir.get_directories():
		if subDir == "items": #Will be automatically created
			continue
		addFolder(subDir)
	update()

func update():
	for child in get_children():
		if child.name.begins_with("folder"):
			child.queue_free()
	for folder in folders.values():
		add_child(folder.render())
