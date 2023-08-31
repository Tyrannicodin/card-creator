extends Node2D

var HermitAttack = preload("res://scripts/card/move_type.gd")
var ImageGenerator = preload("res://scripts/card/image_generator.gd")

@onready var _type_icon_master = $Control/bg/type_circle/type_icon_master
@onready var _primary_node = $Control/bg/BoxContainer/MarginContainer/card_info/moves_margin/moves/primary
@onready var _secondary_node = $Control/bg/BoxContainer/MarginContainer/card_info/moves_margin/moves/secondary
@onready var _name_node = $Control/bg/BoxContainer/MarginContainer/card_info/header/name
@onready var _health_node = $Control/bg/BoxContainer/MarginContainer/card_info/header/health
@onready var _card_bg_node = $Control/bg/BoxContainer/MarginContainer/card_info/img_margin/image_panel/background
@onready var _card_img_node = $Control/bg/BoxContainer/MarginContainer/card_info/img_margin/image_panel/pose

@onready var primary_move = HermitAttack.new(_primary_node)
@onready var secondary_move = HermitAttack.new(_secondary_node)

var _imageGenerator = ImageGenerator.new()
var _palettes = Palettes.new()
var type: String : set = _set_type
var card_name: String : set = _set_card_name
var health: int : set = _set_health

var background: String : set = _set_bg
var image: String : set = _set_img

func set_palette(palette:Palette):
	get_tree().call_group("background", "set_color", palette.background)
	get_tree().call_group("foreground", "set_color", palette.foreground)
	get_tree().call_group("text", "set_color", palette.text)
	if palette is HermitPalette:
		get_tree().call_group("normal_attack", "set_color", palette.normal_attack)
		get_tree().call_group("special_attack", "set_color", palette.special_attack)

# Getters and setters
func _set_type(value: String) -> void:
	type = value
	_imageGenerator.add_type_image(type, _type_icon_master)
	primary_move.type = type
	secondary_move.type = type
	
func _set_card_name(value) -> void:
	card_name = value
	_name_node.text = card_name
	
func _set_health(value) -> void:
	health = value
	_health_node.text = str(health)
	
func _set_bg(value: String) -> void:
	background = value
	_card_bg_node.texture = _imageGenerator.load_texture(value)

func _set_img(value: String) -> void:
	image = value
	var viewport_texture = get_node(image).get_texture()
	_card_img_node.texture = viewport_texture

# Called when the node enters the scene tree for the first time.
func _ready():
	self.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
