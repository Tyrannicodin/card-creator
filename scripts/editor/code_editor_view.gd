extends HBoxContainer


signal tab_changed(tab:int)

func _on_tab_container_tab_changed(tab):
	tab_changed.emit(tab)
	$Codespace.visible = false if tab else true
	$pose_editor.visible = true if tab else false
