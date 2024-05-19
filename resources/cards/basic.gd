extends Resource
class_name BasicCard

@export_group("Basic")
@export var id: String = ""
@export var name: String = ""
@export var rarity: Enums.Rarity = Enums.Rarity.COMMON
@export_range(0, 5, 1) var cost: int = 0
@export var script_id: String = ""
