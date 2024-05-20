extends Control
class_name EditorInput


signal card_update(property: String, value: Variant)

@export var target_property: String = "selected"
@export var property_updater: String = "item_selected"
@export var card_property: String = "name"

func _ready():
	connect(property_updater, target_changed)

func target_changed(value: Variant):
	card_update.emit(card_property, value)

func card_set(card: BasicCard):
	set(target_property, get_property(card, card_property))

func get_property(target, property):
	for part in property.split("."):
		target = target.get(part)
	return target
