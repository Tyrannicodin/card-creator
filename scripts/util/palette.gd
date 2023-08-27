class_name Palette

var background := Color()
var foreground := Color()
var text := Color()
var normal_attack := Color()
var special_attack := Color()
	
func set_property(property:String, col:Color):
	match property:
		"background":
			background = col
		"foreground":
			foreground = col
		"text":
			text = col
		"normal_attack":
			normal_attack = col
		"special_attack":
			special_attack = col
	
func as_dict():
	return {
		"background": [background.r, background.g, background.b],
		"foreground": [foreground.r, foreground.g, foreground.b],
		"text": [text.r, text.g, text.b],
		"normal_attack": [normal_attack.r, normal_attack.g, normal_attack.b],
		"special_attack": [special_attack.r, special_attack.g, special_attack.b]
	}