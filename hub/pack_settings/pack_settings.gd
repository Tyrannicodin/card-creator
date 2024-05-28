extends MarginContainer


signal pack_set(pack: Pack)

func _ready():
	CurrentPack.on_pack_load.connect(on_pack_set)
	for child in (
		$GridsContainer/GeneralContainer.get_children() +
		$GridsContainer/PaletteContainer.get_children()):
		if child.get("pack_set"):
			pack_set.connect(child.get("pack_set"))
			child.pack_update.connect(pack_update)

func on_pack_set(pack: Pack):
	pack_set.emit(pack)

func pack_update(property: String, value: Variant):
	CurrentPack.current_pack.set(property, value)
	$"../Cards".property_updated("", "")

func pack_reload():
	pack_set.emit(CurrentPack.current_pack)
