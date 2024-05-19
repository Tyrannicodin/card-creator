extends MarginContainer


signal card_set(card: BasicCard)

@onready var header: Label = $SplitScreen/ScrollContainer/GridsContainers/Header

var current_card: BasicCard

func _ready():
	var card = HermitCard.new()
	card.id = "cool_card"
	card.name = "IskallMAN"
	card.health = 270
	card.rarity = Enums.Rarity.RARE
	card.type = Enums.Type.FARM
	card.primary_attack.name = "Big head"
	card.primary_attack.damage = 70
	card.primary_attack.item_1 = Enums.AttackType.FARM
	card.primary_attack.item_2 = Enums.AttackType.FARM
	card.secondary_attack.name = "Good Deed"
	card.secondary_attack.damage = 0
	card.secondary_attack.special_ability = "Cool special ability"
	card.secondary_attack.item_1 = Enums.AttackType.FARM
	card.secondary_attack.item_2 = Enums.AttackType.FARM
	card.secondary_attack.item_3 = Enums.AttackType.ANY
	load_card(card)

func load_card(card: BasicCard):
	current_card = card

	for child in $SplitScreen/ScrollContainer/GridsContainers.get_children():
		if child.name != "Header" and child.name != "GeneralContainer":
			child.queue_free()
	for child in $SplitScreen/PreviewContainer/SubViewport.get_children():
		child.queue_free()

	var template: VBoxContainer
	var preview: Control

	if card is HermitCard:
		template = preload("res://cards/editor/hermit.tscn").instantiate()
		preview = preload("res://cards/preview/hermit/hermit.tscn").instantiate()
		header.text = "Hermit Card"
	elif card is EffectCard:
		template = preload("res://cards/editor/effect.tscn").instantiate()
		preview = preload("res://cards/preview/effect/effect.tscn").instantiate()
		header.text = "Effect Card"
	else:
		header.text = "Unknown card"
	
	for child in template.get_children():
		template.remove_child(child)
		$SplitScreen/ScrollContainer/GridsContainers.add_child(child)
		for property in child.get_children():
			if property.get("card_set") and property.has_signal("card_update"):
				card_set.connect(property.get("card_set"))
				property.connect("card_update", property_updated)
	$SplitScreen/PreviewContainer/SubViewport.add_child(preview)
	card_set.connect(preview.card_set)
	card_set.emit(card)

func property_updated(property, value):
	set_recursive(current_card, property, value)
	$SplitScreen/PreviewContainer/SubViewport.get_child(0).card_set(current_card)

func set_recursive(target, property, value):
	var split_property = property.split(".")
	var to_get = split_property.slice(0, len(split_property)-1)
	for part in to_get:
		target = target.get(part)
	target.set(split_property[-1], value)
