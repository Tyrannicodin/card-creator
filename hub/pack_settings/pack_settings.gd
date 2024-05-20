extends MarginContainer


@onready var idText: LineEdit = $GridsContainer/GeneralContainer/Id
@onready var nameText: LineEdit = $GridsContainer/GeneralContainer/Name
@onready var packIcon: TextureRect = $GridsContainer/GeneralContainer/Icon/IconTexture

@onready var backgroundColor: ColorPickerButton = $GridsContainer/PaletteContainer/Background
@onready var foregroundColor: ColorPickerButton = $GridsContainer/PaletteContainer/Foreground
@onready var textColor: ColorPickerButton = $GridsContainer/PaletteContainer/Text
@onready var attackNormalColor: ColorPickerButton = $GridsContainer/PaletteContainer/AttackNormal
@onready var attackSpecialColor: ColorPickerButton = $GridsContainer/PaletteContainer/AttackSpecial

func _ready():
    get_pack_info()

func get_pack_info():
    if not CurrentPack.current_pack:
        return
    idText.text = CurrentPack.current_pack.id
    nameText.text = CurrentPack.current_pack.display_name
    packIcon.texture = CurrentPack.current_pack.icon

    backgroundColor.color = CurrentPack.current_pack.background
    foregroundColor.color = CurrentPack.current_pack.foreground
    textColor.color = CurrentPack.current_pack.text
    attackNormalColor.color = CurrentPack.current_pack.normal_attack
    attackSpecialColor.color = CurrentPack.current_pack.special_attack
