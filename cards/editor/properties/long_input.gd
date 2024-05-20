extends TextEdit

signal card_update(property: String, value: Variant)

@export var card_property: String = "description"

func _ready():
    text_changed.connect(on_text_changed)

func on_text_changed():
    card_update.emit(card_property, text)

func card_set(card: BasicCard):
    text = card.get(card_property)
