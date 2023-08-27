extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_tab_container_tab_changed(tab):
	if tab == 0:
		$Codespace.visible = true
		$pose_editor.visible = false
	if tab == 1:
		$pose_editor.visible = true
		$Codespace.visible = false
