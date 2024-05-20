extends OptionButton

signal load_card(card: BasicCard)

func _ready():
    for card in CurrentPack.current_pack.cards.values():
        add_card_button(card)

func add_card_button(card: BasicCard):
    var current_button = Button.new()
    current_button.name = card.id
    current_button.text = card.id
    get_parent().add_child.call_deferred(current_button)
    current_button.pressed.connect(func (): load_card.emit(card))

func item_selected(index: int):
    if index == 0:
        return
    selected = 0
    var new_card_name = "new_card"
    var new_card_index = 1
    while CurrentPack.current_pack.cards.has(new_card_name + str(new_card_index)):
        new_card_index += 1
    var new_card: BasicCard
    if index == 1:
        new_card = HermitCard.new()
    elif index == 2:
        new_card = EffectCard.new()
    new_card.id = new_card_name + str(new_card_index)
    CurrentPack.current_pack.cards[new_card.id] = new_card
    add_card_button(new_card)
