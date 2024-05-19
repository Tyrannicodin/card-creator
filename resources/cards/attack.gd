extends Resource
class_name Attack

@export var name: String = ""
@export_range(0, 200, 10, "or_greater") var damage: int = 0
@export_multiline var special_ability: String = ""

@export var item_1: Enums.AttackType = Enums.AttackType.NONE
@export var item_2: Enums.AttackType = Enums.AttackType.NONE
@export var item_3: Enums.AttackType = Enums.AttackType.NONE