class_name Palette

var background := Color("E2CA8B")
var foreground := Color("FFFFFF")
var text := Color("000000")
	
func set_property(property:String, col:Color) -> void:
	match property:
		"background":
			background = col
		"foreground":
			foreground = col
		"text":
			text = col

func as_dict() -> Dictionary:
	return {
		"background": background,
		"foreground": foreground,
		"text": text
	}

static func from_dict(dict:Dictionary):
	var new_palette = Palette.new()
	new_palette.background = dict["background"]
	new_palette.foreground = dict["foreground"]
	new_palette.text = dict["text"]
	return new_palette
