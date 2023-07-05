extends Button

func deleteFile():
	print("Totally deleted")

func _pressed():
	var confirm = ConfirmationDialog.new()
	confirm.get_label().text = "Are you sure you want to delete this file?"
	confirm.get_ok_button().text = "Yes"
	confirm.get_cancel_button().text = "No"
	confirm.confirmed.connect(deleteFile)
	add_child(confirm)
	confirm.popup_centered()
