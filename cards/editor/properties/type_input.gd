extends OptionButton

signal card_update(property: String, value: Variant)

@export var target_property: String = "selected"
@export var property_updater: String = "item_selected"
@export var card_property: String = "name"

@export var extra_types: Array[String] = []

func _ready():
    var reg = RegEx.create_from_string("(?!^)([A-Z])")
    for extra in extra_types:
        add_item(extra)
    for type in Enums.Type:
        add_item(reg.sub(type.to_pascal_case(), " $1", true))
    
    connect(property_updater, target_changed)

func target_changed(value: Variant):
    card_update.emit(card_property, value)

func card_set(card: BasicCard):
    set(target_property, get_property(card, card_property))

func get_property(target, property):
    for part in property.split("."):
        target = target.get(part)
    return target
