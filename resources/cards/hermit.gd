extends BasicCard
class_name HermitCard

@export_group("Hermit")
@export_range(10, 300, 10, "or_greater") var health: int = 10
@export var type: Enums.Type
@export var hermit_image: Texture2D
@export var background_image: Texture2D

@export var primary_attack: Attack = Attack.new()
@export var secondary_attack: Attack = Attack.new()
