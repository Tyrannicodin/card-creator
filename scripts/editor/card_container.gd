extends Panel

@onready var card = $card
@onready var types = $"../PropertyContainer/MarginContainer2/VBoxContainer/GridContainer/Type"

@onready var preview_viewport = $"../../../pose_editor".get_node("PreviewViewport")

# Called when the node enters the scene tree for the first time.
func _ready():
	card.image = preview_viewport.get_path()


func _on_name_text_changed(new_text):
	card.card_name = new_text


func _on_type_item_selected(index):
	card.type = types.get_item_text(index)


func _on_health_value_changed(value):
	card.health = int(value)


func _on_primary_name_text_changed(new_text):
	card.primary_move.name = new_text


func _on_primary_damage_value_changed(value):
	card.primary_move.damage = value


func _on_primary_typed_value_changed(value):
	card.primary_move.typed_cost = value


func _on_primary_untyped_value_changed(value):
	card.primary_move.untyped_cost = value


func _on_secondary_name_text_changed(new_text):
	card.secondary_move.name = new_text


func _on_secondary_damage_value_changed(value):
	card.secondary_move.damage = value


func _on_secondary_typed_value_changed(value):
	card.secondary_move.typed_cost = value


func _on_secondary_untyped_value_changed(value):
	card.secondary_move.untyped_cost = value

func _on_primary_ability_text_changed(new_text):
	if len(new_text) > 0:
		card.primary_move.is_special = true
	else:
		card.primary_move.is_special = false

func _on_secondary_ability_text_changed(new_text):
	if len(new_text) > 0:
		card.secondary_move.is_special = true
	else:
		card.secondary_move.is_special = false


func _on_file_dialog_file_selected(path):
	card.background = path
