extends GraphNode


func _ready():
	title = name

	var i = 0
	for child in get_children():
		set_slot_enabled_left(i, child.left)
		if child.left:
			set_slot_type_left(i, 0)
			set_slot_color_left(i, child.left_color)

		set_slot_enabled_right(i, child.right)
		if child.right:
			set_slot_type_right(i, 1)
			set_slot_color_right(i, child.right_color)
		i += 1
