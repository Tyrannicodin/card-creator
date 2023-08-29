extends Palette
class_name HermitPalette

var normal_attack := Color("F60401")
var special_attack := Color("1742EA")
	
func set_property(property:String, col:Color):
	super.set_property(property, col)
	match property:
		"normal_attack":
			normal_attack = col
		"special_attack":
			special_attack = col

func as_dict():
	var super_dict = super.as_dict()
	super_dict.merge({
		"normal_attack": normal_attack,
		"special_attack": special_attack
	})
	return super_dict

static func from_dict(dict:Dictionary):
	var new_palette := HermitPalette.new()
	new_palette.background = dict["background"]
	new_palette.foreground = dict["foreground"]
	new_palette.text = dict["text"]
	new_palette.normal_attack = dict["normal_attack"]
	new_palette.special_attack = dict["special_attack"]
	return new_palette
