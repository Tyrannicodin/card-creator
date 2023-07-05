extends OptionButton

@export
var types = ["effects", "hermits", "single-use"] #The types that use this data

signal fieldChanged(field, value)

func _ready():
	connect("item_selected", itemSelected)

func itemSelected(_id):
	fieldChanged.emit(name, text)

func setType(type):
	visible = false
	if type in types:
		visible = true

func fileLoaded(json: Dictionary):
	var subNames = name.split("_")
	var currentLayer = json
	select(0)
	for subName in subNames:
		if currentLayer is Array:
			if subName.is_valid_int() and subName.to_int() < len(currentLayer):
				currentLayer = currentLayer[subName.to_int()]
		elif currentLayer is Dictionary:
			if currentLayer.has(subName):
				currentLayer = currentLayer[subName]
	if currentLayer is String:
		for item in item_count:
			if get_item_text(item) == currentLayer:
				select(item)
