extends Resource
class_name Pack

@export_group("Basic")
@export var id: String = "my_id"
@export var display_name: String = "My display name"
@export var icon: Texture2D

@export_group("Colours")
@export var background: Color = Color("e2ca8b")
@export var foreground: Color = Color("fff")
@export var text: Color = Color("000")
@export var normal_attack: Color = Color("f60401")
@export var special_attack: Color = Color("1742ea")

@export var scripts: Array = []
@export var cards: Dictionary = {} #[String, BasicCard]
