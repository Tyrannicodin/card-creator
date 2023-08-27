extends VBoxContainer

var hermit_palette
var effect_palette
var single_use_palette

func hermit_palette_changed(new_palette:Palette):
	hermit_palette = new_palette

func effect_palette_changed(new_palette:Palette):
	effect_palette = new_palette

func single_use_palette_changed(new_palette:Palette):
	single_use_palette = new_palette
