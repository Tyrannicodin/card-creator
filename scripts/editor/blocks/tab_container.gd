extends GridContainer


@onready var Blocks = $"../Blocks"

func _ready():
	for child in get_children():
		child.connect("pressed", set_tab(child))

## Get a buttons metadata to set which tab should be open
func set_tab(button):
	return func():
		Blocks.current_tab = button.get_meta("tab", -1)
