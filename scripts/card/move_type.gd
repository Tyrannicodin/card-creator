class_name HermitAttack

var ImageGenerator = preload("res://scripts/card/image_generator.gd")
var _imageGenerator = ImageGenerator.new()

var parent: Node : set = _set_parent
var typed_cost: int : set = _set_typed_cost
var untyped_cost: int : set = _set_untyped_cost
var name: String : set = _set_name
var damage: int : set = _set_damage
var is_special: bool : set = _set_is_special
var type: String : set = _set_type

var palette_overrides

var _cost_node: HBoxContainer
var _name_node: Label
var _damage_node: Label

func _init(parent_val: Node):
	parent = parent_val
	_cost_node = parent.get_node("margin/cost")
	_name_node = parent.get_node("name_container/name")
	_damage_node = parent.get_node("damage")

func _set_parent(value: Node):
	parent = value

func _set_typed_cost(value: int):
	typed_cost = value
	if type == null:
		return
	_imageGenerator.add_move_cost_images(typed_cost, untyped_cost, type, _cost_node)
	
func _set_untyped_cost(value: int):
	untyped_cost = value
	if type == null:
		return
	_imageGenerator.add_move_cost_images(typed_cost, untyped_cost, type, _cost_node)

func _set_name(value: String):
	name = value
	_name_node.text = name
	
func _set_damage(value: int):
	damage = value
	_damage_node.text = str(damage)

func _set_is_special(value: bool):
	is_special = value
	if is_special == true:
		_damage_node.add_theme_color_override("font_color", Color("1742EA"))
	else:
		_damage_node.add_theme_color_override("font_color", Color("f60401"))
	
func _set_type(value: String):
	type = value
	if type == null:
		return
	_imageGenerator.add_move_cost_images(typed_cost, untyped_cost, type, _cost_node)
