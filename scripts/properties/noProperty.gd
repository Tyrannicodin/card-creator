extends Control

@export
var types = ["effects", "hermits", "single-use"] #The types that use this data

signal fieldChanged(field, value)

func setType(type):
	visible = false
	if type in types:
		visible = true

func fileLoaded(_json: Dictionary):
	pass

