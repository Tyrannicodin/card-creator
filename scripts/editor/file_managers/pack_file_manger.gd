extends VBoxContainer


signal save_complete()

@onready var icon_rect:TextureRect = $Icons/IconRect
@onready var icon_file_dialog:FileDialog = $IconFileDialog
@onready var card = $"../../Tabs/CardEditor/Panel/VBoxContainer/card_container/card"

var palettes = {
	"hermit_palette": HermitPalette.new(),
	"effect_palette": Palette.new(),
	"single_use_palette": Palette.new(),
}

var meta:Dictionary

func _ready():
	for child in get_children():
		if child.name.ends_with("Palette"):
			var palette_name := child.name.to_snake_case()
			for node in child.get_node("color_container").get_children():
				if node is ColorPickerButton:
					node.color_changed.connect(func(col:Color):
						_palette_changed(palette_name, node.name, col))
	
	$Name.text = GlobalStorage.pack_name
	var meta_file := FileAccess.open(GlobalStorage.path + "/hc-tcg-cc/pack.meta", FileAccess.READ)
	meta = meta_file.get_var()
	meta_file.close()
	if FileAccess.file_exists(GlobalStorage.path + "/hc-tcg-cc/assets/icon.png"):
		icon_rect.texture = ImageTexture.create_from_image(
			Image.load_from_file(GlobalStorage.path + "/hc-tcg-cc/assets/icon.png"))
	
	for key in meta:
		if key.ends_with("palette"):
			var chosen_type
			if "hermit" in key:
				chosen_type = HermitPalette
			else:
				chosen_type = Palette
			if meta[key]:
				palettes[key] = chosen_type.from_dict(meta[key])
			else:
				palettes[key] = chosen_type.new()
				meta[key] = palettes[key].as_dict()
			var color_container = get_node(key.to_pascal_case()).get_node("color_container")
			for part in meta[key]:
				color_container.get_node(part).color = meta[key][part]

func save():
	for key in meta:
		if key.ends_with("palette"):
			meta[key] = palettes[key].as_dict()
	
	var meta_file := FileAccess.open(GlobalStorage.path + "/hc-tcg-cc/pack.meta", FileAccess.WRITE)
	meta_file.store_var(meta)
	meta_file.close()
	save_complete.emit()

func _icon_upload_started():
	icon_file_dialog.popup_centered()

func _icon_chosen(path:String):
	DirAccess.copy_absolute(path, GlobalStorage.path + "/hc-tcg-cc/assets/icon.png")
	icon_rect.texture = ImageTexture.create_from_image(
			Image.load_from_file(GlobalStorage.path + "/hc-tcg-cc/assets/icon.png"))

func _palette_changed(palette:String, part:String, col:Color):
	if palette == "hermit_palette":
		card.set_palette(palettes[palette])
	palettes[palette].set_property(part, col)
