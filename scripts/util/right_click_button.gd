extends Button
class_name RightClickButton


signal left_click()
signal right_click()

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				call("_left_click")
				left_click.emit()
			MOUSE_BUTTON_RIGHT:
				call("_right_click")
				right_click.emit()

func _left_click():
	pass

func _right_click():
	pass
