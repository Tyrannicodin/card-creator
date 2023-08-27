extends VBoxContainer


signal change_palette(palette:Palette)

var palette = Palette.new()

func foreground(col:Color):
	palette.set_property("foreground", col)
	change_palette.emit(palette)

func background(col:Color):
	palette.set_property("background", col)
	change_palette.emit(palette)

func text(col:Color):
	palette.set_property("text", col)
	change_palette.emit(palette)

func normal_attack(col:Color):
	palette.set_property("normal_attack", col)
	change_palette.emit(palette)

func special_attack(col:Color):
	palette.set_property("special_attack", col)
	change_palette.emit(palette)
