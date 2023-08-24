class_name ImageGenerator

var _type_icon_path = "res://assets/sprites/type_icons/"

func add_type_image(type: String, node: Control):
	for sub_node in node.get_children():
		sub_node.queue_free()
	node.add_child(_create_type_image(type))

func add_move_cost_images(typed_cost: int, untyped_cost: int, type: String, node: Node) -> void:
	for sub_node in node.get_children():
		sub_node.queue_free()
	for i in range(typed_cost):
		node.add_child(_create_type_image(type))
	for i in range(untyped_cost):
		node.add_child(_create_type_image("any"))

func load_texture(path: String) -> ImageTexture:
	var image = Image.new()
	image.load(path)
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func _create_type_image(type: String) -> TextureRect:
	var type_icon = TextureRect.new()
	type_icon.texture = load_texture(_type_icon_path + type + ".png")
	type_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	type_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	return type_icon

