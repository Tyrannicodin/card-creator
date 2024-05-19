extends LineEdit


signal card_update(property: String, value: Variant)

func text_changed(new_text: String, trigger_signal: bool = true):
	$"../Id".text = new_text.to_snake_case()
	if trigger_signal:
		card_update.emit("name", new_text)
		card_update.emit("id", new_text.to_snake_case())

func card_set(card: BasicCard):
	text = card.name
	text_changed(text, false)
