extends Node

signal on_pack_load(pack: Pack)

var current_pack: Pack = Pack.new()
var current_path: String

func _ready():
    var card = HermitCard.new()
    card.id = "cool_card"
    card.name = "IskallMAN"
    card.health = 270
    card.rarity = Enums.Rarity.RARE
    card.type = Enums.Type.FARM
    card.primary_attack.name = "Big head"
    card.primary_attack.damage = 70
    card.primary_attack.item_1 = Enums.AttackType.FARM
    card.primary_attack.item_2 = Enums.AttackType.FARM
    card.secondary_attack.name = "Good Deed"
    card.secondary_attack.damage = 0
    card.secondary_attack.special_ability = "Cool special ability"
    card.secondary_attack.item_1 = Enums.AttackType.FARM
    card.secondary_attack.item_2 = Enums.AttackType.FARM
    card.secondary_attack.item_3 = Enums.AttackType.ANY
    current_pack.cards[card.id] = card
    on_pack_load.emit(current_pack)

func load_pack(path: String):
    current_pack = ResourceLoader.load(path, "Pack")
    current_path = path
    on_pack_load.emit(current_pack)

func save_pack(path: String = ""):
    var save_path = current_path
    if path != "":
        save_path = path
    ResourceSaver.save(current_pack, save_path)
