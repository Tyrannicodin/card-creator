extends SpinBox

@export
var types = ["effects", "hermits", "single-use"] #The types that use this data

signal fieldChanged(field, new_value)

func _value_changed(new_value):
	fieldChanged.emit(name, new_value)

func setType(type):
	visible = false
	if type in types:
		visible = true

func fileLoaded(json: Dictionary):
	var subNames = name.split("_")
	var currentLayer = json
	value = max_value - 50
	for subName in subNames:
		if currentLayer is Array:
			if subName.is_valid_int() and subName.to_int() < len(currentLayer):
				currentLayer = currentLayer[subName.to_int()]
		elif currentLayer is Dictionary:
			if currentLayer.has(subName):
				currentLayer = currentLayer[subName]
	if currentLayer is int:
		value = currentLayer
