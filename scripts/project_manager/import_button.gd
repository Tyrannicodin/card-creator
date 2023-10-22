extends Button


@onready var zipDialog = $ZipDialog

func _pressed():
	zipDialog.popup_centered()

func _zip_dialog_selected(file):
	var reader := ZIPReader.new()
	reader.open(file)
	var packed = reader.read_file("hc-tcg-cc/pack.meta")
	reader.close()
	print(packed.decode_var(0))
	var extFIle = FileAccess.open("user://packs/v0_6_19/test/hc-tcg-cc/pack.meta", FileAccess.READ)
	var unpacked = extFIle.get_buffer(extFIle.get_length())
	var repacked = PackedByteArray()
	repacked.encode_var(0, extFIle.get_var())
	print(unpacked)
	print(repacked)
