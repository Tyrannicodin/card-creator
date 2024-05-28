extends Control


signal pack_update(property: String, value: Variant)

@export var target_property: String = "color"
@export var property_updater: String = "color_changed"
@export var card_property: String = "foreground"

func _ready():
	connect(property_updater, target_changed)

func target_changed(value: Variant):
	pack_update.emit(card_property, value)

func pack_set(pack: Pack):
	set(target_property, pack.get(card_property))
