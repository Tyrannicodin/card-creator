extends Control


@export
var card: EffectCard = null

var cost_images: Dictionary = {}

func _ready():
    var path = "res://resources/images/ranks"
    var dir = DirAccess.open(path)
    for file in dir.get_files():
        cost_images[file.split(".")[0]] = load(path + "/" + file.replace(".import", ""))

func card_set(new_card: EffectCard):
    card = new_card
    update_card()

func update_card():
    $Icon.texture = card.image
    $Tokens/Star.texture = cost_images[str(card.cost)]
    $Tokens.visible = card.cost != 0

    $MarginContainer.modulate = CurrentPack.current_pack.foreground
    $TextBackground/Name.modulate = CurrentPack.current_pack.foreground

    $Star.modulate = CurrentPack.current_pack.background
    $Tokens.self_modulate = CurrentPack.current_pack.background
    $TextBackground.self_modulate = CurrentPack.current_pack.background
    $Foreground.modulate = CurrentPack.current_pack.background
