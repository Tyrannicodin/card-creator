extends MarginContainer


signal card_set(card: BasicCard)

@onready var header: Label = $SplitScreen/ScrollContainer/GridsContainers/Header

var current_card: BasicCard
var freeze_preview: bool = false

func load_card(card: BasicCard):
    current_card = card

    for child in $SplitScreen/ScrollContainer/GridsContainers.get_children():
        if child.name != "Header" and child.name != "GeneralContainer":
            child.free()
    for child in $SplitScreen/PreviewContainer/SubViewport.get_children():
        child.free()

    var template: VBoxContainer
    var preview: Control

    if card is HermitCard:
        template = preload("res://cards/editor/properties/hermit.tscn").instantiate()
        preview = preload("res://cards/preview/hermit/hermit.tscn").instantiate()
        header.text = "Hermit Card"
    elif card is EffectCard:
        template = preload("res://cards/editor/properties/effect.tscn").instantiate()
        preview = preload("res://cards/preview/effect/effect.tscn").instantiate()
        header.text = "Effect Card"
    else:
        header.text = "Unknown card"

    freeze_preview = true

    $SplitScreen/PreviewContainer/SubViewport.add_child(preview)
    card_set.connect(preview.card_set)
    
    for child in template.get_children():
        template.remove_child(child)
        $SplitScreen/ScrollContainer/GridsContainers.add_child(child)
        for property in child.get_children():
            if property.get("card_set") and property.has_signal("card_update"):
                card_set.connect(property.get("card_set"))
                property.connect("card_update", property_updated)
    card_set.emit(card)

    freeze_preview = false

func property_updated(property, value):
    if freeze_preview:
        return
    set_recursive(current_card, property, value)
    $SplitScreen/PreviewContainer/SubViewport.get_child(0).card_set(current_card)

func set_recursive(target, property, value):
    var split_property = property.split(".")
    var to_get = split_property.slice(0, len(split_property)-1)
    for part in to_get:
        target = target.get(part)
    target.set(split_property[-1], value)
