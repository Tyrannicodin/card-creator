extends Control


@export
var card: HermitCard = null

var type_images: Dictionary = {}
var cost_images: Dictionary = {}

func _ready():
    var path = "res://resources/images/types"
    var dir = DirAccess.open(path)
    for file in dir.get_files():
        type_images[file.split(".")[0]] = load(path + "/" + file.replace(".import", ""))
    path = "res://resources/images/ranks"
    dir = DirAccess.open(path)
    for file in dir.get_files():
        cost_images[file.split(".")[0]] = load(path + "/" + file.replace(".import", ""))
    

func card_set(new_card: HermitCard):
    card = new_card
    update_card()

func update_card():
    $Info/Name.text = card.name
    $Info/Name.modulate = CurrentPack.current_pack.text
    $Info/Health.text = str(card.health)
    $Info/Health.modulate = CurrentPack.current_pack.normal_attack

    $Corner/TextureRect.texture = type_images[Enums.Type.find_key(card.type).to_lower()]
    $TokenIcon.texture = null if card.cost == 0 else cost_images[str(card.cost)]

    set_attack_info($Attack1, card.primary_attack)
    set_attack_info($Attack2, card.secondary_attack)

    $Corner.self_modulate = CurrentPack.current_pack.foreground
    $AttackDivider.modulate = CurrentPack.current_pack.foreground
    $PictureBackground.self_modulate = CurrentPack.current_pack.foreground
    $Foreground.modulate = CurrentPack.current_pack.foreground

    $MarginContainer.modulate = CurrentPack.current_pack.background


func set_attack_info(attack: Control, attackInfo: Attack):
    attack.get_node("Name").text = attackInfo.name
    attack.get_node("Name").modulate = CurrentPack.current_pack.text
    attack.get_node("Damage").text = "00" if attackInfo.damage == 0 else str(attackInfo.damage)
    attack.get_node("Damage").modulate = (
        CurrentPack.current_pack.normal_attack if attackInfo.special_ability == ""
        else CurrentPack.current_pack.special_attack)

    attack.get_node("Items/1").texture = (
        null if attackInfo.item_1 == Enums.AttackType.NONE
        else type_images[Enums.AttackType.find_key(attackInfo.item_1).to_lower()])
    attack.get_node("Items/2").texture = (
        null if attackInfo.item_2 == Enums.AttackType.NONE
        else type_images[Enums.AttackType.find_key(attackInfo.item_2).to_lower()])
    attack.get_node("Items/3").texture = (
        null if attackInfo.item_3 == Enums.AttackType.NONE
        else type_images[Enums.AttackType.find_key(attackInfo.item_3).to_lower()])
